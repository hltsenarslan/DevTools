import Carbon.HIToolbox
import Cocoa

enum GlobalHotKey {
    typealias Handler = () -> Void
    private static var hotKeyRef: EventHotKeyRef?
    private static var eventHandlerRef: EventHandlerRef?
    private static var handler: Handler?

    /// Register a global hotkey. Defaults to Control+Option+Command+T
    static func register(
        keyCode: UInt32 = UInt32(kVK_Space),
        modifiers: UInt32 = UInt32(controlKey | optionKey | cmdKey),
        handler: @escaping Handler
    ) {
        unregister()
        Self.handler = handler

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let status = InstallEventHandler(
            GetEventDispatcherTarget(),
            { _, event, _ -> OSStatus in
                var hkID = EventHotKeyID()
                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hkID
                )
                if hkID.id == 1 {
                    DispatchQueue.main.async {
                        GlobalHotKey.handler?()
                    }
                }
                return noErr
            },
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )
        guard status == noErr else { return }

        var hotKeyID = EventHotKeyID(
            signature: OSType(UInt32(truncatingIfNeeded: "DTLS".hashValue)),
            id: 1
        )

        RegisterEventHotKey(
            keyCode,
            modifiers, // already UInt32
            hotKeyID,
            GetEventDispatcherTarget(),
            0,
            &hotKeyRef
        )
    }

    static func unregister() {
        if let hk = hotKeyRef { UnregisterEventHotKey(hk) }
        if let eh = eventHandlerRef { RemoveEventHandler(eh) }
        hotKeyRef = nil
        eventHandlerRef = nil
        handler = nil
    }
}
