import AppKit

enum AppearanceMode: Int, CaseIterable {
    case system = 0, light = 1, dark = 2
}

let AppearanceDidChange = Notification.Name("DevToolsAppearanceDidChange")

enum AppearancePrefs {
    private static let key = "devtools.appearance.mode"

    static func current() -> AppearanceMode {
        AppearanceMode(rawValue: UserDefaults.standard.integer(forKey: key)) ?? .system
    }

    static func set(_ mode: AppearanceMode) {
        UserDefaults.standard.set(mode.rawValue, forKey: key)
        NotificationCenter.default.post(name: AppearanceDidChange, object: nil)
    }
}
