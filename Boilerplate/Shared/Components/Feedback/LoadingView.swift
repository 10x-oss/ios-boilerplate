import SwiftUI

/// Loading indicator view with optional message
struct LoadingView: View {
    // MARK: - Properties

    var message: String?
    var style: LoadingStyle = .spinner

    // MARK: - Body

    var body: some View {
        VStack(spacing: UIConstants.Spacing.md) {
            switch style {
            case .spinner:
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.5)

            case .dots:
                DotsLoadingView()

            case .pulse:
                PulseLoadingView()
            }

            if let message {
                Text(message)
                    .font(AppTheme.Typography.subheadline)
                    .foregroundStyle(AppTheme.Colors.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Loading Style

    enum LoadingStyle {
        case spinner
        case dots
        case pulse
    }
}

// MARK: - Dots Loading View

private struct DotsLoadingView: View {
    @State private var animatingIndex = 0

    private let dotCount = 3
    private let dotSize: CGFloat = 10

    var body: some View {
        HStack(spacing: UIConstants.Spacing.sm) {
            ForEach(0 ..< dotCount, id: \.self) { index in
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: dotSize, height: dotSize)
                    .scaleEffect(animatingIndex == index ? 1.3 : 1.0)
                    .opacity(animatingIndex == index ? 1.0 : 0.5)
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                animatingIndex = (animatingIndex + 1) % dotCount
            }
        }
    }
}

// MARK: - Pulse Loading View

private struct PulseLoadingView: View {
    @State private var isPulsing = false

    var body: some View {
        Circle()
            .fill(Color.accentColor.opacity(0.5))
            .frame(width: 50, height: 50)
            .scaleEffect(isPulsing ? 1.5 : 1.0)
            .opacity(isPulsing ? 0 : 1)
            .animation(
                .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: false),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - Loading Overlay Modifier

struct LoadingOverlayModifier: ViewModifier {
    let isLoading: Bool
    let message: String?

    func body(content: Content) -> some View {
        content
            .overlay {
                if isLoading {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()

                        LoadingView(message: message)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: UIConstants.CornerRadius.large)
                                    .fill(AppTheme.Colors.background)
                            )
                            .shadow(radius: 10)
                    }
                }
            }
    }
}

extension View {
    /// Show a loading overlay when loading is true
    func loadingOverlay(_ isLoading: Bool, message: String? = nil) -> some View {
        modifier(LoadingOverlayModifier(isLoading: isLoading, message: message))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 32) {
        LoadingView(message: "Loading...", style: .spinner)
            .frame(height: 100)

        LoadingView(message: "Please wait", style: .dots)
            .frame(height: 100)

        LoadingView(style: .pulse)
            .frame(height: 100)
    }
}
