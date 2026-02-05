import Foundation

/// Form validation utilities
enum FormValidation {
    // MARK: - Validation Result

    struct ValidationResult {
        let isValid: Bool
        let message: String?

        static let valid = ValidationResult(isValid: true, message: nil)

        static func invalid(_ message: String) -> ValidationResult {
            ValidationResult(isValid: false, message: message)
        }
    }

    // MARK: - Email Validation

    static func validateEmail(_ email: String) -> ValidationResult {
        guard !email.isEmpty else {
            return .invalid("Email is required")
        }

        let emailRegex = AppConstants.Validation.emailPattern
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        guard emailPredicate.evaluate(with: email) else {
            return .invalid("Please enter a valid email address")
        }

        return .valid
    }

    // MARK: - Password Validation

    static func validatePassword(_ password: String) -> ValidationResult {
        guard !password.isEmpty else {
            return .invalid("Password is required")
        }

        guard password.count >= AppConstants.Validation.minPasswordLength else {
            return .invalid("Password must be at least \(AppConstants.Validation.minPasswordLength) characters")
        }

        guard password.count <= AppConstants.Validation.maxPasswordLength else {
            return .invalid("Password must be less than \(AppConstants.Validation.maxPasswordLength) characters")
        }

        // Check for at least one uppercase letter
        let hasUppercase = password.range(of: "[A-Z]", options: .regularExpression) != nil
        guard hasUppercase else {
            return .invalid("Password must contain at least one uppercase letter")
        }

        // Check for at least one lowercase letter
        let hasLowercase = password.range(of: "[a-z]", options: .regularExpression) != nil
        guard hasLowercase else {
            return .invalid("Password must contain at least one lowercase letter")
        }

        // Check for at least one digit
        let hasDigit = password.range(of: "[0-9]", options: .regularExpression) != nil
        guard hasDigit else {
            return .invalid("Password must contain at least one number")
        }

        return .valid
    }

    // MARK: - Username Validation

    static func validateUsername(_ username: String) -> ValidationResult {
        guard !username.isEmpty else {
            return .invalid("Username is required")
        }

        guard username.count >= AppConstants.Validation.minUsernameLength else {
            return .invalid("Username must be at least \(AppConstants.Validation.minUsernameLength) characters")
        }

        guard username.count <= AppConstants.Validation.maxUsernameLength else {
            return .invalid("Username must be less than \(AppConstants.Validation.maxUsernameLength) characters")
        }

        // Check for valid characters (alphanumeric and underscores only)
        let validCharacters = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "_"))
        guard username.unicodeScalars.allSatisfy({ validCharacters.contains($0) }) else {
            return .invalid("Username can only contain letters, numbers, and underscores")
        }

        // Check that it doesn't start with a number
        guard !username.first!.isNumber else {
            return .invalid("Username cannot start with a number")
        }

        return .valid
    }

    // MARK: - Required Field Validation

    static func validateRequired(_ value: String, fieldName: String) -> ValidationResult {
        guard !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .invalid("\(fieldName) is required")
        }
        return .valid
    }

    // MARK: - Length Validation

    static func validateLength(
        _ value: String,
        min: Int? = nil,
        max: Int? = nil,
        fieldName: String
    ) -> ValidationResult {
        if let min, value.count < min {
            return .invalid("\(fieldName) must be at least \(min) characters")
        }

        if let max, value.count > max {
            return .invalid("\(fieldName) must be less than \(max) characters")
        }

        return .valid
    }

    // MARK: - URL Validation

    static func validateURL(_ urlString: String) -> ValidationResult {
        guard !urlString.isEmpty else {
            return .invalid("URL is required")
        }

        guard URL(string: urlString) != nil else {
            return .invalid("Please enter a valid URL")
        }

        return .valid
    }

    // MARK: - Phone Validation

    static func validatePhone(_ phone: String) -> ValidationResult {
        guard !phone.isEmpty else {
            return .invalid("Phone number is required")
        }

        // Remove non-digit characters for validation
        let digitsOnly = phone.filter { $0.isNumber }

        guard digitsOnly.count >= 10, digitsOnly.count <= 15 else {
            return .invalid("Please enter a valid phone number")
        }

        return .valid
    }

    // MARK: - Match Validation

    static func validateMatch(
        _ value: String,
        matches other: String,
        fieldName: String
    ) -> ValidationResult {
        guard value == other else {
            return .invalid("\(fieldName) does not match")
        }
        return .valid
    }
}

// MARK: - Form Validator

/// Observable form validator for managing multiple field validations
@Observable
final class FormValidator {
    // MARK: - Properties

    private(set) var errors: [String: String] = [:]

    var isValid: Bool {
        errors.isEmpty
    }

    // MARK: - Methods

    func validate(
        _ field: String,
        value: String,
        rules: [ValidationRule]
    ) -> Bool {
        for rule in rules {
            let result = rule.validate(value)
            if !result.isValid {
                errors[field] = result.message
                return false
            }
        }

        errors.removeValue(forKey: field)
        return true
    }

    func error(for field: String) -> String? {
        errors[field]
    }

    func clearError(for field: String) {
        errors.removeValue(forKey: field)
    }

    func clearAllErrors() {
        errors.removeAll()
    }
}

// MARK: - Validation Rule

struct ValidationRule {
    let validate: (String) -> FormValidation.ValidationResult

    static func required(_ fieldName: String) -> ValidationRule {
        ValidationRule { value in
            FormValidation.validateRequired(value, fieldName: fieldName)
        }
    }

    static var email: ValidationRule {
        ValidationRule { value in
            FormValidation.validateEmail(value)
        }
    }

    static var password: ValidationRule {
        ValidationRule { value in
            FormValidation.validatePassword(value)
        }
    }

    static var username: ValidationRule {
        ValidationRule { value in
            FormValidation.validateUsername(value)
        }
    }

    static func minLength(_ length: Int, fieldName: String) -> ValidationRule {
        ValidationRule { value in
            FormValidation.validateLength(value, min: length, fieldName: fieldName)
        }
    }

    static func maxLength(_ length: Int, fieldName: String) -> ValidationRule {
        ValidationRule { value in
            FormValidation.validateLength(value, max: length, fieldName: fieldName)
        }
    }

    static func matches(_ other: String, fieldName: String) -> ValidationRule {
        ValidationRule { value in
            FormValidation.validateMatch(value, matches: other, fieldName: fieldName)
        }
    }
}
