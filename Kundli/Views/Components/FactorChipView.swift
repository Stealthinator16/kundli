import SwiftUI

struct FactorChipView: View {
    let text: String
    let icon: String
    var accentColor: Color = .kundliPrimary

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(text)
                .font(.system(size: 11))
        }
        .foregroundColor(accentColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(accentColor.opacity(0.15))
        )
    }
}
