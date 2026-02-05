import SwiftUI

/// App theme configuration for colors and typography
enum AppTheme {
    // MARK: - Colors

    enum Colors {
        // Brand colors
        static let primary = Color.accentColor
        static let secondary = Color.secondary

        // Background colors
        static let background = Color(uiColor: .systemBackground)
        static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
        static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
        static let groupedBackground = Color(uiColor: .systemGroupedBackground)

        // Text colors
        static let text = Color(uiColor: .label)
        static let secondaryText = Color(uiColor: .secondaryLabel)
        static let tertiaryText = Color(uiColor: .tertiaryLabel)
        static let quaternaryText = Color(uiColor: .quaternaryLabel)
        static let placeholderText = Color(uiColor: .placeholderText)

        // Semantic colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue

        // UI element colors
        static let separator = Color(uiColor: .separator)
        static let opaqueSeparator = Color(uiColor: .opaqueSeparator)
        static let link = Color(uiColor: .link)
        static let tint = Color(uiColor: .tintColor)

        // Fill colors
        static let fill = Color(uiColor: .systemFill)
        static let secondaryFill = Color(uiColor: .secondarySystemFill)
        static let tertiaryFill = Color(uiColor: .tertiarySystemFill)
        static let quaternaryFill = Color(uiColor: .quaternarySystemFill)
    }

    // MARK: - Typography

    enum Typography {
        // Title styles
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.semibold)

        // Body styles
        static let headline = Font.headline
        static let body = Font.body
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption = Font.caption
        static let caption2 = Font.caption2

        // Custom styles
        static let buttonLabel = Font.body.weight(.semibold)
        static let smallButtonLabel = Font.subheadline.weight(.medium)
        static let sectionHeader = Font.footnote.weight(.semibold)
        static let listItem = Font.body
        static let badge = Font.caption.weight(.semibold)
    }

    // MARK: - Gradients

    enum Gradients {
        static let primary = LinearGradient(
            colors: [Colors.primary, Colors.primary.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let accent = LinearGradient(
            colors: [.blue, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let success = LinearGradient(
            colors: [.green, .green.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let warning = LinearGradient(
            colors: [.orange, .yellow],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let error = LinearGradient(
            colors: [.red, .red.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let shimmer = LinearGradient(
            colors: [
                Color.gray.opacity(0.3),
                Color.gray.opacity(0.1),
                Color.gray.opacity(0.3)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: - Shadows

    enum Shadows {
        static func small(_ colorScheme: ColorScheme) -> some View {
            EmptyView()
                .shadow(
                    color: colorScheme == .dark ? .clear : .black.opacity(0.08),
                    radius: 2,
                    x: 0,
                    y: 1
                )
        }

        static func medium(_ colorScheme: ColorScheme) -> some View {
            EmptyView()
                .shadow(
                    color: colorScheme == .dark ? .clear : .black.opacity(0.1),
                    radius: 4,
                    x: 0,
                    y: 2
                )
        }

        static func large(_ colorScheme: ColorScheme) -> some View {
            EmptyView()
                .shadow(
                    color: colorScheme == .dark ? .clear : .black.opacity(0.15),
                    radius: 8,
                    x: 0,
                    y: 4
                )
        }
    }
}

// MARK: - Color Scheme Support

extension AppTheme.Colors {
    /// Get the appropriate color for the current color scheme
    static func adaptive(light: Color, dark: Color) -> Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}
