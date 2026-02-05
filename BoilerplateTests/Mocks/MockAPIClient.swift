import Foundation
@testable import Boilerplate

/// Mock API client for testing
final class MockAPIClient: APIClientProtocol, @unchecked Sendable {
    // MARK: - Mock Configuration

    var mockResponse: Any?
    var mockError: Error?
    var requestDelay: TimeInterval = 0
    var requestedEndpoints: [APIEndpoint] = []

    // MARK: - Counters

    var requestCount = 0

    // MARK: - APIClientProtocol

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        requestCount += 1
        requestedEndpoints.append(endpoint)

        if requestDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(requestDelay * 1_000_000_000))
        }

        if let error = mockError {
            throw error
        }

        guard let response = mockResponse as? T else {
            throw APIError.decodingFailed(
                NSError(domain: "MockAPIClient", code: 0, userInfo: [
                    NSLocalizedDescriptionKey: "Mock response type mismatch"
                ])
            )
        }

        return response
    }

    func request(_ endpoint: APIEndpoint) async throws -> Data {
        requestCount += 1
        requestedEndpoints.append(endpoint)

        if requestDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(requestDelay * 1_000_000_000))
        }

        if let error = mockError {
            throw error
        }

        if let data = mockResponse as? Data {
            return data
        }

        return Data()
    }

    // MARK: - Test Helpers

    func reset() {
        mockResponse = nil
        mockError = nil
        requestDelay = 0
        requestedEndpoints = []
        requestCount = 0
    }

    func setSuccessResponse<T: Encodable>(_ response: T) throws {
        mockResponse = response
        mockError = nil
    }

    func setErrorResponse(_ error: Error) {
        mockResponse = nil
        mockError = error
    }

    func lastRequestedEndpoint() -> APIEndpoint? {
        requestedEndpoints.last
    }

    func wasEndpointCalled(_ check: (APIEndpoint) -> Bool) -> Bool {
        requestedEndpoints.contains(where: check)
    }
}
