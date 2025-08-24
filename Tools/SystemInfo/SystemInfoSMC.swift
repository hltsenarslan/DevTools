import Foundation
import IOKit

// Minimal SMC bridge for reading keys like TC0P (CPU temp) and F0Ac (fan RPM)
final class SMC {
    static let shared = SMC()

    private static var connection: io_connect_t = 0

    private init() {
        _ = SMC.open()
    }

    // MARK: - Open/Close

    @discardableResult
    private static func open() -> Bool {
        if connection != 0 { return true }
        let service = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSMC"))
        guard service != 0 else { return false }
        let kr = IOServiceOpen(service, mach_task_self_, 0, &connection)
        IOObjectRelease(service)
        return kr == KERN_SUCCESS
    }

    static func close() {
        if connection != 0 {
            IOServiceClose(connection)
            connection = 0
        }
    }

    // MARK: - Structures (layout approximation for AppleSMC user client)

    struct SMCKeyData_t {
        var key: UInt32 = 0
        var vers: (major: UInt8, minor: UInt8, build: UInt8, reserved: UInt8, release: UInt16) = (0, 0, 0, 0, 0)
        var length: UInt32 = 0
        var dataType: UInt32 = 0
        var dataAttributes: UInt8 = 0
        var result: UInt8 = 0
        var status: UInt8 = 0
        var data8: UInt8 = 0
        var data32: UInt32 = 0
        var bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    }

    struct SMCParamStruct {
        var key: UInt32 = 0
        var dataSize: UInt32 = 0
        var dataType: UInt32 = 0
        var dataAttributes: UInt8 = 0
        var bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                    UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    }

    // SMC selectors (empirical)
    private static let kSMCHandleY: UInt32 = 2 // read key by name

    private static func toFourCC(_ s: String) -> UInt32 {
        var result: UInt32 = 0
        for c in s.utf8 {
            result = (result << 8) | UInt32(c)
        }
        return result
    }

    // MARK: - Read

    static func readKey(_ name: String) -> Data? {
        guard open() else { return nil }
        var input = SMCKeyData_t()
        var output = SMCParamStruct()

        input.key = toFourCC(name)

        let inSize = MemoryLayout<SMCKeyData_t>.stride
        let outSize = MemoryLayout<SMCParamStruct>.stride

        let kr = withUnsafePointer(to: &input) { inPtr -> kern_return_t in
            withUnsafeMutablePointer(to: &output) { outPtr in
                let inStruct = UnsafeRawPointer(inPtr).bindMemory(to: UInt8.self, capacity: inSize)
                let outStruct = UnsafeMutableRawPointer(outPtr).bindMemory(to: UInt8.self, capacity: outSize)
                var outCnt = outSize
                return IOConnectCallStructMethod(connection, kSMCHandleY, inStruct, inSize, outStruct, &outCnt)
            }
        }
        guard kr == KERN_SUCCESS else { return nil }

        // Convert tuple bytes to Data (length in output.dataSize)
        let count = Int(output.dataSize)
        let mirror = Mirror(reflecting: output.bytes)
        let arr = mirror.children.compactMap { $0.value as? UInt8 }
        return Data(arr.prefix(count))
    }

    // Many temperature sensors use "sp78" (signed fixed 7.8)
    static func readTemperatureC(keys: [String]) -> Double? {
        for k in keys {
            if let d = readKey(k), d.count >= 2 {
                let val = (Int16(Int(d[0]) << 8) | Int16(Int(d[1])))
                return Double(val) / 256.0
            }
        }
        return nil
    }

    // Fan RPMs (F0Ac, F1Ac...) often "fpe2" (16.16) or 8.8; try to interpret
    static func readFanRPM(index: Int) -> Double? {
        let key = "F\(index)Ac"
        if let d = readKey(key) {
            if d.count >= 4 {
                let v = (UInt32(d[0]) << 24) | (UInt32(d[1]) << 16) | (UInt32(d[2]) << 8) | UInt32(d[3])
                return Double(v) / 65536.0 // assume 16.16
            } else if d.count >= 2 {
                let v = (UInt16(d[0]) << 8) | UInt16(d[1])
                return Double(v)
            }
        }
        return nil
    }

    static func fanCount() -> Int {
        if let d = readKey("FNum"), d.count >= 1 { return Int(d[0]) }
        return 0
    }
}
