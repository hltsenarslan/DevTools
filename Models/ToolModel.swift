import Foundation

struct Manifest: Codable {
    var version: Int
    var tools: [ToolItem]
}

struct ToolItem: Codable, Identifiable {
    let id: String
    let name: String
    let type: ToolType
    let icon: String?
    let url: URL?
}

enum ToolType: String, Codable { case builtin, url }