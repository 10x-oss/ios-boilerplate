import SwiftUI

/// Shimmer loading effect modifier
struct ShimmerModifier: ViewModifier {
    // MARK: - Properties

    let isActive: Bool
    let duration: Double
    let bounce: Bool

    // MARK: - State

    @State private var phase: CGFloat = 0

    // MARK: - Initialization

    init(isActive: Bool = true, duration: Double = 1.5, bounce: Bool = false) {
        self.isActive = isActive
        self.duration = duration
        self.bounce = bounce
    }

    // MARK: - Body

    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay(
                    shimmerOverlay
                        .mask(content)
                )
                .onAppear {
                    withAnimation(
                        .linear(duration: duration)
                            .repeatForever(autoreverses: bounce)
                    ) {
                        phase = 1
                    }
                }
        } else {
            content
        }
    }

    // MARK: - Private Views

    private var shimmerOverlay: some View {
        LinearGradient(
            colors: [
                Color.white.opacity(0.4),
                Color.white.opacity(0.8),
                Color.white.opacity(0.4)
            ],
            startPoint: .init(x: phase - 1, y: phase - 1),
            endPoint: .init(x: phase, y: phase)
        )
    }
}

// MARK: - View Extension

extension View {
    /// Apply a shimmer loading effect
    func shimmer(
        when active: Bool = true,
        duration: Double = 1.5,
        bounce: Bool = false
    ) -> some View {
        modifier(ShimmerModifier(isActive: active, duration: duration, bounce: bounce))
    }
}

// MARK: - Skeleton View

/// Skeleton placeholder view for loading states
struct SkeletonView: View {
    // MARK: - Properties

    let width: CGFloat?
    let height: CGFloat

    var cornerRadius: CGFloat = UIConstants.CornerRadius.medium

    // MARK: - Body

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.3))
            .frame(width: width, height: height)
            .shimmer()
    }
}

// MARK: - Skeleton Shapes

extension SkeletonView {
    /// Circle skeleton
    static func circle(size: CGFloat) -> some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: size, height: size)
            .shimmer()
    }

    /// Text line skeleton
    static func textLine(width: CGFloat? = nil, height: CGFloat = 14) -> SkeletonView {
        SkeletonView(width: width, height: height, cornerRadius: height / 2)
    }

    /// Rectangle skeleton
    static func rectangle(width: CGFloat? = nil, height: CGFloat, cornerRadius: CGFloat = UIConstants.CornerRadius.medium) -> SkeletonView {
        SkeletonView(width: width, height: height, cornerRadius: cornerRadius)
    }
}

// MARK: - List Item Skeleton

struct ListItemSkeletonView: View {
    var body: some View {
        HStack(spacing: UIConstants.Spacing.md) {
            SkeletonView.circle(size: 48)

            VStack(alignment: .leading, spacing: UIConstants.Spacing.sm) {
                SkeletonView.textLine(width: 150, height: 16)
                SkeletonView.textLine(width: 100, height: 12)
            }

            Spacer()
        }
        .padding(.vertical, UIConstants.Spacing.sm)
    }
}

// MARK: - Card Skeleton

struct CardSkeletonView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: UIConstants.Spacing.md) {
            SkeletonView.rectangle(height: 150)

            VStack(alignment: .leading, spacing: UIConstants.Spacing.sm) {
                SkeletonView.textLine(width: 200, height: 18)
                SkeletonView.textLine(height: 14)
                SkeletonView.textLine(width: 150, height: 14)
            }
        }
        .padding(UIConstants.Padding.card)
        .background(AppTheme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.CornerRadius.large))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        Text("Shimmer Effect")
            .padding()
            .background(Color.gray.opacity(0.3))
            .shimmer()

        Divider()

        SkeletonView(width: 200, height: 20)

        SkeletonView.circle(size: 60)

        ListItemSkeletonView()

        CardSkeletonView()
    }
    .padding()
}
