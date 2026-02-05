import SwiftUI

// MARK: - Conditional Modifiers

extension View {
    /// Apply a modifier conditionally
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// Apply a modifier conditionally with else clause
    @ViewBuilder
    func `if`<TrueContent: View, FalseContent: View>(
        _ condition: Bool,
        then trueTransform: (Self) -> TrueContent,
        else falseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }

    /// Apply a modifier if a value is non-nil
    @ViewBuilder
    func ifLet<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
}

// MARK: - Frame Modifiers

extension View {
    /// Fill the available width
    func fillWidth(alignment: Alignment = .center) -> some View {
        frame(maxWidth: .infinity, alignment: alignment)
    }

    /// Fill the available height
    func fillHeight(alignment: Alignment = .center) -> some View {
        frame(maxHeight: .infinity, alignment: alignment)
    }

    /// Fill the available space
    func fillSpace(alignment: Alignment = .center) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
}

// MARK: - Navigation Modifiers

extension View {
    /// Hide the navigation bar
    func hideNavigationBar() -> some View {
        navigationBarHidden(true)
    }

    /// Set inline navigation bar title
    func inlineNavigationTitle(_ title: String) -> some View {
        navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Keyboard Modifiers

extension View {
    /// Hide keyboard on tap
    func hideKeyboardOnTap() -> some View {
        onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}

// MARK: - Styling Modifiers

extension View {
    /// Apply card styling
    func card(
        backgroundColor: Color = .secondaryBackground,
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 4
    ) -> some View {
        background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(color: .black.opacity(0.1), radius: shadowRadius, x: 0, y: 2)
    }

    /// Apply a circular mask
    func circular() -> some View {
        clipShape(Circle())
    }

    /// Apply a rounded rectangle mask
    func rounded(_ radius: CGFloat = 8) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

// MARK: - Debug Modifiers

extension View {
    /// Add a debug border
    func debugBorder(_ color: Color = .red, width: CGFloat = 1) -> some View {
        #if DEBUG
        return border(color, width: width)
        #else
        return self
        #endif
    }

    /// Print debug info when view appears
    func debugOnAppear(_ message: String) -> some View {
        #if DEBUG
        return onAppear {
            print("🔍 \(message)")
        }
        #else
        return self
        #endif
    }
}

// MARK: - Loading Modifiers

extension View {
    /// Show a loading overlay
    func loading(_ isLoading: Bool) -> some View {
        overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.3)
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(1.5)
                }
                .ignoresSafeArea()
            }
        }
    }

    /// Redact content when loading
    func redacted(when loading: Bool) -> some View {
        redacted(reason: loading ? .placeholder : [])
    }
}

// MARK: - Animation Modifiers

extension View {
    /// Apply a spring animation
    func springAnimation() -> some View {
        animation(.spring(response: 0.3, dampingFraction: 0.7), value: UUID())
    }

    /// Animate on appear
    func animateOnAppear(
        animation: Animation = .easeOut(duration: 0.3),
        delay: TimeInterval = 0
    ) -> some View {
        modifier(AnimateOnAppearModifier(animation: animation, delay: delay))
    }
}

private struct AnimateOnAppearModifier: ViewModifier {
    let animation: Animation
    let delay: TimeInterval

    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(animation.delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// MARK: - Gesture Modifiers

extension View {
    /// Add haptic feedback on tap
    func hapticTap(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) -> some View {
        simultaneousGesture(
            TapGesture()
                .onEnded { _ in
                    let generator = UIImpactFeedbackGenerator(style: style)
                    generator.impactOccurred()
                }
        )
    }
}

// MARK: - Safe Area

extension View {
    /// Read the safe area insets
    func readSafeAreaInsets(_ insets: Binding<EdgeInsets>) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        insets.wrappedValue = geometry.safeAreaInsets
                    }
                    .onChange(of: geometry.safeAreaInsets) { _, newValue in
                        insets.wrappedValue = newValue
                    }
            }
        )
    }
}

// MARK: - Size Reading

extension View {
    /// Read the view's size
    func readSize(_ size: Binding<CGSize>) -> some View {
        background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        size.wrappedValue = geometry.size
                    }
                    .onChange(of: geometry.size) { _, newValue in
                        size.wrappedValue = newValue
                    }
            }
        )
    }
}
