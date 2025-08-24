import SwiftUI

struct RegexTesterView: View {
    @State private var pattern = ""
    @State private var sample = ""
    @State private var matches: [NSTextCheckingResult] = []
    @State private var error: String?
    @State private var options = Options()

    struct Options {
        var caseInsensitive = true
        var anchorsMatchLines = true
        var dotMatchesLineSeparators = false
    }

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Regex Tester").font(.headline)
                Spacer()
                Toggle("i", isOn: $options.caseInsensitive)
                Toggle("m (^$=line)", isOn: $options.anchorsMatchLines)
                Toggle("s (dotall)", isOn: $options.dotMatchesLineSeparators)
                Button("Run") { run() }
            }.padding(.horizontal)

            TextField("Pattern (NSRegularExpression)", text: $pattern)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal)

            HStack {
                TextEditor(text: $sample).font(.system(.body, design: .monospaced))
                List(matches.indices, id: \.self) { i in
                    let m = matches[i]
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Match \(i + 1) range: \(m.range.location)–\(m.range.location + m.range.length)")
                            .font(.subheadline).bold()
                        ForEach(0 ..< m.numberOfRanges, id: \.self) { g in
                            let r = m.range(at: g)
                            if r.location != NSNotFound, let s = substring(sample, r) {
                                Text("(\(g)) \(s)")
                                    .font(.system(.body, design: .monospaced))
                            }
                        }
                    }
                }.frame(minWidth: 320)
            }.border(.gray.opacity(0.2))

            if let e = error { Text(e).foregroundStyle(.red) }
        }.padding()
    }

    private func run() {
        error = nil; matches = []
        var opts: NSRegularExpression.Options = []
        if options.caseInsensitive { opts.insert(.caseInsensitive) }
        if options.anchorsMatchLines { opts.insert(.anchorsMatchLines) }
        if options.dotMatchesLineSeparators { opts.insert(.dotMatchesLineSeparators) }
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: opts)
            let range = NSRange(sample.startIndex ..< sample.endIndex, in: sample)
            matches = regex.matches(in: sample, options: [], range: range)
        } catch {
            self.error = error.localizedDescription
        }
    }

    private func substring(_ s: String, _ r: NSRange) -> String? {
        guard let rr = Range(r, in: s) else { return nil }
        return String(s[rr])
    }
}
