import Foundation

/// Protocol for request middleware that can modify requests before sending
protocol RequestMiddleware {
    func prepare(_ request: URLRequest) async throws -> URLRequest
}

/// Protocol for response middleware that can process responses after receiving
protocol ResponseMiddleware {
    func process(_ data: Data, _ response: URLResponse) async throws -> Data
}

/// Combined middleware protocol
protocol APIMiddleware: RequestMiddleware, ResponseMiddleware {}

/// Authentication middleware that adds auth headers to requests
final class AuthMiddleware: RequestMiddleware {
    // MARK: - Properties

    private let tokenProvider: () -> String?

    // MARK: - Initialization

    init(tokenProvider: @escaping () -> String?) {
        self.tokenProvider = tokenProvider
    }

    // MARK: - RequestMiddleware

    func prepare(_ request: URLRequest) async throws -> URLRequest {
        var modifiedRequest = request

        if let token = tokenProvider() {
            modifiedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return modifiedRequest
    }
}

/// Middleware that adds common headers to all requests
final class CommonHeadersMiddleware: RequestMiddleware {
    // MARK: - Properties

    private let appVersion: String
    private let platform: String

    // MARK: - Initialization

    init() {
        appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        platform = "iOS"
    }

    // MARK: - RequestMiddleware

    func prepare(_ request: URLRequest) async throws -> URLRequest {
        var modifiedRequest = request

        modifiedRequest.setValue(appVersion, forHTTPHeaderField: "X-App-Version")
        modifiedRequest.setValue(platform, forHTTPHeaderField: "X-Platform")

        return modifiedRequest
    }
}
