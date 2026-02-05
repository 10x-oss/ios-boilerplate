import SwiftUI

/// ViewModel for settings screen
@Observable
final class SettingsViewModel {
    // MARK: - Settings State

    var hapticsEnabled: Bool {
        didSet {
            UserDefaultsWrapper.hapticsEnabled = hapticsEnabled
            FeatureFlags.shared.hapticsEnabled = hapticsEnabled
        }
    }

    var soundsEnabled: Bool {
        didSet {
            UserDefaultsWrapper.soundsEnabled = soundsEnabled
        }
    }

    var notificationsEnabled: Bool {
        didSet {
            UserDefaultsWrapper.notificationsEnabled = notificationsEnabled
        }
    }

    var selectedTheme: AppThemeOption {
        didSet {
            UserDefaultsWrapper.selectedTheme = selectedTheme.rawValue
        }
    }

    // MARK: - App Info

    let appVersion = AppConstants.appVersion
    let buildNumber = AppConstants.buildNumber

    // MARK: - Dependencies

    private let authService: AuthService
    private let analyticsService: AnalyticsService

    // MARK: - Initialization

    init(authService: AuthService, analyticsService: AnalyticsService) {
        self.authService = authService
        self.analyticsService = analyticsService

        // Load saved settings
        hapticsEnabled = UserDefaultsWrapper.hapticsEnabled
        soundsEnabled = UserDefaultsWrapper.soundsEnabled
        notificationsEnabled = UserDefaultsWrapper.notificationsEnabled
        selectedTheme = AppThemeOption(rawValue: UserDefaultsWrapper.selectedTheme) ?? .system
    }

    // MARK: - Actions

    func signOut() async {
        await authService.signOut()
        analyticsService.track(.logout)
    }

    func clearCache() {
        // Clear image cache, temporary files, etc.
        URLCache.shared.removeAllCachedResponses()
        Logger.shared.app("Cache cleared", level: .info)
    }

    func resetOnboarding() {
        UserDefaultsWrapper.hasCompletedOnboarding = false
        Logger.shared.app("Onboarding reset", level: .info)
    }

    #if DEBUG
    func resetAllData() {
        UserDefaultsWrapper.resetAll()
        try? KeychainManager.shared.deleteAll()
        Logger.shared.app("All data reset", level: .warning)
    }
    #endif
}

// MARK: - Theme Option

enum AppThemeOption: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }

    var icon: String {
        switch self {
        case .system: return "gear"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}
