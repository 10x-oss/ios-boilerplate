import SwiftUI

/// Empty state placeholder view
struct EmptyStateView: View {
    // MARK: - Properties

    let icon: String
    let title: String
    let message: String

    var actionTitle: String?
    var action: (() -> Void)?

    // MARK: - Body

    var body: some View {
        VStack(spacing: UIConstants.Spacing.lg) {
            Spacer()

            // Icon
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundStyle(AppTheme.Colors.tertiaryText)

            // Text
            VStack(spacing: UIConstants.Spacing.sm) {
                Text(title)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(AppTheme.Colors.text)

                Text(message)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
            }

            // Action button
            if let actionTitle, let action {
                PrimaryButton(title: actionTitle, action: action, isFullWidth: false)
                    .padding(.top, UIConstants.Spacing.md)
            }

            Spacer()
        }
        .padding(UIConstants.Padding.section)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Predefined Empty States

extension EmptyStateView {
    /// No items in a list
    static func noItems(
        itemName: String = "items",
        actionTitle: String? = "Add \(String(describing: "items"))",
        action: (() -> Void)? = nil
    ) -> EmptyStateView {
        EmptyStateView(
            icon: "tray",
            title: "No \(itemName)",
            message: "You don't have any \(itemName) yet.",
            actionTitle: actionTitle,
            action: action
        )
    }

    /// No search results
    static func noSearchResults(query: String) -> EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results",
            message: "No results found for \"\(query)\". Try a different search term."
        )
    }

    /// No network connection
    static func noConnection(retryAction: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "wifi.slash",
            title: "No Connection",
            message: "Please check your internet connection and try again.",
            actionTitle: "Retry",
            action: retryAction
        )
    }

    /// Generic error state
    static func error(message: String, retryAction: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "exclamationmark.triangle",
            title: "Something Went Wrong",
            message: message,
            actionTitle: "Try Again",
            action: retryAction
        )
    }

    /// Coming soon feature
    static func comingSoon(featureName: String) -> EmptyStateView {
        EmptyStateView(
            icon: "hammer",
            title: "Coming Soon",
            message: "\(featureName) is coming soon. Stay tuned!"
        )
    }

    /// Access denied
    static func accessDenied(reason: String) -> EmptyStateView {
        EmptyStateView(
            icon: "lock.fill",
            title: "Access Denied",
            message: reason
        )
    }
}

// MARK: - Preview

#Preview {
    VStack {
        EmptyStateView(
            icon: "doc.text",
            title: "No Documents",
            message: "Create your first document to get started.",
            actionTitle: "Create Document"
        ) {
            print("Create tapped")
        }
    }
}

#Preview("No Search Results") {
    EmptyStateView.noSearchResults(query: "test query")
}

#Preview("Error State") {
    EmptyStateView.error(message: "Failed to load data.") {
        print("Retry tapped")
    }
}
