// Views/TopPanelView.swift
import SwiftUI

struct TopPanelView: View {
    enum Action { case openBuiltin(String), openURL(URL), quit }
    let onSelect: (Action) -> Void

    @State private var manifest = ManifestSource.load()
    @State private var search = ""
    @State private var appearance = AppearancePrefs.current()
    @FocusState private var searchFocused: Bool

    var body: some View {
        VStack(spacing: 12) {
            // Başlık
            HStack(spacing: 10) {
                Image(systemName: "hammer.circle.fill")
                    .font(.system(size: 22, weight: .semibold))
                Text("DevTools").font(.title3).bold()
                Spacer()

                Picker("", selection: $appearance) {
                    Image(systemName: "aqi.medium").tag(AppearanceMode.system) // System
                    Image(systemName: "sun.max").tag(AppearanceMode.light) // Light
                    Image(systemName: "moon").tag(AppearanceMode.dark) // Dark
                }
                .pickerStyle(.segmented)
                .controlSize(.small)
                .frame(width: 140)
                .onChange(of: appearance) { AppearancePrefs.set($0) }

                Button("Quit") { onSelect(.quit) }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.small)
            }
            .padding(.top, 8)
            .padding(.horizontal, 12)
            .tint(Color(nsColor: .controlAccentColor))

            // Arama
            TextField("Search tools", text: $search)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 12)
                .focused($searchFocused)
                .onSubmit {
                    if let first = filtered(manifest.tools).first {
                        switch first.type {
                        case .builtin: onSelect(.openBuiltin(first.id))
                        case .url: if let u = first.url { onSelect(.openURL(u)) }
                        }
                    }
                }

            // Liste (tam genişlik)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(filtered(manifest.tools)) { tool in
                        Button {
                            switch tool.type {
                            case .builtin: onSelect(.openBuiltin(tool.id))
                            case .url: if let url = tool.url { onSelect(.openURL(url)) }
                            }
                        } label: {
                            ToolRow(item: tool)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 12)
                    }
                }
                .padding(.vertical, 6)
            }
        }
        .padding(.bottom, 10)
        // SwiftUI tarafında da blur + radius; NSPanel’de zaten var ama bu, içerik stilini tamamlar
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { // view hiyerarşisi kurulduktan hemen sonra

                searchFocused = false
            }
        }
    }

    private func filtered(_ items: [ToolItem]) -> [ToolItem] {
        let s = search.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(s) || $0.id.localizedCaseInsensitiveContains(s) }
    }
}
