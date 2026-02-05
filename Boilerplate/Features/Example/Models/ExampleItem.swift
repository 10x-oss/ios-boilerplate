import Foundation
import SwiftData

/// Example SwiftData model demonstrating persistence patterns
@Model
final class ExampleItem {
    // MARK: - Properties

    /// Unique identifier
    @Attribute(.unique) var id: String

    /// Item title
    var title: String

    /// Optional description
    var itemDescription: String?

    /// Whether the item is marked as favorite
    var isFavorite: Bool

    /// Creation timestamp
    var createdAt: Date

    /// Last update timestamp
    var updatedAt: Date

    // MARK: - Initialization

    init(
        id: String = UUID().uuidString,
        title: String,
        itemDescription: String? = nil,
        isFavorite: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.itemDescription = itemDescription
        self.isFavorite = isFavorite
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// Create from API response
    convenience init(from response: ItemResponse) {
        self.init(
            id: response.id,
            title: response.title,
            itemDescription: response.description,
            createdAt: response.createdAt ?? Date(),
            updatedAt: response.updatedAt ?? Date()
        )
    }

    // MARK: - Methods

    func update(title: String, description: String?) {
        self.title = title
        itemDescription = description
        updatedAt = Date()
    }

    func toggleFavorite() {
        isFavorite.toggle()
        updatedAt = Date()
    }
}

// MARK: - Equatable

extension ExampleItem: Equatable {
    static func == (lhs: ExampleItem, rhs: ExampleItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Hashable

extension ExampleItem: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Mock Data

#if DEBUG
extension ExampleItem {
    static let preview = ExampleItem(
        title: "Sample Item",
        itemDescription: "This is a sample item for previews"
    )

    static let previewList: [ExampleItem] = [
        ExampleItem(title: "First Item", itemDescription: "Description for first item"),
        ExampleItem(title: "Second Item", itemDescription: nil, isFavorite: true),
        ExampleItem(title: "Third Item", itemDescription: "A longer description that might wrap to multiple lines in the UI"),
        ExampleItem(title: "Fourth Item", itemDescription: "Short desc"),
        ExampleItem(title: "Fifth Item", itemDescription: nil)
    ]
}
#endif
