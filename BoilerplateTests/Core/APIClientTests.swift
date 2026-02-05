import Foundation
import Testing
@testable import Boilerplate

/// Tests for APIClient functionality
struct APIClientTests {
    // MARK: - Basic Request Tests

    @Test("API client makes successful request")
    func testSuccessfulRequest() async throws {
        let mockClient = MockAPIClient()
        let expectedResponse = ItemResponse(
            id: "1",
            title: "Test Item",
            description: "Test description",
            createdAt: Date(),
            updatedAt: Date()
        )
        mockClient.mockResponse = expectedResponse

        let response: ItemResponse = try await mockClient.request(.getItem(id: "1"))

        #expect(response.id == expectedResponse.id)
        #expect(response.title == expectedResponse.title)
        #expect(mockClient.requestCount == 1)
    }

    @Test("API client throws error on failure")
    func testErrorResponse() async throws {
        let mockClient = MockAPIClient()
        mockClient.mockError = APIError.networkUnavailable

        await #expect(throws: APIError.self) {
            let _: ItemResponse = try await mockClient.request(.getItem(id: "1"))
        }
    }

    @Test("API client tracks requested endpoints")
    func testEndpointTracking() async throws {
        let mockClient = MockAPIClient()
        mockClient.mockResponse = Data()

        _ = try? await mockClient.request(.getItems(page: 1, limit: 10)) as Data
        _ = try? await mockClient.request(.getItem(id: "123")) as Data
        _ = try? await mockClient.request(.deleteItem(id: "456")) as Data

        #expect(mockClient.requestCount == 3)
        #expect(mockClient.requestedEndpoints.count == 3)
    }

    // MARK: - Error Type Tests

    @Test("API error provides correct descriptions", arguments: [
        (APIError.networkUnavailable, "Network connection is unavailable"),
        (APIError.unauthorized, "You are not authorized"),
        (APIError.notFound, "The requested resource was not found"),
        (APIError.timeout, "The request timed out")
    ])
    func testErrorDescriptions(error: APIError, expectedSubstring: String) {
        let description = error.localizedDescription
        #expect(description.contains(expectedSubstring))
    }

    @Test("API error identifies recoverable errors correctly")
    func testRecoverableErrors() {
        #expect(APIError.networkUnavailable.isRecoverable == true)
        #expect(APIError.timeout.isRecoverable == true)
        #expect(APIError.rateLimited(retryAfter: nil).isRecoverable == true)
        #expect(APIError.serverError(statusCode: 500, message: nil).isRecoverable == true)

        #expect(APIError.unauthorized.isRecoverable == false)
        #expect(APIError.notFound.isRecoverable == false)
        #expect(APIError.invalidURL.isRecoverable == false)
    }

    @Test("API error creates correct error from status code")
    func testErrorFromStatusCode() {
        #expect(APIError.from(statusCode: 400, data: nil) == .badRequest(message: nil))
        #expect(APIError.from(statusCode: 401, data: nil) == .unauthorized)
        #expect(APIError.from(statusCode: 403, data: nil) == .forbidden)
        #expect(APIError.from(statusCode: 404, data: nil) == .notFound)
        #expect(APIError.from(statusCode: 429, data: nil) == .rateLimited(retryAfter: nil))
    }

    // MARK: - Endpoint Tests

    @Test("Endpoints have correct HTTP methods")
    func testEndpointMethods() {
        #expect(APIEndpoint.getItems(page: 1, limit: 10).method == .get)
        #expect(APIEndpoint.getItem(id: "1").method == .get)
        #expect(APIEndpoint.createItem(CreateItemRequest(title: "Test", description: nil)).method == .post)
        #expect(APIEndpoint.updateItem(id: "1", UpdateItemRequest(title: "New")).method == .put)
        #expect(APIEndpoint.deleteItem(id: "1").method == .delete)
    }

    @Test("Endpoints have correct paths")
    func testEndpointPaths() {
        #expect(APIEndpoint.getItems(page: 1, limit: 10).path == "/items")
        #expect(APIEndpoint.getItem(id: "123").path == "/items/123")
        #expect(APIEndpoint.login(email: "test@example.com", password: "pass").path == "/auth/login")
        #expect(APIEndpoint.getCurrentUser.path == "/users/me")
    }

    @Test("Endpoints correctly identify auth requirements")
    func testEndpointAuthRequirements() {
        #expect(APIEndpoint.login(email: "", password: "").requiresAuth == false)
        #expect(APIEndpoint.signUp(name: "", email: "", password: "").requiresAuth == false)
        #expect(APIEndpoint.refreshToken(refreshToken: "").requiresAuth == false)

        #expect(APIEndpoint.getCurrentUser.requiresAuth == true)
        #expect(APIEndpoint.getItems(page: 1, limit: 10).requiresAuth == true)
        #expect(APIEndpoint.deleteItem(id: "1").requiresAuth == true)
    }
}
