import SwiftUI

/// Error display view with retry option
struct ErrorView: View {
    // MARK: - Properties

    let error: Error
    var onRetry: (() -> Void)?

    // MARK: - Body

    var body: some View {
        VStack(spacing: UIConstants.Spacing.lg) {
            Spacer()

            // Icon
            Image(systemName: iconName)
                .font(.system(size: 64))
                .foregroundStyle(iconColor)

            // Text
            VStack(spacing: UIConstants.Spacing.sm) {
                Text(title)
                    .font(AppTheme.Typography.headline)
                    .foregroundStyle(AppTheme.Colors.text)

                Text(message)
                    .font(AppTheme.Typography.body)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)

                if let suggestion {
                    Text(suggestion)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.tertiaryText)
                        .multilineTextAlignment(.center)
                        .padding(.top, UIConstants.Spacing.xs)
                }
            }

            // Retry button
            if let onRetry, isRecoverable {
                PrimaryButton(title: "Try Again", action: onRetry, isFullWidth: false)
                    .padding(.top, UIConstants.Spacing.md)
            }

            Spacer()
        }
        .padding(UIConstants.Padding.section)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Computed Properties

    private var title: String {
        if let apiError = error as? APIError {
            return apiError.errorTitle
        }
        return "Something Went Wrong"
    }

    private var message: String {
        error.localizedDescription
    }

    private var suggestion: String? {
        if let apiError = error as? APIError {
            return apiError.suggestedAction
        }
        return nil
    }

    private var iconName: String {
        if let apiError = error as? APIError {
            return apiError.iconName
        }
        return "exclamationmark.triangle.fill"
    }

    private var iconColor: Color {
        if let apiError = error as? APIError {
            return apiError.iconColor
        }
        return .orange
    }

    private var isRecoverable: Bool {
        if let apiError = error as? APIError {
            return apiError.isRecoverable
        }
        return true
    }
}

// MARK: - APIError Extensions

private extension APIError {
    var errorTitle: String {
        switch self {
        case .networkUnavailable:
            return "No Connection"
        case .unauthorized:
            return "Session Expired"
        case .forbidden:
            return "Access Denied"
        case .notFound:
            return "Not Found"
        case .rateLimited:
            return "Too Many Requests"
        case .serverError:
            return "Server Error"
        case .timeout:
            return "Request Timeout"
        default:
            return "Error"
        }
    }

    var iconName: String {
        switch self {
        case .networkUnavailable:
            return "wifi.slash"
        case .unauthorized:
            return "person.crop.circle.badge.exclamationmark"
        case .forbidden:
            return "lock.fill"
        case .notFound:
            return "questionmark.folder"
        case .rateLimited:
            return "clock.badge.exclamationmark"
        case .serverError:
            return "server.rack"
        case .timeout:
            return "clock"
        default:
            return "exclamationmark.triangle.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .networkUnavailable:
            return .gray
        case .unauthorized, .forbidden:
            return .orange
        case .notFound:
            return .blue
        case .rateLimited:
            return .purple
        case .serverError:
            return .red
        default:
            return .orange
        }
    }
}

// MARK: - Inline Error Banner

struct ErrorBanner: View {
    let message: String
    var onDismiss: (() -> Void)?

    var body: some View {
        HStack(spacing: UIConstants.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.white)

            Text(message)
                .font(AppTheme.Typography.subheadline)
                .foregroundStyle(.white)
                .lineLimit(2)

            Spacer()

            if let onDismiss {
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                }
            }
        }
        .padding(UIConstants.Spacing.md)
        .background(Color.red)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.CornerRadius.medium))
    }
}

// MARK: - Preview

#Preview {
    ErrorView(error: APIError.networkUnavailable) {
        print("Retry tapped")
    }
}

#Preview("Server Error") {
    ErrorView(error: APIError.serverError(statusCode: 500, message: "Internal server error")) {
        print("Retry tapped")
    }
}

#Preview("Error Banner") {
    VStack {
        ErrorBanner(message: "Failed to save changes") {
            print("Dismissed")
        }
        .padding()

        Spacer()
    }
}
