import Foundation

/// Feature flags for controlling feature availability
/// Use these to enable/disable features without code changes
@Observable
final class FeatureFlags {
    // MARK: - Singleton

    static let shared = FeatureFlags()

    // MARK: - Feature Flags

    /// Enable new onboarding flow
    var newOnboardingEnabled: Bool = false

    /// Enable experimental UI components
    var experimentalUIEnabled: Bool = false

    /// Enable offline mode support
    var offlineModeEnabled: Bool = true

    /// Enable push notifications
    var pushNotificationsEnabled: Bool = true

    /// Enable analytics tracking
    var analyticsEnabled: Bool = AppEnvironment.current.analyticsEnabled

    /// Enable haptic feedback
    var hapticsEnabled: Bool = true

    /// Enable dark mode support
    var darkModeEnabled: Bool = true

    // MARK: - Debug Flags (Development Only)

    #if DEBUG
    /// Show debug overlay
    var showDebugOverlay: Bool = false

    /// Log all network requests
    var logNetworkRequests: Bool = true

    /// Use mock API responses
    var useMockAPI: Bool = false

    /// Simulate slow network
    var simulateSlowNetwork: Bool = false

    /// Network delay in seconds when simulating slow network
    var simulatedNetworkDelay: TimeInterval = 2.0
    #endif

    // MARK: - Initialization

    private init() {
        loadFromUserDefaults()
    }

    // MARK: - Persistence

    private func loadFromUserDefaults() {
        let defaults = UserDefaults.standard

        if defaults.object(forKey: "ff_hapticsEnabled") != nil {
            hapticsEnabled = defaults.bool(forKey: "ff_hapticsEnabled")
        }

        if defaults.object(forKey: "ff_darkModeEnabled") != nil {
            darkModeEnabled = defaults.bool(forKey: "ff_darkModeEnabled")
        }
    }

    func saveToUserDefaults() {
        let defaults = UserDefaults.standard
        defaults.set(hapticsEnabled, forKey: "ff_hapticsEnabled")
        defaults.set(darkModeEnabled, forKey: "ff_darkModeEnabled")
    }

    // MARK: - Remote Config (Placeholder)

    /// Fetch feature flags from remote configuration service
    func fetchRemoteConfig() async {
        // TODO: Implement remote config fetching
        // Example: Firebase Remote Config, LaunchDarkly, etc.
    }
}
