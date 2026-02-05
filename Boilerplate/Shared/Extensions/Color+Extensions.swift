import SwiftUI

// MARK: - Color Extensions

extension Color {
    // MARK: - Hex Initialization

    /// Initialize a Color from a hex string
    /// Supports formats: "RGB", "RRGGBB", "#RGB", "#RRGGBB", "RRGGBBAA", "#RRGGBBAA"
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RRGGBB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // RRGGBBAA (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// Convert color to hex string
    var hexString: String? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)

        if components.count >= 4, components[3] < 1 {
            let a = Int(components[3] * 255)
            return String(format: "#%02X%02X%02X%02X", r, g, b, a)
        }

        return String(format: "#%02X%02X%02X", r, g, b)
    }

    // MARK: - RGBA Initialization

    /// Initialize a Color from RGB values (0-255)
    init(red: Int, green: Int, blue: Int, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: alpha
        )
    }

    // MARK: - Color Manipulation

    /// Lighten the color by a percentage (0-1)
    func lighter(by percentage: CGFloat = 0.2) -> Color {
        adjust(by: abs(percentage))
    }

    /// Darken the color by a percentage (0-1)
    func darker(by percentage: CGFloat = 0.2) -> Color {
        adjust(by: -abs(percentage))
    }

    private func adjust(by percentage: CGFloat) -> Color {
        let uiColor = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0

        guard uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
            return self
        }

        let newBrightness = max(min(b + percentage, 1.0), 0.0)
        return Color(hue: h, saturation: s, brightness: newBrightness, opacity: a)
    }

    /// Return a contrasting color (black or white)
    var contrastingColor: Color {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0

        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else {
            return .black
        }

        // Calculate luminance using the WCAG formula
        let luminance = 0.299 * r + 0.587 * g + 0.114 * b
        return luminance > 0.5 ? .black : .white
    }

    // MARK: - Opacity

    /// Return the color with modified opacity
    func opacity(_ value: Double) -> Color {
        self.opacity(value)
    }

    // MARK: - Random

    /// Generate a random color
    static var random: Color {
        Color(
            red: .random(in: 0 ... 1),
            green: .random(in: 0 ... 1),
            blue: .random(in: 0 ... 1)
        )
    }

    /// Generate a random pastel color
    static var randomPastel: Color {
        Color(
            hue: .random(in: 0 ... 1),
            saturation: 0.3,
            brightness: 0.9
        )
    }
}

// MARK: - Semantic Colors

extension Color {
    /// Semantic color for success states
    static let success = Color.green

    /// Semantic color for warning states
    static let warning = Color.orange

    /// Semantic color for error states
    static let error = Color.red

    /// Semantic color for info states
    static let info = Color.blue

    /// Primary background color
    static let primaryBackground = Color(uiColor: .systemBackground)

    /// Secondary background color
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)

    /// Tertiary background color
    static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)

    /// Primary text color
    static let primaryText = Color(uiColor: .label)

    /// Secondary text color
    static let secondaryText = Color(uiColor: .secondaryLabel)

    /// Placeholder text color
    static let placeholderText = Color(uiColor: .placeholderText)

    /// Separator color
    static let separator = Color(uiColor: .separator)
}
