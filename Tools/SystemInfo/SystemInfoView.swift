import IOKit
import IOKit.ps
import SwiftUI

struct SystemInfoView: View {
    @State private var info: [String: String] = [:]
    @State private var cpuTemp: String = "—"
    @State private var fanLines: [String] = []
    @State private var battery: BatteryInfo = .init()
    @State private var timer: Timer?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("System Information").font(.title2).bold()

            // Basic
            GroupBox(label: Text("Basics").bold()) {
                listify(info)
            }

            // CPU & Fans
            GroupBox(label: Text("Thermals & Fans").bold()) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("CPU Temperature").bold()
                        Spacer()
                        Text(cpuTemp).font(.system(.body, design: .monospaced))
                    }
                    Divider()
                    ForEach(fanLines, id: \.self) { line in
                        HStack {
                            Text(line.components(separatedBy: ":").first ?? "Fan").bold()
                            Spacer()
                            Text(line.components(separatedBy: ":").dropFirst().joined(separator: ":").trimmingCharacters(in: .whitespaces))
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                }
                .padding(.horizontal, 4)
            }

            // Battery
            GroupBox(label: Text("Battery").bold()) {
                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 6) {
                    gridRow("Charge", battery.percentage.map { "\($0)%" } ?? "—")
                    gridRow("Charging", battery.isCharging.map { $0 ? "Yes" : "No" } ?? "—")
                    gridRow("Charged", battery.isCharged.map { $0 ? "Yes" : "No" } ?? "—")
                    gridRow("Time Remaining", battery.timeRemainingMinutes.map { "\($0) min" } ?? "—")
                    gridRow("Cycle Count", battery.cycleCount.map(String.init) ?? "—")
                    gridRow("Condition", battery.condition ?? "—")
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            loadBasic()
            refreshSensors()
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
                refreshSensors()
            }
        }
        .onDisappear { timer?.invalidate() }
    }

    // MARK: UI helpers

    private func listify(_ dict: [String: String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(dict.keys.sorted(), id: \.self) { k in
                HStack {
                    Text(k).bold()
                    Spacer()
                    Text(dict[k] ?? "")
                        .font(.system(.body, design: .monospaced))
                        .lineLimit(3)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }

    private func gridRow(_ k: String, _ v: String) -> some View {
        GridRow {
            Text(k).bold()
            Text(v).font(.system(.body, design: .monospaced))
        }
    }

    // MARK: Data loaders

    private func loadBasic() {
        var dict: [String: String] = [:]
        let process = ProcessInfo.processInfo
        dict["OS Version"] = process.operatingSystemVersionString
        dict["Host Name"] = Host.current().localizedName ?? "?"
        dict["Processor Count"] = "\(process.processorCount)"
        dict["Active Processors"] = "\(process.activeProcessorCount)"
        dict["Physical Memory (GB)"] = String(format: "%.2f", Double(process.physicalMemory) / 1_073_741_824.0)
        dict["Uptime (s)"] = "\(Int(process.systemUptime))"

        // Kernel & CPU brand via sysctl
        if let model = sysctlString("machdep.cpu.brand_string") { dict["CPU Model"] = model }
        if let kern = sysctlString("kern.version") { dict["Kernel Version"] = kern }

        info = dict
    }

    private func refreshSensors() {
        // CPU temperature: try common SMC keys in order
        let tempKeys = ["TC0P", "TC0E", "TC0F", "TCPU", "Tp0P"]
        if let t = SMC.readTemperatureC(keys: tempKeys) {
            cpuTemp = String(format: "%.1f ℃", t)
        } else {
            cpuTemp = "—"
        }

        // Fans
        var lines: [String] = []
        let count = max(SMC.fanCount(), 2) // try first 2 if FNum not present
        for i in 0 ..< count {
            if let rpm = SMC.readFanRPM(index: i), rpm > 0 {
                lines.append("Fan \(i): \(Int(rpm)) rpm")
            }
        }
        if lines.isEmpty { lines = ["Fan: —"] }
        fanLines = lines

        // Battery
        battery = BatteryReader.read()
    }

    private func sysctlString(_ key: String) -> String? {
        var size: size_t = 0
        sysctlbyname(key, nil, &size, nil, 0)
        guard size > 0 else { return nil }
        var buf = [CChar](repeating: 0, count: size)
        let ret = sysctlbyname(key, &buf, &size, nil, 0)
        guard ret == 0 else { return nil }
        return String(cString: buf)
    }
}
