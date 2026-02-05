import Foundation

/// Type-safe UserDefaults wrapper using property wrappers
/// Provides compile-time safety for UserDefaults access
@propertyWrapper
struct UserDefault<T> {
    let key: String
    let defaultValue: T
    let storage: UserDefaults

    init(key: String, defaultValue: T, storage: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }

    var wrappedValue: T {
        get {
            storage.object(forKey: key) as? T ?? defaultValue
        }
        set {
            if let optional = newValue as? AnyOptional, optional.isNil {
                storage.removeObject(forKey: key)
            } else {
                storage.set(newValue, forKey: key)
            }
        }
    }
}

/// Property wrapper for Codable types in UserDefaults
@propertyWrapper
struct UserDefaultCodable<T: Codable> {
    let key: String
    let defaultValue: T
    let storage: UserDefaults

    init(key: String, defaultValue: T, storage: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.storage = storage
    }

    var wrappedValue: T {
        get {
            guard let data = storage.data(forKey: key) else {
                return defaultValue
            }
            return (try? JSONDecoder().decode(T.self, from: data)) ?? defaultValue
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                storage.set(data, forKey: key)
            }
        }
    }
}

/// Property wrapper for optional Codable types
@propertyWrapper
struct UserDefaultCodableOptional<T: Codable> {
    let key: String
    let storage: UserDefaults

    init(key: String, storage: UserDefaults = .standard) {
        self.key = key
        self.storage = storage
    }

    var wrappedValue: T? {
        get {
            guard let data = storage.data(forKey: key) else {
                return nil
            }
            return try? JSONDecoder().decode(T.self, from: data)
        }
        set {
            if let value = newValue, let data = try? JSONEncoder().encode(value) {
                storage.set(data, forKey: key)
            } else {
                storage.removeObject(forKey: key)
            }
        }
    }
}

// MARK: - Optional Protocol for nil checking

private protocol AnyOptional {
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    var isNil: Bool { self == nil }
}

// MARK: - App-Wide UserDefaults Keys

/// Centralized UserDefaults access for the app
enum UserDefaultsWrapper {
    private static let storage = UserDefaults.standard

    // MARK: - Onboarding

    @UserDefault(key: "hasCompletedOnboarding", defaultValue: false)
    static var hasCompletedOnboarding: Bool

    @UserDefault(key: "onboardingVersion", defaultValue: 0)
    static var onboardingVersion: Int

    // MARK: - Appearance

    @UserDefault(key: "selectedTheme", defaultValue: "system")
    static var selectedTheme: String

    @UserDefault(key: "accentColorHex", defaultValue: nil as String?)
    static var accentColorHex: String?

    // MARK: - User Preferences

    @UserDefault(key: "hapticsEnabled", defaultValue: true)
    static var hapticsEnabled: Bool

    @UserDefault(key: "soundsEnabled", defaultValue: true)
    static var soundsEnabled: Bool

    @UserDefault(key: "notificationsEnabled", defaultValue: true)
    static var notificationsEnabled: Bool

    // MARK: - App State

    @UserDefault(key: "lastSyncDate", defaultValue: nil as Date?)
    static var lastSyncDate: Date?

    @UserDefault(key: "launchCount", defaultValue: 0)
    static var launchCount: Int

    @UserDefault(key: "lastAppVersion", defaultValue: nil as String?)
    static var lastAppVersion: String?

    // MARK: - Debug (Development Only)

    #if DEBUG
    @UserDefault(key: "debug_showFrameRates", defaultValue: false)
    static var debugShowFrameRates: Bool

    @UserDefault(key: "debug_logNetworkRequests", defaultValue: true)
    static var debugLogNetworkRequests: Bool
    #endif

    // MARK: - Methods

    /// Increment launch count and return the new value
    static func incrementLaunchCount() -> Int {
        launchCount += 1
        return launchCount
    }

    /// Check if the app was updated since last launch
    static func checkForAppUpdate() -> Bool {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let wasUpdated = lastAppVersion != nil && lastAppVersion != currentVersion
        lastAppVersion = currentVersion
        return wasUpdated
    }

    /// Reset all user defaults to default values
    static func resetAll() {
        let domain = Bundle.main.bundleIdentifier!
        storage.removePersistentDomain(forName: domain)
        storage.synchronize()
    }
}
