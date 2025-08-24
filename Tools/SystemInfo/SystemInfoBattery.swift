import Foundation
import IOKit.ps

struct BatteryInfo {
    var percentage: Int?
    var isCharging: Bool?
    var isCharged: Bool?
    var timeRemainingMinutes: Int?
    var cycleCount: Int?
    var condition: String?
}

enum BatteryReader {
    static func read() -> BatteryInfo {
        var info = BatteryInfo()
        if let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(),
           let list = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef],
           let pwr = list.first,
           let desc = IOPSGetPowerSourceDescription(snapshot, pwr)?.takeUnretainedValue() as? [String: Any]
        {
            if let cap = desc[kIOPSCurrentCapacityKey as String] as? Int,
               let max = desc[kIOPSMaxCapacityKey as String] as? Int, max > 0
            {
                info.percentage = Int((Double(cap) / Double(max)) * 100.0 + 0.5)
            }
            if let state = desc[kIOPSPowerSourceStateKey as String] as? String {
                info.condition = (info.condition ?? "") + " (\(state))"
            }
            if let isCharging = desc[kIOPSIsChargingKey as String] as? Bool {
                info.isCharging = isCharging
            }
            if let isCharged = desc[kIOPSIsChargedKey as String] as? Bool {
                info.isCharged = isCharged
            }
            if let time = IOPSGetTimeRemainingEstimate() as Double?,
               time != kIOPSTimeRemainingUnknown
            {
                info.timeRemainingMinutes = Int(time / 60.0)
            }
        }

        // Cycle count & condition via ioreg (quick fallback)
        if let cyclesStr = shell(["/usr/sbin/ioreg", "-r", "-n", "AppleSmartBattery", "-k", "CycleCount", "-a"]),
           let n = cyclesStr.components(separatedBy: CharacterSet.decimalDigits.inverted).joined().nilIfEmpty(),
           let cycles = Int(n)
        {
            info.cycleCount = cycles
        }
        if let cond = shell(["/usr/sbin/ioreg", "-r", "-n", "AppleSmartBattery", "-k", "BatteryHealth", "-a"])?
            .components(separatedBy: CharacterSet.newlines).first(where: { $0.contains("BatteryHealth") })
        {
            info.condition = cond.trimmingCharacters(in: .whitespacesAndNewlines)
        }

        return info
    }

    private static func shell(_ cmd: [String]) -> String? {
        let task = Process()
        task.launchPath = cmd.first
        task.arguments = Array(cmd.dropFirst())
        let pipe = Pipe()
        task.standardOutput = pipe
        do { try task.run() } catch { return nil }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }
}

private extension String {
    func nilIfEmpty() -> String? { isEmpty ? nil : self }
}
