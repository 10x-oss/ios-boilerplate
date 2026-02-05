import Foundation

/// User model representing an authenticated user
struct User: Identifiable, Codable, Equatable, Sendable {
    // MARK: - Properties

    let id: String
    let name: String
    let email: String
    let avatarURL: URL?
    let createdAt: Date?

    // MARK: - Initialization

    init(
        id: String,
        name: String,
        email: String,
        avatarURL: URL? = nil,
        createdAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.createdAt = createdAt
    }

    /// Create a User from API response
    init(from response: UserResponse) {
        id = response.id
        name = response.name
        email = response.email
        avatarURL = nil
        createdAt = response.createdAt
    }

    // MARK: - Computed Properties

    /// First name extracted from full name
    var firstName: String {
        name.components(separatedBy: " ").first ?? name
    }

    /// Last name extracted from full name
    var lastName: String? {
        let components = name.components(separatedBy: " ")
        guard components.count > 1 else { return nil }
        return components.dropFirst().joined(separator: " ")
    }

    /// Initials for avatar placeholder
    var initials: String {
        let components = name.components(separatedBy: " ")
        let firstInitial = components.first?.first.map(String.init) ?? ""
        let lastInitial = components.count > 1 ? components.last?.first.map(String.init) ?? "" : ""
        return (firstInitial + lastInitial).uppercased()
    }
}

// MARK: - Mock Data

#if DEBUG
extension User {
    static let preview = User(
        id: "user_123",
        name: "John Doe",
        email: "john@example.com",
        avatarURL: URL(string: "https://example.com/avatar.jpg"),
        createdAt: Date()
    )

    static let previewList = [
        User(id: "1", name: "Alice Smith", email: "alice@example.com"),
        User(id: "2", name: "Bob Johnson", email: "bob@example.com"),
        User(id: "3", name: "Carol Williams", email: "carol@example.com")
    ]
}
#endif
