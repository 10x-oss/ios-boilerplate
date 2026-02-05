import SwiftUI

/// Button that shows loading state and disables interaction during async operations
struct LoadingButton<Label: View>: View {
    // MARK: - Properties

    let action: () async -> Void
    let label: () -> Label

    // MARK: - State

    @State private var isLoading = false

    // MARK: - Environment

    @Environment(\.isEnabled) private var isEnabled

    // MARK: - Initialization

    init(
        action: @escaping () async -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.action = action
        self.label = label
    }

    // MARK: - Body

    var body: some View {
        Button {
            guard !isLoading else { return }
            HapticService.shared.buttonTap()

            isLoading = true
            Task {
                await action()
                isLoading = false
            }
        } label: {
            ZStack {
                label()
                    .opacity(isLoading ? 0 : 1)

                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
        }
        .disabled(isLoading)
    }
}

// MARK: - Convenience Initializers

extension LoadingButton where Label == Text {
    /// Create a loading button with a text label
    init(
        _ title: String,
        action: @escaping () async -> Void
    ) {
        self.init(action: action) {
            Text(title)
        }
    }
}

// MARK: - Styled Loading Buttons

/// Primary styled loading button
struct PrimaryLoadingButton: View {
    let title: String
    let icon: String?
    let action: () async -> Void

    @State private var isLoading = false

    init(
        _ title: String,
        icon: String? = nil,
        action: @escaping () async -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        PrimaryButton(
            title: title,
            action: {
                guard !isLoading else { return }
                isLoading = true
                Task {
                    await action()
                    isLoading = false
                }
            },
            icon: icon,
            isLoading: isLoading
        )
        .disabled(isLoading)
    }
}

/// Secondary styled loading button
struct SecondaryLoadingButton: View {
    let title: String
    let icon: String?
    let action: () async -> Void

    @State private var isLoading = false

    init(
        _ title: String,
        icon: String? = nil,
        action: @escaping () async -> Void
    ) {
        self.title = title
        self.icon = icon
        self.action = action
    }

    var body: some View {
        SecondaryButton(
            title: title,
            action: {
                guard !isLoading else { return }
                isLoading = true
                Task {
                    await action()
                    isLoading = false
                }
            },
            icon: icon,
            isLoading: isLoading
        )
        .disabled(isLoading)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        PrimaryLoadingButton("Save Changes") {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }

        SecondaryLoadingButton("Refresh", icon: "arrow.clockwise") {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        }

        LoadingButton {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
        } label: {
            Label("Custom Button", systemImage: "star.fill")
        }
        .buttonStyle(.primary)
    }
    .padding()
}
