import SwiftUI

struct ToolRow: View {
    let item: ToolItem
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: item.icon ?? "square.grid.2x2")
            Text(item.name)
            Spacer()
        }
        .padding(8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}