import Foundation
import SwiftData

/// ViewModel for the Example list feature
/// Demonstrates @Observable pattern with loading states, pagination, and API integration
@Observable
final class ExampleListViewModel {
    // MARK: - State

    private(set) var items: [ExampleItem] = []
    private(set) var loadingState: LoadingState<[ExampleItem]> = .idle
    private(set) var pagination = PaginationState<ExampleItem>()

    var searchText = ""

    // MARK: - Computed Properties

    var filteredItems: [ExampleItem] {
        if searchText.isEmpty {
            return items
        }
        return items.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
                ($0.itemDescription?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var isEmpty: Bool {
        items.isEmpty && !loadingState.isLoading
    }

    var isRefreshing: Bool {
        loadingState.isLoading && !items.isEmpty
    }

    // MARK: - Dependencies

    private let apiService: ExampleAPIServiceProtocol
    private let modelContext: ModelContext

    // MARK: - Initialization

    init(apiService: ExampleAPIServiceProtocol, modelContext: ModelContext) {
        self.apiService = apiService
        self.modelContext = modelContext
    }

    // MARK: - Data Loading

    /// Load items from local database
    @MainActor
    func loadLocalItems() {
        do {
            let descriptor = FetchDescriptor<ExampleItem>(
                sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
            )
            items = try modelContext.fetch(descriptor)
            loadingState = .loaded(items)
        } catch {
            Logger.shared.data("Failed to load local items: \(error)", level: .error)
            loadingState = .error(.persistence(error.localizedDescription))
        }
    }

    /// Refresh items from API
    @MainActor
    func refresh() async {
        loadingState = .loading

        do {
            let response = try await apiService.getItems(page: 1, limit: AppConstants.API.defaultPageSize)

            // Sync with local database
            for itemResponse in response.items {
                if let existingItem = items.first(where: { $0.id == itemResponse.id }) {
                    existingItem.update(title: itemResponse.title, description: itemResponse.description)
                } else {
                    let newItem = ExampleItem(from: itemResponse)
                    modelContext.insert(newItem)
                    items.append(newItem)
                }
            }

            modelContext.saveIfNeeded()

            pagination = PaginationState(
                items: items,
                currentPage: response.page,
                hasMorePages: response.hasNextPage
            )

            loadingState = .loaded(items)
            Logger.shared.data("Refreshed \(response.items.count) items", level: .info)
        } catch {
            loadingState = .error(.from(error))
            Logger.shared.error(error, context: "Failed to refresh items")
        }
    }

    /// Load more items (pagination)
    @MainActor
    func loadMore() async {
        guard pagination.canLoadMore else { return }

        pagination.isLoadingMore = true

        do {
            let nextPage = pagination.currentPage + 1
            let response = try await apiService.getItems(page: nextPage, limit: AppConstants.API.defaultPageSize)

            // Add new items to local database
            for itemResponse in response.items {
                if !items.contains(where: { $0.id == itemResponse.id }) {
                    let newItem = ExampleItem(from: itemResponse)
                    modelContext.insert(newItem)
                    items.append(newItem)
                }
            }

            modelContext.saveIfNeeded()

            pagination.appendPage(
                items.suffix(response.items.count).map { $0 },
                hasMore: response.hasNextPage
            )

            Logger.shared.data("Loaded page \(nextPage) with \(response.items.count) items", level: .debug)
        } catch {
            pagination.error = .from(error)
            pagination.isLoadingMore = false
            Logger.shared.error(error, context: "Failed to load more items")
        }
    }

    // MARK: - Item Actions

    /// Create a new item
    @MainActor
    func createItem(title: String, description: String?) async throws {
        let response = try await apiService.createItem(title: title, description: description)

        let newItem = ExampleItem(from: response)
        modelContext.insert(newItem)
        items.insert(newItem, at: 0)
        modelContext.saveIfNeeded()

        HapticService.shared.success()
        Logger.shared.data("Created item: \(newItem.id)", level: .info)
    }

    /// Delete an item
    @MainActor
    func deleteItem(_ item: ExampleItem) async throws {
        try await apiService.deleteItem(id: item.id)

        modelContext.delete(item)
        items.removeAll { $0.id == item.id }
        modelContext.saveIfNeeded()

        HapticService.shared.itemDeleted()
        Logger.shared.data("Deleted item: \(item.id)", level: .info)
    }

    /// Toggle favorite status
    @MainActor
    func toggleFavorite(_ item: ExampleItem) {
        item.toggleFavorite()
        modelContext.saveIfNeeded()

        HapticService.shared.lightImpact()
        Logger.shared.data("Toggled favorite for: \(item.id)", level: .debug)
    }

    /// Delete multiple items
    @MainActor
    func deleteItems(_ itemsToDelete: [ExampleItem]) async throws {
        for item in itemsToDelete {
            try await deleteItem(item)
        }
    }
}
