import SwiftUI

struct URLCoderView: View {
    @State private var input = ""
    @State private var output = ""
    @State private var plusAsSpace = false
    @State private var error: String?

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("URL Encoder/Decoder").font(.headline)
                Spacer()
                Toggle("+ as space", isOn: $plusAsSpace)
                Button("Encode") { encode() }
                Button("Decode") { decode() }
                Button("Copy") { copy() }
            }.padding(.horizontal)

            HStack {
                TextEditor(text: $input).font(.system(.body, design: .monospaced))
                TextEditor(text: $output).font(.system(.body, design: .monospaced))
            }.border(.gray.opacity(0.2))
            if let e = error { Text(e).foregroundStyle(.red) }
        }.padding()
    }

    private func encode() {
        error = nil
        if plusAsSpace {
            output = input.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)?
                .replacingOccurrences(of: " ", with: "+") ?? ""
        } else {
            output = input.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        }
    }

    private func decode() {
        error = nil
        var s = input
        if plusAsSpace { s = s.replacingOccurrences(of: "+", with: " ") }
        output = s.removingPercentEncoding ?? { error = "Invalid percent encoding"; return "" }()
    }

    private func copy() { NSPasteboard.general.clearContents(); NSPasteboard.general.setString(output, forType: .string) }
}
