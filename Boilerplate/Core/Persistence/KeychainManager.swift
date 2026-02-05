import Foundation
import Security

/// Secure storage manager using iOS Keychain
/// Use for storing sensitive data like tokens, passwords, and credentials
final class KeychainManager {
    // MARK: - Singleton

    static let shared = KeychainManager()

    // MARK: - Properties

    private let service: String

    // MARK: - Initialization

    private init() {
        service = Bundle.main.bundleIdentifier ?? "com.boilerplate.app"
    }

    // MARK: - Public Methods

    /// Save data to keychain
    func save(_ data: Data, for key: String) throws {
        // Delete existing item first
        try? delete(for: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }

        Logger.shared.data("Saved to keychain: \(key)", level: .debug)
    }

    /// Load data from keychain
    func load(for key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.loadFailed(status)
        }
    }

    /// Delete data from keychain
    func delete(for key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }

        Logger.shared.data("Deleted from keychain: \(key)", level: .debug)
    }

    /// Check if a key exists in keychain
    func exists(for key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    /// Delete all items for this service
    func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }

        Logger.shared.data("Deleted all keychain items", level: .debug)
    }

    // MARK: - Convenience Methods

    /// Save a string value
    func saveString(_ string: String, for key: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }
        try save(data, for: key)
    }

    /// Load a string value
    func loadString(for key: String) throws -> String? {
        guard let data = try load(for: key) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    /// Save a Codable value
    func saveCodable<T: Encodable>(_ value: T, for key: String) throws {
        let data = try JSONEncoder().encode(value)
        try save(data, for: key)
    }

    /// Load a Codable value
    func loadCodable<T: Decodable>(_ type: T.Type, for key: String) throws -> T? {
        guard let data = try load(for: key) else {
            return nil
        }
        return try JSONDecoder().decode(type, from: data)
    }
}

// MARK: - Keychain Keys

extension KeychainManager {
    enum Keys {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let userId = "userId"
        static let apiKey = "apiKey"
    }
}

// MARK: - Keychain Error

enum KeychainError: Error, LocalizedError {
    case saveFailed(OSStatus)
    case loadFailed(OSStatus)
    case deleteFailed(OSStatus)
    case encodingFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed(let status):
            return "Failed to save to keychain: \(status)"
        case .loadFailed(let status):
            return "Failed to load from keychain: \(status)"
        case .deleteFailed(let status):
            return "Failed to delete from keychain: \(status)"
        case .encodingFailed:
            return "Failed to encode data for keychain"
        }
    }
}
