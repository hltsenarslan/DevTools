import Foundation

enum ManifestSource {
    static func load() -> Manifest {
        let fm = FileManager.default
        let appSup = (try? fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true))
            .map { $0.appendingPathComponent("DevTools", isDirectory: true) }
        if let appSup, fm.fileExists(atPath: appSup.appendingPathComponent("tools.manifest.json").path) {
            if let data = try? Data(contentsOf: appSup.appendingPathComponent("tools.manifest.json")),
               let m = try? JSONDecoder().decode(Manifest.self, from: data) {
                return m
            }
        }
        // Fallback to bundled manifest
        if let url = Bundle.main.url(forResource: "tools.manifest", withExtension: "json", subdirectory: "Manifest"),
           let data = try? Data(contentsOf: url),
           let m = try? JSONDecoder().decode(Manifest.self, from: data) { return m }
        return Manifest(version: 1, tools: [ToolItem(id: "json_beautifier", name: "JSON Beautifier", type: .builtin, icon: "hammer", url: nil)])
    }
}