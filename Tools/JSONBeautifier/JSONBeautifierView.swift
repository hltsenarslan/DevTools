import SwiftUI

struct JSONBeautifierView: View {
    @State private var input: String = "{\n  \"hello\":\"world\"\n}"
    @State private var output: String = ""
    @State private var error: String?
    @State private var indent: Int = 2

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("JSON Beautifier").font(.headline)
                Spacer()
                Stepper("Indent: \(indent)", value: $indent, in: 2...8)
                Button("Beautify") { beautify() }
                Button("Minify") { minify() }
                Button("Copy") { copyOut() }
            }
            .padding(.horizontal)

            HStack(spacing: 8) {
                TextEditor(text: $input)
                    .font(.system(.body, design: .monospaced))
                    .border(Color.gray.opacity(0.2))
                TextEditor(text: $output)
                    .font(.system(.body, design: .monospaced))
                    .border(Color.gray.opacity(0.2))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal)

            if let error {
                Text(error).foregroundColor(.red).padding(.bottom)
            }
        }
        .padding(.top)
        .onAppear { beautify() }
    }

    private func beautify() {
        error = nil
        guard let data = input.data(using: .utf8) else { error = "Invalid UTF-8"; return }
        do {
            let obj = try JSONSerialization.jsonObject(with: data)
            let opt = JSONSerialization.WritingOptions.prettyPrinted
            let dataOut = try JSONSerialization.data(withJSONObject: obj, options: opt)
            var text = String(decoding: dataOut, as: UTF8.self)
            // Replace default 2-space pretty print with custom indent
            if indent != 2 { text = reindent(text, spaces: indent) }
            output = text
        } catch { self.error = error.localizedDescription }
    }

    private func minify() {
        error = nil
        guard let data = input.data(using: .utf8) else { error = "Invalid UTF-8"; return }
        do {
            let obj = try JSONSerialization.jsonObject(with: data)
            let dataOut = try JSONSerialization.data(withJSONObject: obj, options: [])
            output = String(decoding: dataOut, as: UTF8.self)
        } catch { self.error = error.localizedDescription }
    }

    private func copyOut() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(output, forType: .string)
    }

    private func reindent(_ text: String, spaces: Int) -> String {
        let unit = String(repeating: " ", count: spaces)
        var result = ""
        var level = 0
        for line in text.split(separator: "\n", omittingEmptySubsequences: false) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.first == "}" || trimmed.first == "]" { level = max(0, level - 1) }
            result += String(repeating: unit, count: level) + trimmed + "\n"
            if trimmed.last == "{" || trimmed.last == "[" { level += 1 }
        }
        return result
    }
}