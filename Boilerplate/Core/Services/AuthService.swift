import Foundation

/// Authentication service managing user session state
/// Handles login, logout, token management, and user state
@Observable
final class AuthService {
    // MARK: - Properties

    /// Current authenticated user
    private(set) var currentUser: User?

    /// Whether the user is currently authenticated
    var isAuthenticated: Bool {
        currentUser != nil
    }

    /// Loading state for auth operations
    private(set) var isLoading = false

    /// Last authentication error
    private(set) var error: AuthError?

    // MARK: - Dependencies

    private let apiClient: APIClient
    private let keychain: KeychainManager

    // MARK: - Initialization

    init(apiClient: APIClient, keychain: KeychainManager = .shared) {
        self.apiClient = apiClient
        self.keychain = keychain

        // Try to restore session on init
        Task {
            await restoreSession()
        }
    }

    // MARK: - Public Methods

    /// Sign in with email and password
    @MainActor
    func signIn(email: String, password: String) async throws {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            let response: AuthResponse = try await apiClient.request(.login(email: email, password: password))

            // Save tokens
            try keychain.saveString(response.accessToken, for: KeychainManager.Keys.accessToken)
            try keychain.saveString(response.refreshToken, for: KeychainManager.Keys.refreshToken)

            // Update API client with token
            apiClient.setAuthToken(response.accessToken, refresh: response.refreshToken)

            // Update current user
            currentUser = User(from: response.user)

            Logger.shared.auth("User signed in: \(response.user.email)", level: .info)
        } catch let apiError as APIError {
            let authError = AuthError.from(apiError)
            error = authError
            throw authError
        } catch {
            let authError = AuthError.unknown(error.localizedDescription)
            self.error = authError
            throw authError
        }
    }

    /// Sign up with name, email, and password
    @MainActor
    func signUp(name: String, email: String, password: String) async throws {
        isLoading = true
        error = nil

        defer { isLoading = false }

        do {
            let response: AuthResponse = try await apiClient.request(.signUp(name: name, email: email, password: password))

            // Save tokens
            try keychain.saveString(response.accessToken, for: KeychainManager.Keys.accessToken)
            try keychain.saveString(response.refreshToken, for: KeychainManager.Keys.refreshToken)

            // Update API client with token
            apiClient.setAuthToken(response.accessToken, refresh: response.refreshToken)

            // Update current user
            currentUser = User(from: response.user)

            Logger.shared.auth("User signed up: \(response.user.email)", level: .info)
        } catch let apiError as APIError {
            let authError = AuthError.from(apiError)
            error = authError
            throw authError
        } catch {
            let authError = AuthError.unknown(error.localizedDescription)
            self.error = authError
            throw authError
        }
    }

    /// Sign out the current user
    @MainActor
    func signOut() async {
        // Clear local state first
        currentUser = nil
        apiClient.clearAuthToken()

        // Clear keychain
        try? keychain.delete(for: KeychainManager.Keys.accessToken)
        try? keychain.delete(for: KeychainManager.Keys.refreshToken)

        // Notify server (fire and forget)
        Task {
            try? await apiClient.request(.logout) as Data
        }

        Logger.shared.auth("User signed out", level: .info)
    }

    /// Refresh the current user's data
    @MainActor
    func refreshUser() async throws {
        guard isAuthenticated else { return }

        let response: UserResponse = try await apiClient.request(.getCurrentUser)
        currentUser = User(from: response)
    }

    // MARK: - Private Methods

    /// Restore session from stored tokens
    @MainActor
    private func restoreSession() async {
        guard let accessToken = try? keychain.loadString(for: KeychainManager.Keys.accessToken),
              let refreshToken = try? keychain.loadString(for: KeychainManager.Keys.refreshToken) else {
            Logger.shared.auth("No stored session found", level: .debug)
            return
        }

        apiClient.setAuthToken(accessToken, refresh: refreshToken)

        do {
            let response: UserResponse = try await apiClient.request(.getCurrentUser)
            currentUser = User(from: response)
            Logger.shared.auth("Session restored for: \(response.email)", level: .info)
        } catch {
            // Token expired or invalid - clear it
            apiClient.clearAuthToken()
            try? keychain.delete(for: KeychainManager.Keys.accessToken)
            try? keychain.delete(for: KeychainManager.Keys.refreshToken)
            Logger.shared.auth("Failed to restore session: \(error)", level: .warning)
        }
    }
}

// MARK: - Auth Error

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case emailAlreadyExists
    case weakPassword
    case networkError
    case serverError
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .emailAlreadyExists:
            return "An account with this email already exists."
        case .weakPassword:
            return "Password is too weak. Please use a stronger password."
        case .networkError:
            return "Network connection failed. Please check your internet."
        case .serverError:
            return "Server error. Please try again later."
        case .unknown(let message):
            return message
        }
    }

    static func from(_ apiError: APIError) -> AuthError {
        switch apiError {
        case .unauthorized:
            return .invalidCredentials
        case .conflict:
            return .emailAlreadyExists
        case .badRequest(let message) where message?.contains("password") == true:
            return .weakPassword
        case .networkUnavailable:
            return .networkError
        case .serverError:
            return .serverError
        default:
            return .unknown(apiError.localizedDescription)
        }
    }
}
