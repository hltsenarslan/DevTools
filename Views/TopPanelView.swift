import SwiftUI

struct TopPanelView: View {
    enum Action { case openBuiltin(String), openURL(URL), quit }
    let onSelect: (Action) -> Void

    @State private var manifest = ManifestSource.load()
    @State private var search = ""

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(alignment: .leading, spacing: 8) {
                Text("DevTools").font(.title3).bold().padding(.horizontal)
                TextField("Search tools", text: $search)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 6) {
                        ForEach(filtered(manifest.tools)) { tool in
                            Button {
                                switch tool.type {
                                case .builtin: onSelect(.openBuiltin(tool.id))
                                case .url: if let url = tool.url { onSelect(.openURL(url)) }
                                }
                            } label: { ToolRow(item: tool) }
                                .buttonStyle(.plain)
                                .padding(.horizontal)
                        }
                    }.padding(.vertical)
                }
                Divider()
                HStack {
                    Spacer()
                    Button("Quit") { onSelect(.quit) }
                        .buttonStyle(.bordered)
                        .padding(.trailing)
                }
            }
            .frame(width: 240)
            .background(.thinMaterial)

            // Right area (branding / tips)
            ZStack {
                VStack(spacing: 14) {
                    Image(systemName: "hammer.circle.fill").font(.system(size: 56))
                    Text("Select a tool from the left").font(.headline)
                    Text("Tools are managed by a manifest file for easy add/remove.")
                        .font(.callout).foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(12)
        .background(.ultraThinMaterial)
    }

    private func filtered(_ items: [ToolItem]) -> [ToolItem] {
        let s = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(s) || $0.id.localizedCaseInsensitiveContains(s) }
    }
}
