import Foundation

/// Typed API errors for consistent error handling across the app
enum APIError: Error, LocalizedError, Equatable {
    // MARK: - Network Errors

    case invalidURL
    case networkUnavailable
    case timeout
    case cancelled

    // MARK: - HTTP Errors

    case badRequest(message: String?)
    case unauthorized
    case forbidden
    case notFound
    case conflict(message: String?)
    case rateLimited(retryAfter: TimeInterval?)
    case serverError(statusCode: Int, message: String?)

    // MARK: - Data Errors

    case noData
    case decodingFailed(Error)
    case encodingFailed(Error)

    // MARK: - Generic Error

    case unknown(String)

    // MARK: - LocalizedError

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .networkUnavailable:
            return "Network connection is unavailable. Please check your internet connection."
        case .timeout:
            return "The request timed out. Please try again."
        case .cancelled:
            return "The request was cancelled."
        case .badRequest(let message):
            return message ?? "The request was invalid."
        case .unauthorized:
            return "You are not authorized. Please sign in again."
        case .forbidden:
            return "You don't have permission to access this resource."
        case .notFound:
            return "The requested resource was not found."
        case .conflict(let message):
            return message ?? "A conflict occurred with the current state."
        case .rateLimited:
            return "Too many requests. Please wait a moment and try again."
        case .serverError(_, let message):
            return message ?? "A server error occurred. Please try again later."
        case .noData:
            return "No data was returned from the server."
        case .decodingFailed:
            return "Failed to process the server response."
        case .encodingFailed:
            return "Failed to prepare the request data."
        case .unknown(let message):
            return message
        }
    }

    // MARK: - Properties

    /// Whether the error is recoverable (user can retry)
    var isRecoverable: Bool {
        switch self {
        case .networkUnavailable, .timeout, .rateLimited, .serverError:
            return true
        case .invalidURL, .unauthorized, .forbidden, .notFound, .noData,
             .decodingFailed, .encodingFailed, .cancelled, .badRequest, .conflict, .unknown:
            return false
        }
    }

    /// Suggested action for the user
    var suggestedAction: String? {
        switch self {
        case .networkUnavailable:
            return "Check your internet connection and try again."
        case .timeout:
            return "The server is taking too long. Try again in a moment."
        case .unauthorized:
            return "Please sign in to continue."
        case .rateLimited(let retryAfter):
            if let seconds = retryAfter {
                return "Please wait \(Int(seconds)) seconds before trying again."
            }
            return "Please wait a moment before trying again."
        case .serverError:
            return "Our servers are having issues. Please try again later."
        default:
            return nil
        }
    }

    // MARK: - Equatable

    static func == (lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.networkUnavailable, .networkUnavailable),
             (.timeout, .timeout),
             (.cancelled, .cancelled),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.notFound, .notFound),
             (.noData, .noData):
            return true
        case (.badRequest(let lhsMsg), .badRequest(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.conflict(let lhsMsg), .conflict(let rhsMsg)):
            return lhsMsg == rhsMsg
        case (.rateLimited(let lhsRetry), .rateLimited(let rhsRetry)):
            return lhsRetry == rhsRetry
        case (.serverError(let lhsCode, let lhsMsg), .serverError(let rhsCode, let rhsMsg)):
            return lhsCode == rhsCode && lhsMsg == rhsMsg
        case (.decodingFailed, .decodingFailed),
             (.encodingFailed, .encodingFailed):
            return true
        case (.unknown(let lhsMsg), .unknown(let rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }

    // MARK: - Factory Methods

    static func from(statusCode: Int, data: Data?) -> APIError {
        let message = data.flatMap { try? JSONDecoder().decode(ErrorResponse.self, from: $0) }?.message

        switch statusCode {
        case 400:
            return .badRequest(message: message)
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 409:
            return .conflict(message: message)
        case 429:
            return .rateLimited(retryAfter: nil)
        case 500 ... 599:
            return .serverError(statusCode: statusCode, message: message)
        default:
            return .unknown("HTTP \(statusCode)")
        }
    }

    static func from(urlError: URLError) -> APIError {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .networkUnavailable
        case .timedOut:
            return .timeout
        case .cancelled:
            return .cancelled
        case .badURL:
            return .invalidURL
        default:
            return .unknown(urlError.localizedDescription)
        }
    }
}

// MARK: - Error Response Model

private struct ErrorResponse: Decodable {
    let message: String?
    let error: String?

    var displayMessage: String? {
        message ?? error
    }
}
