import SwiftUI

struct Base64CoderView: View {
    @State private var input = ""
    @State private var output = ""
    @State private var urlSafe = false
    @State private var wrapLines = false
    @State private var error: String?

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Base64 Coder").font(.headline)
                Spacer()
                Toggle("URL-safe", isOn: $urlSafe)
                Toggle("Wrap 76", isOn: $wrapLines)
                Button("Encode") { encode() }
                Button("Decode") { decode() }
                Button("Copy") { copy() }
            }.padding(.horizontal)

            HStack(spacing: 8) {
                TextEditor(text: $input).font(.system(.body, design: .monospaced))
                TextEditor(text: $output).font(.system(.body, design: .monospaced))
            }.border(.gray.opacity(0.2))

            if let e = error { Text(e).foregroundStyle(.red) }
        }
        .padding()
    }

    private func encode() {
        error = nil
        let data = input.data(using: .utf8) ?? Data()
        var b64 = data.base64EncodedString()
        if urlSafe { b64 = b64.replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_") }
        if wrapLines {
            b64 = stride(from: 0, to: b64.count, by: 76).map { i in
                let start = b64.index(b64.startIndex, offsetBy: i)
                let end = b64.index(start, offsetBy: min(76, b64.distance(from: start, to: b64.endIndex)), limitedBy: b64.endIndex) ?? b64.endIndex
                return String(b64[start ..< end])
            }.joined(separator: "\n")
        }
        output = b64
    }

    private func decode() {
        error = nil
        var s = input.replacingOccurrences(of: "\n", with: "")
        if urlSafe { s = s.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/") }
        guard let data = Data(base64Encoded: s) else { error = "Invalid Base64"; return }
        output = String(decoding: data, as: UTF8.self)
    }

    private func copy() { NSPasteboard.general.clearContents(); NSPasteboard.general.setString(output, forType: .string) }
}
