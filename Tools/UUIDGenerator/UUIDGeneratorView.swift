import SwiftUI

struct UUIDGeneratorView: View {
    @State private var count = 10
    @State private var hyphens = true
    @State private var uppers = false
    @State private var items: [String] = []

    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Generate").font(.headline)
                Spacer()
                Stepper("Count: \(count)", value: $count, in: 1 ... 100)
                Toggle("Hyphens", isOn: $hyphens)
                Toggle("Uppercase", isOn: $uppers)
                Button("Generate") { generate() }
                Button("Copy All") { copyAll() }
            }.padding(.horizontal)

            List(items, id: \.self) { s in
                HStack {
                    Text(s).font(.system(.body, design: .monospaced))
                    Spacer()
                    Button("Copy") { copy(s) }.buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(.top, 8)
        .onAppear { generate() }
    }

    private func generate() {
        items = (0 ..< count).map { _ in
            var s = UUID().uuidString
            if !hyphens { s.removeAll(where: { $0 == "-" }) }
            if uppers { s = s.uppercased() } else { s = s.lowercased() }
            return s
        }
    }

    private func copy(_ s: String) { NSPasteboard.general.clearContents(); NSPasteboard.general.setString(s, forType: .string) }
    private func copyAll() { copy(items.joined(separator: "\n")) }
}
