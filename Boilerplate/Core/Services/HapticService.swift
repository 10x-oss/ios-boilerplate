import CoreHaptics
import UIKit

/// Haptic feedback service using Core Haptics and UIKit feedback generators
/// Provides both simple feedback and custom haptic patterns
final class HapticService {
    // MARK: - Singleton

    static let shared = HapticService()

    // MARK: - Properties

    private var engine: CHHapticEngine?
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let selection = UISelectionFeedbackGenerator()
    private let notification = UINotificationFeedbackGenerator()

    private var isEnabled: Bool {
        UserDefaultsWrapper.hapticsEnabled && FeatureFlags.shared.hapticsEnabled
    }

    private var supportsHaptics: Bool {
        CHHapticEngine.capabilitiesForHardware().supportsHaptics
    }

    // MARK: - Initialization

    private init() {
        prepareGenerators()
        setupEngine()
    }

    // MARK: - Setup

    private func prepareGenerators() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        selection.prepare()
        notification.prepare()
    }

    private func setupEngine() {
        guard supportsHaptics else { return }

        do {
            engine = try CHHapticEngine()
            engine?.playsHapticsOnly = true

            engine?.stoppedHandler = { [weak self] reason in
                Logger.shared.app("Haptic engine stopped: \(reason)", level: .debug)
                self?.restartEngine()
            }

            engine?.resetHandler = { [weak self] in
                Logger.shared.app("Haptic engine reset", level: .debug)
                try? self?.engine?.start()
            }

            try engine?.start()
        } catch {
            Logger.shared.error(error, context: "Failed to setup haptic engine")
        }
    }

    private func restartEngine() {
        guard supportsHaptics else { return }

        do {
            try engine?.start()
        } catch {
            Logger.shared.error(error, context: "Failed to restart haptic engine")
        }
    }

    // MARK: - Simple Feedback

    /// Light impact feedback (subtle tap)
    func lightImpact() {
        guard isEnabled else { return }
        impactLight.impactOccurred()
    }

    /// Medium impact feedback (standard tap)
    func mediumImpact() {
        guard isEnabled else { return }
        impactMedium.impactOccurred()
    }

    /// Heavy impact feedback (strong tap)
    func heavyImpact() {
        guard isEnabled else { return }
        impactHeavy.impactOccurred()
    }

    /// Selection change feedback (subtle click)
    func selectionChanged() {
        guard isEnabled else { return }
        selection.selectionChanged()
    }

    /// Success notification feedback
    func success() {
        guard isEnabled else { return }
        notification.notificationOccurred(.success)
    }

    /// Warning notification feedback
    func warning() {
        guard isEnabled else { return }
        notification.notificationOccurred(.warning)
    }

    /// Error notification feedback
    func error() {
        guard isEnabled else { return }
        notification.notificationOccurred(.error)
    }

    // MARK: - Custom Patterns

    /// Play a custom haptic pattern
    func playPattern(_ pattern: HapticPattern) {
        guard isEnabled, supportsHaptics, let engine else { return }

        do {
            let hapticPattern = try pattern.toChapticPattern()
            let player = try engine.makePlayer(with: hapticPattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            Logger.shared.error(error, context: "Failed to play haptic pattern")
        }
    }

    /// Play a continuous haptic for a duration
    func playContinuous(intensity: Float, sharpness: Float, duration: TimeInterval) {
        guard isEnabled, supportsHaptics, let engine else { return }

        do {
            let intensityParam = CHHapticEventParameter(
                parameterID: .hapticIntensity,
                value: intensity
            )
            let sharpnessParam = CHHapticEventParameter(
                parameterID: .hapticSharpness,
                value: sharpness
            )

            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [intensityParam, sharpnessParam],
                relativeTime: 0,
                duration: duration
            )

            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            Logger.shared.error(error, context: "Failed to play continuous haptic")
        }
    }

    // MARK: - Convenience Methods

    /// Button tap feedback
    func buttonTap() {
        lightImpact()
    }

    /// Toggle switch feedback
    func toggleChanged() {
        mediumImpact()
    }

    /// Item deleted feedback
    func itemDeleted() {
        warning()
    }

    /// Action completed feedback
    func actionCompleted() {
        success()
    }

    /// Action failed feedback
    func actionFailed() {
        error()
    }
}

// MARK: - Haptic Pattern

struct HapticPattern {
    let events: [HapticEvent]

    struct HapticEvent {
        let type: EventType
        let intensity: Float
        let sharpness: Float
        let relativeTime: TimeInterval
        let duration: TimeInterval?

        enum EventType {
            case transient
            case continuous
        }
    }

    func toChapticPattern() throws -> CHHapticPattern {
        let hapticEvents = events.map { event -> CHHapticEvent in
            let intensityParam = CHHapticEventParameter(
                parameterID: .hapticIntensity,
                value: event.intensity
            )
            let sharpnessParam = CHHapticEventParameter(
                parameterID: .hapticSharpness,
                value: event.sharpness
            )

            switch event.type {
            case .transient:
                return CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensityParam, sharpnessParam],
                    relativeTime: event.relativeTime
                )
            case .continuous:
                return CHHapticEvent(
                    eventType: .hapticContinuous,
                    parameters: [intensityParam, sharpnessParam],
                    relativeTime: event.relativeTime,
                    duration: event.duration ?? 0.1
                )
            }
        }

        return try CHHapticPattern(events: hapticEvents, parameters: [])
    }
}

// MARK: - Predefined Patterns

extension HapticPattern {
    /// Double tap pattern
    static let doubleTap = HapticPattern(events: [
        HapticEvent(type: .transient, intensity: 0.8, sharpness: 0.6, relativeTime: 0, duration: nil),
        HapticEvent(type: .transient, intensity: 0.8, sharpness: 0.6, relativeTime: 0.1, duration: nil)
    ])

    /// Rising intensity pattern
    static let rising = HapticPattern(events: [
        HapticEvent(type: .transient, intensity: 0.3, sharpness: 0.5, relativeTime: 0, duration: nil),
        HapticEvent(type: .transient, intensity: 0.6, sharpness: 0.5, relativeTime: 0.1, duration: nil),
        HapticEvent(type: .transient, intensity: 1.0, sharpness: 0.5, relativeTime: 0.2, duration: nil)
    ])

    /// Heartbeat pattern
    static let heartbeat = HapticPattern(events: [
        HapticEvent(type: .transient, intensity: 0.8, sharpness: 0.4, relativeTime: 0, duration: nil),
        HapticEvent(type: .transient, intensity: 0.6, sharpness: 0.4, relativeTime: 0.15, duration: nil)
    ])
}
