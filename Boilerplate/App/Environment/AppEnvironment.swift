import Foundation

/// Application environment configuration
/// Supports development, staging, and production environments
enum AppEnvironment: String {
    case development
    case staging
    case production

    // MARK: - Current Environment

    static var current: AppEnvironment {
        #if DEBUG
        return .development
        #else
        guard let envString = Bundle.main.infoDictionary?["APP_ENVIRONMENT"] as? String,
              let env = AppEnvironment(rawValue: envString) else {
            return .production
        }
        return env
        #endif
    }

    // MARK: - Configuration Values

    /// Base URL for API requests
    var baseURL: URL {
        switch self {
        case .development:
            return URL(string: "https://api-dev.example.com")!
        case .staging:
            return URL(string: "https://api-staging.example.com")!
        case .production:
            return URL(string: "https://api.example.com")!
        }
    }

    /// Whether analytics tracking is enabled
    var analyticsEnabled: Bool {
        switch self {
        case .development:
            return false
        case .staging, .production:
            return true
        }
    }

    /// Logging verbosity level
    var loggingLevel: LogLevel {
        switch self {
        case .development:
            return .debug
        case .staging:
            return .info
        case .production:
            return .error
        }
    }

    /// Whether to show debug UI elements
    var showDebugUI: Bool {
        switch self {
        case .development:
            return true
        case .staging, .production:
            return false
        }
    }

    /// API request timeout interval in seconds
    var requestTimeout: TimeInterval {
        switch self {
        case .development:
            return 60
        case .staging:
            return 30
        case .production:
            return 15
        }
    }

    /// Whether to enable mock data for testing
    var useMockData: Bool {
        #if DEBUG
        return ProcessInfo.processInfo.arguments.contains("-useMockData")
        #else
        return false
        #endif
    }
}

// MARK: - Log Level

enum LogLevel: Int, Comparable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3

    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
