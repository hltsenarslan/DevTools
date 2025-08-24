// Views/Components/ToolRow.swift
import SwiftUI

struct ToolRow: View {
    let item: ToolItem
    @State private var hovering = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: item.icon ?? "square.grid.2x2")
                .font(.system(size: 16, weight: .medium))
            Text(item.name)
                .font(.body)
            Spacer()
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial.opacity(hovering ? 0.9 : 0.75))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.white.opacity(hovering ? 0.28 : 0.14), lineWidth: 1)
        )
        .animation(.easeOut(duration: 0.15), value: hovering)
        .onHover { hovering = $0 }
    }
}
