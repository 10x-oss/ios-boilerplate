import Foundation

/// Middleware that logs all network requests and responses
final class LoggingMiddleware: APIMiddleware {
    // MARK: - Properties

    private let logLevel: LogLevel

    // MARK: - Initialization

    init(logLevel: LogLevel = .debug) {
        self.logLevel = logLevel
    }

    // MARK: - RequestMiddleware

    func prepare(_ request: URLRequest) async throws -> URLRequest {
        guard AppEnvironment.current.loggingLevel <= logLevel else {
            return request
        }

        var logMessage = ">>> Request: \(request.httpMethod ?? "?") \(request.url?.absoluteString ?? "?")"

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            logMessage += "\nHeaders: \(sanitizeHeaders(headers))"
        }

        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            logMessage += "\nBody: \(truncate(bodyString, maxLength: 500))"
        }

        Logger.shared.network(logMessage, level: logLevel)

        return request
    }

    // MARK: - ResponseMiddleware

    func process(_ data: Data, _ response: URLResponse) async throws -> Data {
        guard AppEnvironment.current.loggingLevel <= logLevel else {
            return data
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            return data
        }

        var logMessage = "<<< Response: \(httpResponse.statusCode) \(response.url?.absoluteString ?? "?")"

        if let bodyString = String(data: data, encoding: .utf8) {
            logMessage += "\nBody: \(truncate(bodyString, maxLength: 500))"
        }

        Logger.shared.network(logMessage, level: logLevel)

        return data
    }

    // MARK: - Private Methods

    private func sanitizeHeaders(_ headers: [String: String]) -> [String: String] {
        var sanitized = headers

        // Remove sensitive headers from logs
        let sensitiveHeaders = ["Authorization", "Cookie", "X-API-Key"]
        for header in sensitiveHeaders {
            if sanitized[header] != nil {
                sanitized[header] = "[REDACTED]"
            }
        }

        return sanitized
    }

    private func truncate(_ string: String, maxLength: Int) -> String {
        if string.count <= maxLength {
            return string
        }
        return String(string.prefix(maxLength)) + "..."
    }
}
