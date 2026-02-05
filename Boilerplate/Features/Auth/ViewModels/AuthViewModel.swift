import Foundation

/// ViewModel for authentication flows
@Observable
final class AuthViewModel {
    // MARK: - Form State

    var email = ""
    var password = ""
    var confirmPassword = ""
    var name = ""

    // MARK: - Validation Errors

    var emailError: String?
    var passwordError: String?
    var confirmPasswordError: String?
    var nameError: String?

    // MARK: - UI State

    private(set) var isLoading = false
    private(set) var generalError: String?

    // MARK: - Dependencies

    private let authService: AuthService

    // MARK: - Initialization

    init(authService: AuthService) {
        self.authService = authService
    }

    // MARK: - Computed Properties

    var isLoginFormValid: Bool {
        !email.isEmpty && !password.isEmpty && emailError == nil && passwordError == nil
    }

    var isSignUpFormValid: Bool {
        !email.isEmpty &&
            !password.isEmpty &&
            !name.isEmpty &&
            password == confirmPassword &&
            emailError == nil &&
            passwordError == nil &&
            nameError == nil
    }

    // MARK: - Validation

    func validateEmail() {
        let result = FormValidation.validateEmail(email)
        emailError = result.message
    }

    func validatePassword() {
        let result = FormValidation.validatePassword(password)
        passwordError = result.message
    }

    func validateConfirmPassword() {
        if password != confirmPassword {
            confirmPasswordError = "Passwords do not match"
        } else {
            confirmPasswordError = nil
        }
    }

    func validateName() {
        let result = FormValidation.validateRequired(name, fieldName: "Name")
        nameError = result.message
    }

    // MARK: - Actions

    @MainActor
    func login() async -> Bool {
        clearErrors()

        validateEmail()
        validatePassword()

        guard isLoginFormValid else { return false }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.signIn(email: email, password: password)
            Logger.shared.auth("Login successful", level: .info)
            return true
        } catch let error as AuthError {
            generalError = error.localizedDescription
            return false
        } catch {
            generalError = error.localizedDescription
            return false
        }
    }

    @MainActor
    func signUp() async -> Bool {
        clearErrors()

        validateEmail()
        validatePassword()
        validateConfirmPassword()
        validateName()

        guard isSignUpFormValid else { return false }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.signUp(name: name, email: email, password: password)
            Logger.shared.auth("Sign up successful", level: .info)
            return true
        } catch let error as AuthError {
            generalError = error.localizedDescription
            return false
        } catch {
            generalError = error.localizedDescription
            return false
        }
    }

    func resetForm() {
        email = ""
        password = ""
        confirmPassword = ""
        name = ""
        clearErrors()
    }

    private func clearErrors() {
        emailError = nil
        passwordError = nil
        confirmPasswordError = nil
        nameError = nil
        generalError = nil
    }
}
