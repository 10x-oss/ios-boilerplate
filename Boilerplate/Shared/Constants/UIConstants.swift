import SwiftUI

/// UI layout and styling constants
enum UIConstants {
    // MARK: - Spacing

    enum Spacing {
        /// Extra small spacing (4pt)
        static let xs: CGFloat = 4

        /// Small spacing (8pt)
        static let sm: CGFloat = 8

        /// Medium spacing (16pt)
        static let md: CGFloat = 16

        /// Large spacing (24pt)
        static let lg: CGFloat = 24

        /// Extra large spacing (32pt)
        static let xl: CGFloat = 32

        /// Extra extra large spacing (48pt)
        static let xxl: CGFloat = 48
    }

    // MARK: - Padding

    enum Padding {
        /// Standard horizontal padding
        static let horizontal: CGFloat = 16

        /// Standard vertical padding
        static let vertical: CGFloat = 12

        /// Card padding
        static let card: CGFloat = 16

        /// Section padding
        static let section: CGFloat = 20

        /// Edge insets for standard content
        static let standard = EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16)

        /// Edge insets for card content
        static let cardInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        /// Small corner radius (4pt)
        static let small: CGFloat = 4

        /// Medium corner radius (8pt)
        static let medium: CGFloat = 8

        /// Large corner radius (12pt)
        static let large: CGFloat = 12

        /// Extra large corner radius (16pt)
        static let extraLarge: CGFloat = 16

        /// Pill shape corner radius (very large)
        static let pill: CGFloat = 50
    }

    // MARK: - Button Sizes

    enum ButtonSize {
        /// Small button height
        static let small: CGFloat = 36

        /// Medium button height
        static let medium: CGFloat = 44

        /// Large button height
        static let large: CGFloat = 52

        /// Icon button size
        static let icon: CGFloat = 44
    }

    // MARK: - Font Sizes

    enum FontSize {
        /// Caption font size
        static let caption: CGFloat = 12

        /// Footnote font size
        static let footnote: CGFloat = 13

        /// Body font size
        static let body: CGFloat = 17

        /// Headline font size
        static let headline: CGFloat = 17

        /// Title 3 font size
        static let title3: CGFloat = 20

        /// Title 2 font size
        static let title2: CGFloat = 22

        /// Title 1 font size
        static let title1: CGFloat = 28

        /// Large title font size
        static let largeTitle: CGFloat = 34
    }

    // MARK: - Icon Sizes

    enum IconSize {
        /// Small icon size
        static let small: CGFloat = 16

        /// Medium icon size
        static let medium: CGFloat = 24

        /// Large icon size
        static let large: CGFloat = 32

        /// Extra large icon size
        static let extraLarge: CGFloat = 48

        /// Navigation bar icon size
        static let navBar: CGFloat = 22

        /// Tab bar icon size
        static let tabBar: CGFloat = 24
    }

    // MARK: - Shadow

    enum Shadow {
        /// Small shadow radius
        static let small: CGFloat = 2

        /// Medium shadow radius
        static let medium: CGFloat = 4

        /// Large shadow radius
        static let large: CGFloat = 8

        /// Shadow color
        static let color = Color.black.opacity(0.1)

        /// Shadow offset
        static let offset = CGSize(width: 0, height: 2)
    }

    // MARK: - Border

    enum Border {
        /// Thin border width
        static let thin: CGFloat = 0.5

        /// Standard border width
        static let standard: CGFloat = 1

        /// Thick border width
        static let thick: CGFloat = 2
    }

    // MARK: - Avatar Sizes

    enum AvatarSize {
        /// Small avatar (24pt)
        static let small: CGFloat = 24

        /// Medium avatar (40pt)
        static let medium: CGFloat = 40

        /// Large avatar (64pt)
        static let large: CGFloat = 64

        /// Extra large avatar (96pt)
        static let extraLarge: CGFloat = 96
    }

    // MARK: - Thumbnail Sizes

    enum ThumbnailSize {
        /// Small thumbnail
        static let small = CGSize(width: 60, height: 60)

        /// Medium thumbnail
        static let medium = CGSize(width: 100, height: 100)

        /// Large thumbnail
        static let large = CGSize(width: 150, height: 150)
    }

    // MARK: - Hit Area

    enum HitArea {
        /// Minimum tappable area (44pt as per Apple HIG)
        static let minimum: CGFloat = 44
    }
}
