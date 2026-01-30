import SwiftUI

extension Font {
    // Heading Fonts
    static let kundliLargeTitle = Font.system(size: 34, weight: .bold)
    static let kundliTitle = Font.system(size: 28, weight: .bold)
    static let kundliTitle2 = Font.system(size: 22, weight: .semibold)
    static let kundliTitle3 = Font.system(size: 20, weight: .semibold)

    // Body Fonts
    static let kundliHeadline = Font.system(size: 17, weight: .semibold)
    static let kundliBody = Font.system(size: 17, weight: .regular)
    static let kundliCallout = Font.system(size: 16, weight: .regular)
    static let kundliSubheadline = Font.system(size: 15, weight: .regular)

    // Small Fonts
    static let kundliFootnote = Font.system(size: 13, weight: .regular)
    static let kundliCaption = Font.system(size: 12, weight: .regular)
    static let kundliCaption2 = Font.system(size: 11, weight: .regular)

    // Special Fonts
    static let kundliSymbol = Font.system(size: 14, weight: .medium)
    static let kundliDegree = Font.system(size: 12, weight: .medium, design: .monospaced)
}

// MARK: - Text Styles
struct KundliTextStyle: ViewModifier {
    enum Style {
        case largeTitle
        case title
        case title2
        case title3
        case headline
        case body
        case callout
        case subheadline
        case footnote
        case caption
    }

    let style: Style
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundColor(color)
    }

    private var font: Font {
        switch style {
        case .largeTitle: return .kundliLargeTitle
        case .title: return .kundliTitle
        case .title2: return .kundliTitle2
        case .title3: return .kundliTitle3
        case .headline: return .kundliHeadline
        case .body: return .kundliBody
        case .callout: return .kundliCallout
        case .subheadline: return .kundliSubheadline
        case .footnote: return .kundliFootnote
        case .caption: return .kundliCaption
        }
    }
}

extension View {
    func kundliTextStyle(_ style: KundliTextStyle.Style, color: Color = .kundliTextPrimary) -> some View {
        modifier(KundliTextStyle(style: style, color: color))
    }
}
