import Foundation

/// Protocol for the Example API service
protocol ExampleAPIServiceProtocol: Sendable {
    func getItems(page: Int, limit: Int) async throws -> PaginatedResponse<ItemResponse>
    func getItem(id: String) async throws -> ItemResponse
    func createItem(title: String, description: String?) async throws -> ItemResponse
    func updateItem(id: String, title: String?, description: String?) async throws -> ItemResponse
    func deleteItem(id: String) async throws
}

/// Example API service implementation
final class ExampleAPIService: ExampleAPIServiceProtocol, @unchecked Sendable {
    // MARK: - Properties

    private let apiClient: APIClient

    // MARK: - Initialization

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    // MARK: - API Methods

    func getItems(page: Int, limit: Int) async throws -> PaginatedResponse<ItemResponse> {
        try await apiClient.request(.getItems(page: page, limit: limit))
    }

    func getItem(id: String) async throws -> ItemResponse {
        try await apiClient.request(.getItem(id: id))
    }

    func createItem(title: String, description: String?) async throws -> ItemResponse {
        let request = CreateItemRequest(title: title, description: description)
        return try await apiClient.request(.createItem(request))
    }

    func updateItem(id: String, title: String?, description: String?) async throws -> ItemResponse {
        let request = UpdateItemRequest(title: title, description: description)
        return try await apiClient.request(.updateItem(id: id, request))
    }

    func deleteItem(id: String) async throws {
        _ = try await apiClient.request(.deleteItem(id: id)) as Data
    }
}

// MARK: - Mock Service for Previews/Testing

#if DEBUG
final class MockExampleAPIService: ExampleAPIServiceProtocol, @unchecked Sendable {
    var mockItems: [ItemResponse] = [
        ItemResponse(id: "1", title: "First Item", description: "Description 1", createdAt: Date(), updatedAt: Date()),
        ItemResponse(id: "2", title: "Second Item", description: nil, createdAt: Date(), updatedAt: Date()),
        ItemResponse(id: "3", title: "Third Item", description: "Description 3", createdAt: Date(), updatedAt: Date())
    ]

    var shouldFail = false
    var delay: TimeInterval = 0.5

    func getItems(page: Int, limit: Int) async throws -> PaginatedResponse<ItemResponse> {
        try await simulateDelay()

        if shouldFail {
            throw APIError.serverError(statusCode: 500, message: "Mock error")
        }

        let startIndex = (page - 1) * limit
        let endIndex = min(startIndex + limit, mockItems.count)
        let items = Array(mockItems[startIndex ..< endIndex])

        return PaginatedResponse(
            items: items,
            page: page,
            limit: limit,
            totalItems: mockItems.count,
            totalPages: (mockItems.count + limit - 1) / limit
        )
    }

    func getItem(id: String) async throws -> ItemResponse {
        try await simulateDelay()

        if shouldFail {
            throw APIError.serverError(statusCode: 500, message: "Mock error")
        }

        guard let item = mockItems.first(where: { $0.id == id }) else {
            throw APIError.notFound
        }

        return item
    }

    func createItem(title: String, description: String?) async throws -> ItemResponse {
        try await simulateDelay()

        if shouldFail {
            throw APIError.serverError(statusCode: 500, message: "Mock error")
        }

        let newItem = ItemResponse(
            id: UUID().uuidString,
            title: title,
            description: description,
            createdAt: Date(),
            updatedAt: Date()
        )

        mockItems.append(newItem)
        return newItem
    }

    func updateItem(id: String, title: String?, description: String?) async throws -> ItemResponse {
        try await simulateDelay()

        if shouldFail {
            throw APIError.serverError(statusCode: 500, message: "Mock error")
        }

        guard let index = mockItems.firstIndex(where: { $0.id == id }) else {
            throw APIError.notFound
        }

        let existing = mockItems[index]
        let updated = ItemResponse(
            id: id,
            title: title ?? existing.title,
            description: description ?? existing.description,
            createdAt: existing.createdAt,
            updatedAt: Date()
        )

        mockItems[index] = updated
        return updated
    }

    func deleteItem(id: String) async throws {
        try await simulateDelay()

        if shouldFail {
            throw APIError.serverError(statusCode: 500, message: "Mock error")
        }

        mockItems.removeAll { $0.id == id }
    }

    private func simulateDelay() async throws {
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
    }
}
#endif
