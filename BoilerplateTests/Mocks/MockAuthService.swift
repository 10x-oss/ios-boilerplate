import Foundation
@testable import Boilerplate

/// Mock auth service for testing
@Observable
final class MockAuthService {
    // MARK: - Mock State

    var mockUser: User?
    var shouldFailLogin = false
    var shouldFailSignUp = false
    var loginError: AuthError = .invalidCredentials
    var signUpError: AuthError = .emailAlreadyExists

    // MARK: - Counters

    var loginCallCount = 0
    var signUpCallCount = 0
    var signOutCallCount = 0

    // MARK: - Last Call Parameters

    var lastLoginEmail: String?
    var lastLoginPassword: String?
    var lastSignUpName: String?
    var lastSignUpEmail: String?
    var lastSignUpPassword: String?

    // MARK: - Properties

    var currentUser: User? {
        mockUser
    }

    var isAuthenticated: Bool {
        mockUser != nil
    }

    // MARK: - Mock Methods

    @MainActor
    func signIn(email: String, password: String) async throws {
        loginCallCount += 1
        lastLoginEmail = email
        lastLoginPassword = password

        if shouldFailLogin {
            throw loginError
        }

        mockUser = User(
            id: "mock_user_\(UUID().uuidString)",
            name: "Test User",
            email: email
        )
    }

    @MainActor
    func signUp(name: String, email: String, password: String) async throws {
        signUpCallCount += 1
        lastSignUpName = name
        lastSignUpEmail = email
        lastSignUpPassword = password

        if shouldFailSignUp {
            throw signUpError
        }

        mockUser = User(
            id: "mock_user_\(UUID().uuidString)",
            name: name,
            email: email
        )
    }

    @MainActor
    func signOut() async {
        signOutCallCount += 1
        mockUser = nil
    }

    // MARK: - Test Helpers

    func reset() {
        mockUser = nil
        shouldFailLogin = false
        shouldFailSignUp = false
        loginCallCount = 0
        signUpCallCount = 0
        signOutCallCount = 0
        lastLoginEmail = nil
        lastLoginPassword = nil
        lastSignUpName = nil
        lastSignUpEmail = nil
        lastSignUpPassword = nil
    }

    func setAuthenticatedUser(_ user: User) {
        mockUser = user
    }
}
