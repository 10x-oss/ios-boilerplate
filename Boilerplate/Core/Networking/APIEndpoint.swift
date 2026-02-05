import Foundation

/// HTTP methods supported by the API client
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// Protocol for type-safe API endpoint definitions
protocol APIEndpointProtocol {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String] { get }
    var queryItems: [URLQueryItem]? { get }
    var body: Encodable? { get }
    var requiresAuth: Bool { get }
}

/// Default implementations for optional properties
extension APIEndpointProtocol {
    var headers: [String: String] { [:] }
    var queryItems: [URLQueryItem]? { nil }
    var body: Encodable? { nil }
    var requiresAuth: Bool { true }
}

/// Example API endpoints demonstrating the pattern
/// Replace with your actual API endpoints
enum APIEndpoint: APIEndpointProtocol {
    // MARK: - Auth Endpoints

    case login(email: String, password: String)
    case signUp(name: String, email: String, password: String)
    case refreshToken(refreshToken: String)
    case logout

    // MARK: - User Endpoints

    case getCurrentUser
    case updateUser(UpdateUserRequest)
    case deleteAccount

    // MARK: - Example Feature Endpoints

    case getItems(page: Int, limit: Int)
    case getItem(id: String)
    case createItem(CreateItemRequest)
    case updateItem(id: String, UpdateItemRequest)
    case deleteItem(id: String)

    // MARK: - APIEndpointProtocol

    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .signUp:
            return "/auth/signup"
        case .refreshToken:
            return "/auth/refresh"
        case .logout:
            return "/auth/logout"
        case .getCurrentUser:
            return "/users/me"
        case .updateUser:
            return "/users/me"
        case .deleteAccount:
            return "/users/me"
        case .getItems:
            return "/items"
        case .getItem(let id):
            return "/items/\(id)"
        case .createItem:
            return "/items"
        case .updateItem(let id, _):
            return "/items/\(id)"
        case .deleteItem(let id):
            return "/items/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .signUp, .refreshToken, .createItem:
            return .post
        case .logout, .getCurrentUser, .getItems, .getItem:
            return .get
        case .updateUser, .updateItem:
            return .put
        case .deleteAccount, .deleteItem:
            return .delete
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .getItems(let page, let limit):
            return [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "limit", value: String(limit))
            ]
        default:
            return nil
        }
    }

    var body: Encodable? {
        switch self {
        case .login(let email, let password):
            return LoginRequest(email: email, password: password)
        case .signUp(let name, let email, let password):
            return SignUpRequest(name: name, email: email, password: password)
        case .refreshToken(let refreshToken):
            return RefreshTokenRequest(refreshToken: refreshToken)
        case .updateUser(let request):
            return request
        case .createItem(let request):
            return request
        case .updateItem(_, let request):
            return request
        default:
            return nil
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .login, .signUp, .refreshToken:
            return false
        default:
            return true
        }
    }
}

// MARK: - Request Models

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct SignUpRequest: Encodable {
    let name: String
    let email: String
    let password: String
}

struct RefreshTokenRequest: Encodable {
    let refreshToken: String
}

struct UpdateUserRequest: Encodable {
    var name: String?
    var email: String?
}

struct CreateItemRequest: Encodable {
    let title: String
    let description: String?
}

struct UpdateItemRequest: Encodable {
    var title: String?
    var description: String?
}

// MARK: - Response Models

struct AuthResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let user: UserResponse
}

struct UserResponse: Decodable {
    let id: String
    let name: String
    let email: String
    let createdAt: Date?
}

struct ItemResponse: Decodable {
    let id: String
    let title: String
    let description: String?
    let createdAt: Date?
    let updatedAt: Date?
}

struct PaginatedResponse<T: Decodable>: Decodable {
    let items: [T]
    let page: Int
    let limit: Int
    let totalItems: Int
    let totalPages: Int

    var hasNextPage: Bool {
        page < totalPages
    }
}
