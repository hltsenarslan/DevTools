import SwiftUI

struct JWTInspectorView: View {
    @State private var token = ""
    @State private var header = ""
    @State private var payload = ""
    @State private var error: String?

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("JWT Inspector").font(.headline)
                Spacer()
                Button("Decode") { decode() }
                Button("Copy Payload") { copy(payload) }
            }.padding(.horizontal)

            TextField("Paste JWT here", text: $token)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal)

            HStack {
                VStack(alignment: .leading) {
                    Text("Header").font(.subheadline).bold()
                    TextEditor(text: $header).font(.system(.body, design: .monospaced)).frame(minHeight: 150)
                }
                VStack(alignment: .leading) {
                    Text("Payload").font(.subheadline).bold()
                    TextEditor(text: $payload).font(.system(.body, design: .monospaced)).frame(minHeight: 150)
                }
            }.padding(.horizontal)

            if let e = error { Text(e).foregroundStyle(.red) }
            Spacer()
        }.padding(.top, 8)
    }

    private func decode() {
        error = nil; header = ""; payload = ""
        let parts = token.split(separator: ".")
        guard parts.count >= 2 else { error = "Invalid JWT format"; return }
        func decodePart(_ s: Substring) -> String? {
            var base64 = String(s).replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
            let pad = 4 - (base64.count % 4)
            if pad < 4 { base64 += String(repeating: "=", count: pad) }
            guard let data = Data(base64Encoded: base64) else { return nil }
            return String(decoding: data, as: UTF8.self)
        }
        guard let h = decodePart(parts[0]), let p = decodePart(parts[1]) else { error = "Base64 decode failed"; return }
        header = pretty(h) ?? h
        payload = pretty(p) ?? p
    }

    private func pretty(_ json: String) -> String? {
        guard let data = json.data(using: .utf8) else { return nil }
        guard let obj = try? JSONSerialization.jsonObject(with: data) else { return nil }
        let out = try! JSONSerialization.data(withJSONObject: obj, options: [.prettyPrinted, .sortedKeys])
        return String(decoding: out, as: UTF8.self)
    }

    private func copy(_ s: String) { NSPasteboard.general.clearContents(); NSPasteboard.general.setString(s, forType: .string) }
}
