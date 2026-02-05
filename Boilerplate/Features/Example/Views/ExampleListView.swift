import SwiftData
import SwiftUI

/// Example list view demonstrating common list patterns
struct ExampleListView: View {
    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(APIClient.self) private var apiClient
    @Environment(Router.self) private var router

    // MARK: - State

    @State private var viewModel: ExampleListViewModel?
    @State private var showingAddSheet = false
    @State private var selectedItems: Set<ExampleItem> = []
    @State private var isEditing = false

    // MARK: - Body

    var body: some View {
        Group {
            if let viewModel {
                contentView(viewModel)
            } else {
                LoadingView(message: "Loading...")
            }
        }
        .navigationTitle("Items")
        .toolbar {
            toolbarContent
        }
        .searchable(
            text: Binding(
                get: { viewModel?.searchText ?? "" },
                set: { viewModel?.searchText = $0 }
            ),
            prompt: "Search items"
        )
        .sheet(isPresented: $showingAddSheet) {
            if let viewModel {
                ExampleFormView(viewModel: viewModel)
            }
        }
        .onAppear {
            setupViewModel()
        }
    }

    // MARK: - Content View

    @ViewBuilder
    private func contentView(_ viewModel: ExampleListViewModel) -> some View {
        switch viewModel.loadingState {
        case .idle, .loading where viewModel.items.isEmpty:
            LoadingView(message: "Loading items...")

        case .error(let error) where viewModel.items.isEmpty:
            ErrorView(error: error) {
                Task { await viewModel.refresh() }
            }

        default:
            if viewModel.isEmpty {
                emptyState
            } else {
                listContent(viewModel)
            }
        }
    }

    private var emptyState: some View {
        EmptyStateView(
            icon: "tray",
            title: "No Items",
            message: "Create your first item to get started.",
            actionTitle: "Add Item"
        ) {
            showingAddSheet = true
        }
    }

    private func listContent(_ viewModel: ExampleListViewModel) -> some View {
        List(selection: isEditing ? $selectedItems : nil) {
            ForEach(viewModel.filteredItems, id: \.id) { item in
                itemRow(item, viewModel: viewModel)
            }
            .onDelete { indexSet in
                deleteItems(at: indexSet, viewModel: viewModel)
            }

            // Load more indicator
            if viewModel.pagination.canLoadMore {
                loadMoreRow(viewModel)
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await viewModel.refresh()
        }
        .environment(\.editMode, .constant(isEditing ? .active : .inactive))
    }

    private func itemRow(_ item: ExampleItem, viewModel: ExampleListViewModel) -> some View {
        Button {
            router.navigate(to: .exampleDetail(id: item.id))
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: UIConstants.Spacing.xs) {
                    Text(item.title)
                        .font(AppTheme.Typography.headline)
                        .foregroundStyle(AppTheme.Colors.text)

                    if let description = item.itemDescription {
                        Text(description)
                            .font(AppTheme.Typography.subheadline)
                            .foregroundStyle(AppTheme.Colors.secondaryText)
                            .lineLimit(2)
                    }

                    Text(item.updatedAt.relativeFormatted)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.tertiaryText)
                }

                Spacer()

                if item.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                Task {
                    try? await viewModel.deleteItem(item)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                viewModel.toggleFavorite(item)
            } label: {
                Label(
                    item.isFavorite ? "Unfavorite" : "Favorite",
                    systemImage: item.isFavorite ? "star.slash" : "star"
                )
            }
            .tint(.yellow)
        }
    }

    private func loadMoreRow(_ viewModel: ExampleListViewModel) -> some View {
        HStack {
            Spacer()
            if viewModel.pagination.isLoadingMore {
                ProgressView()
            } else {
                Button("Load More") {
                    Task { await viewModel.loadMore() }
                }
            }
            Spacer()
        }
        .onAppear {
            Task { await viewModel.loadMore() }
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                showingAddSheet = true
            } label: {
                Image(systemName: "plus")
            }
        }

        ToolbarItem(placement: .secondaryAction) {
            Button(isEditing ? "Done" : "Edit") {
                withAnimation {
                    isEditing.toggle()
                    if !isEditing {
                        selectedItems.removeAll()
                    }
                }
            }
        }

        if isEditing && !selectedItems.isEmpty {
            ToolbarItem(placement: .bottomBar) {
                Button("Delete \(selectedItems.count) Items", role: .destructive) {
                    Task {
                        try? await viewModel?.deleteItems(Array(selectedItems))
                        selectedItems.removeAll()
                        isEditing = false
                    }
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func setupViewModel() {
        if viewModel == nil {
            let service = ExampleAPIService(apiClient: apiClient)
            viewModel = ExampleListViewModel(apiService: service, modelContext: modelContext)
            viewModel?.loadLocalItems()

            Task {
                await viewModel?.refresh()
            }
        }
    }

    private func deleteItems(at indexSet: IndexSet, viewModel: ExampleListViewModel) {
        let itemsToDelete = indexSet.map { viewModel.filteredItems[$0] }
        Task {
            try? await viewModel.deleteItems(itemsToDelete)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ExampleListView()
    }
    .modelContainer(SwiftDataContainer.preview)
    .environment(APIClient())
    .environment(Router.shared)
}
