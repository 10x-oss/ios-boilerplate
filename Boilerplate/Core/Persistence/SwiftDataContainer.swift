import Foundation
import SwiftData

/// SwiftData model container configuration
/// Manages the app's data persistence with optional CloudKit sync
enum SwiftDataContainer {
    // MARK: - Shared Container

    /// Shared model container for the entire app
    static let shared: ModelContainer = {
        let schema = Schema([
            // Add your SwiftData models here
            ExampleItem.self
        ])

        let configuration: ModelConfiguration

        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-inMemoryStore") {
            // Use in-memory store for testing
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: true
            )
        } else {
            configuration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none // Set to .automatic for CloudKit sync
            )
        }
        #else
        configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic // Enable CloudKit sync in production
        )
        #endif

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            // This is a critical error - the app cannot function without persistence
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }()

    // MARK: - Preview Container

    /// In-memory container for SwiftUI previews
    @MainActor
    static var preview: ModelContainer = {
        let schema = Schema([
            ExampleItem.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])

            // Add sample data for previews
            let context = container.mainContext

            let sampleItems = [
                ExampleItem(title: "First Item", itemDescription: "Description for the first item"),
                ExampleItem(title: "Second Item", itemDescription: "Description for the second item"),
                ExampleItem(title: "Third Item", itemDescription: nil)
            ]

            for item in sampleItems {
                context.insert(item)
            }

            return container
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error.localizedDescription)")
        }
    }()

    // MARK: - Test Container

    /// Creates a fresh in-memory container for unit tests
    static func createTestContainer() -> ModelContainer {
        let schema = Schema([
            ExampleItem.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create test ModelContainer: \(error.localizedDescription)")
        }
    }
}

// MARK: - ModelContext Extensions

extension ModelContext {
    /// Save context if there are changes, with error logging
    func saveIfNeeded() {
        guard hasChanges else { return }

        do {
            try save()
        } catch {
            Logger.shared.data("Failed to save context: \(error)", level: .error)
        }
    }

    /// Fetch all items of a type with optional sorting
    func fetchAll<T: PersistentModel>(
        _ type: T.Type,
        sortBy sortDescriptors: [SortDescriptor<T>] = []
    ) throws -> [T] {
        let descriptor = FetchDescriptor<T>(sortBy: sortDescriptors)
        return try fetch(descriptor)
    }

    /// Fetch a single item by predicate
    func fetchFirst<T: PersistentModel>(
        _ type: T.Type,
        where predicate: Predicate<T>
    ) throws -> T? {
        var descriptor = FetchDescriptor<T>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try fetch(descriptor).first
    }
}
