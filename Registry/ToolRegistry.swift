import AppKit

enum ToolRegistry {
    static func openBuiltin(id: String) {
        switch id {
        case "system_info":
            SystemInfoWindowController.shared.show()
        case "json_beautifier":
            JSONBeautifierWindowController.shared.show()
        case "uuid_generator":
            UUIDGeneratorWindowController.shared.show()
        case "base64_coder":
            Base64CoderWindowController.shared.show()
        case "jwt_inspector":
            JWTInspectorWindowController.shared.show()
        case "url_coder":
            URLCoderWindowController.shared.show()
        case "regex_tester":
            RegexTesterWindowController.shared.show()
        default:
            NSSound.beep()
        }
    }
}
