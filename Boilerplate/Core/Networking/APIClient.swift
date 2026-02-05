import Foundation

/// Protocol for the API client, enabling dependency injection and testing
protocol APIClientProtocol: Sendable {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
    func request(_ endpoint: APIEndpoint) async throws -> Data
}

/// Main API client implementation with async/await networking
@Observable
final class APIClient: APIClientProtocol, @unchecked Sendable {
    // MARK: - Properties

    private let session: URLSession
    private let baseURL: URL
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private var authToken: String?
    private var refreshToken: String?

    private let tokenLock = NSLock()

    // MARK: - Initialization

    init(
        baseURL: URL = AppEnvironment.current.baseURL,
        session: URLSession? = nil
    ) {
        self.baseURL = baseURL

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = AppEnvironment.current.requestTimeout
        config.timeoutIntervalForResource = AppEnvironment.current.requestTimeout * 2
        self.session = session ?? URLSession(configuration: config)

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    // MARK: - Auth Token Management

    func setAuthToken(_ token: String?, refresh: String? = nil) {
        tokenLock.lock()
        defer { tokenLock.unlock() }
        authToken = token
        if let refresh {
            refreshToken = refresh
        }
    }

    func clearAuthToken() {
        tokenLock.lock()
        defer { tokenLock.unlock() }
        authToken = nil
        refreshToken = nil
    }

    // MARK: - APIClientProtocol

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let data = try await request(endpoint)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            Logger.shared.network("Decoding failed: \(error)", level: .error)
            throw APIError.decodingFailed(error)
        }
    }

    func request(_ endpoint: APIEndpoint) async throws -> Data {
        let request = try buildRequest(for: endpoint)

        Logger.shared.network("[\(endpoint.method.rawValue)] \(endpoint.path)", level: .debug)

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknown("Invalid response type")
            }

            Logger.shared.network("Response: \(httpResponse.statusCode) for \(endpoint.path)", level: .debug)

            try validateResponse(httpResponse, data: data)

            return data
        } catch let error as URLError {
            throw APIError.from(urlError: error)
        } catch let error as APIError {
            // Handle 401 with token refresh
            if case .unauthorized = error, endpoint.requiresAuth {
                if try await attemptTokenRefresh() {
                    // Retry the original request
                    return try await self.request(endpoint)
                }
            }
            throw error
        }
    }

    // MARK: - Private Methods

    private func buildRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        components?.path += endpoint.path
        components?.queryItems = endpoint.queryItems

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue

        // Default headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Custom headers
        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        // Auth header
        if endpoint.requiresAuth {
            tokenLock.lock()
            let token = authToken
            tokenLock.unlock()

            if let token {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        // Body
        if let body = endpoint.body {
            do {
                request.httpBody = try encoder.encode(AnyEncodable(body))
            } catch {
                throw APIError.encodingFailed(error)
            }
        }

        return request
    }

    private func validateResponse(_ response: HTTPURLResponse, data: Data) throws {
        switch response.statusCode {
        case 200 ... 299:
            return
        case 401:
            throw APIError.unauthorized
        default:
            throw APIError.from(statusCode: response.statusCode, data: data)
        }
    }

    private func attemptTokenRefresh() async throws -> Bool {
        tokenLock.lock()
        let refresh = refreshToken
        tokenLock.unlock()

        guard let refresh else {
            return false
        }

        do {
            let response: AuthResponse = try await request(.refreshToken(refreshToken: refresh))
            setAuthToken(response.accessToken, refresh: response.refreshToken)
            return true
        } catch {
            Logger.shared.auth("Token refresh failed: \(error)", level: .warning)
            clearAuthToken()
            return false
        }
    }
}

// MARK: - AnyEncodable Wrapper

private struct AnyEncodable: Encodable {
    private let encodeClosure: (Encoder) throws -> Void

    init<T: Encodable>(_ value: T) {
        encodeClosure = { encoder in
            try value.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try encodeClosure(encoder)
    }
}
