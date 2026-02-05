import Foundation
import SwiftData
import Testing
@testable import Boilerplate

/// Tests for ExampleListViewModel
struct ExampleListViewModelTests {
    // MARK: - Setup

    @MainActor
    private func createViewModel() -> (ExampleListViewModel, MockExampleAPIService, ModelContext) {
        let container = SwiftDataContainer.createTestContainer()
        let context = ModelContext(container)
        let mockService = MockExampleAPIService()
        let viewModel = ExampleListViewModel(apiService: mockService, modelContext: context)

        return (viewModel, mockService, context)
    }

    // MARK: - Initial State Tests

    @Test("ViewModel starts with empty state")
    @MainActor
    func testInitialState() {
        let (viewModel, _, _) = createViewModel()

        #expect(viewModel.items.isEmpty)
        #expect(viewModel.loadingState == .idle)
        #expect(viewModel.searchText.isEmpty)
        #expect(viewModel.isEmpty == true)
    }

    // MARK: - Loading Tests

    @Test("ViewModel loads local items correctly")
    @MainActor
    func testLoadLocalItems() throws {
        let (viewModel, _, context) = createViewModel()

        // Insert test data
        let item1 = ExampleItem(title: "Test 1", itemDescription: "Description 1")
        let item2 = ExampleItem(title: "Test 2", itemDescription: "Description 2")
        context.insert(item1)
        context.insert(item2)
        try context.save()

        viewModel.loadLocalItems()

        #expect(viewModel.items.count == 2)
        #expect(viewModel.loadingState.isLoaded)
    }

    @Test("ViewModel refreshes items from API")
    @MainActor
    func testRefresh() async {
        let (viewModel, mockService, _) = createViewModel()

        await viewModel.refresh()

        #expect(viewModel.items.count == mockService.mockItems.count)
        #expect(viewModel.loadingState.isLoaded)
    }

    @Test("ViewModel handles refresh error")
    @MainActor
    func testRefreshError() async {
        let (viewModel, mockService, _) = createViewModel()
        mockService.shouldFail = true

        await viewModel.refresh()

        #expect(viewModel.loadingState.isError)
    }

    // MARK: - Search Tests

    @Test("ViewModel filters items by search text")
    @MainActor
    func testSearchFiltering() async {
        let (viewModel, _, _) = createViewModel()

        await viewModel.refresh()

        viewModel.searchText = "First"
        #expect(viewModel.filteredItems.count == 1)
        #expect(viewModel.filteredItems.first?.title == "First Item")

        viewModel.searchText = ""
        #expect(viewModel.filteredItems.count == viewModel.items.count)
    }

    @Test("Search is case insensitive")
    @MainActor
    func testCaseInsensitiveSearch() async {
        let (viewModel, _, _) = createViewModel()

        await viewModel.refresh()

        viewModel.searchText = "first"
        #expect(viewModel.filteredItems.count == 1)

        viewModel.searchText = "FIRST"
        #expect(viewModel.filteredItems.count == 1)
    }

    // MARK: - CRUD Tests

    @Test("ViewModel creates item successfully")
    @MainActor
    func testCreateItem() async throws {
        let (viewModel, _, _) = createViewModel()

        try await viewModel.createItem(title: "New Item", description: "New Description")

        #expect(viewModel.items.contains { $0.title == "New Item" })
    }

    @Test("ViewModel deletes item successfully")
    @MainActor
    func testDeleteItem() async throws {
        let (viewModel, _, context) = createViewModel()

        // Create an item first
        let item = ExampleItem(title: "To Delete", itemDescription: nil)
        context.insert(item)
        try context.save()
        viewModel.loadLocalItems()

        let initialCount = viewModel.items.count

        try await viewModel.deleteItem(item)

        #expect(viewModel.items.count == initialCount - 1)
        #expect(!viewModel.items.contains { $0.id == item.id })
    }

    @Test("ViewModel toggles favorite correctly")
    @MainActor
    func testToggleFavorite() throws {
        let (viewModel, _, context) = createViewModel()

        let item = ExampleItem(title: "Test", itemDescription: nil, isFavorite: false)
        context.insert(item)
        try context.save()
        viewModel.loadLocalItems()

        #expect(item.isFavorite == false)

        viewModel.toggleFavorite(item)

        #expect(item.isFavorite == true)

        viewModel.toggleFavorite(item)

        #expect(item.isFavorite == false)
    }

    // MARK: - Pagination Tests

    @Test("ViewModel handles pagination state correctly")
    @MainActor
    func testPaginationState() async {
        let (viewModel, mockService, _) = createViewModel()

        // Add more items to enable pagination
        for i in 4 ... 25 {
            mockService.mockItems.append(ItemResponse(
                id: "\(i)",
                title: "Item \(i)",
                description: nil,
                createdAt: Date(),
                updatedAt: Date()
            ))
        }

        await viewModel.refresh()

        #expect(viewModel.pagination.hasMorePages == true)
        #expect(viewModel.pagination.canLoadMore == true)
    }

    // MARK: - Computed Properties Tests

    @Test("isEmpty returns correct value")
    @MainActor
    func testIsEmpty() async {
        let (viewModel, mockService, _) = createViewModel()

        #expect(viewModel.isEmpty == true)

        mockService.mockItems = []
        await viewModel.refresh()

        #expect(viewModel.isEmpty == true)

        mockService.mockItems = [ItemResponse(id: "1", title: "Test", description: nil, createdAt: nil, updatedAt: nil)]
        await viewModel.refresh()

        #expect(viewModel.isEmpty == false)
    }
}
