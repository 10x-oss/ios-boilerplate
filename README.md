# iOS Boilerplate

A production-ready iOS boilerplate with authentication, SwiftData persistence, and modern SwiftUI patterns. Everything you need to ship your iOS app faster.

## Features

- **Architecture** - MVVM with `@Observable` (iOS 17+)
- **Networking** - Protocol-based async/await API client with middleware support
- **Persistence** - SwiftData with CloudKit sync + Keychain + UserDefaults wrapper
- **Navigation** - Type-safe NavigationStack with Router pattern
- **UI Components** - Reusable buttons, forms, loading states, and more
- **Testing** - Swift Testing framework with mocks and helpers
- **Configuration** - Environment-based config (dev/staging/prod)
- **Code Quality** - SwiftLint + SwiftFormat configurations

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/10x-oss/ios-boilerplate.git
cd ios-boilerplate
```

### 2. Open in Xcode

```bash
open Boilerplate.xcodeproj
```

### 3. Configure Your App

1. Update the bundle identifier in project settings
2. Configure `AppEnvironment.swift` with your API URLs
3. Update app icons and launch screen
4. Configure signing and capabilities

### 4. Build and Run

Select a simulator or device and press `⌘R` to build and run.

## Project Structure

```
ios-boilerplate/
├── Boilerplate/
│   ├── App/                    # App entry point and environment
│   │   ├── BoilerplateApp.swift
│   │   └── Environment/
│   │       ├── AppEnvironment.swift
│   │       └── FeatureFlags.swift
│   │
│   ├── Core/                   # Core infrastructure
│   │   ├── Networking/         # API client and endpoints
│   │   ├── Persistence/        # SwiftData, Keychain, UserDefaults
│   │   ├── Navigation/         # Router and routes
│   │   ├── Services/           # Auth, Analytics, Haptics
│   │   └── Logging/            # Unified logging
│   │
│   ├── Shared/                 # Shared code
│   │   ├── Extensions/         # Swift extensions
│   │   ├── Constants/          # App and UI constants
│   │   ├── Styles/             # Theme and button styles
│   │   ├── Components/         # Reusable UI components
│   │   ├── ViewModifiers/      # Custom view modifiers
│   │   └── Types/              # Common types (LoadingState, etc.)
│   │
│   ├── Features/               # Feature modules
│   │   ├── Auth/               # Authentication
│   │   ├── Settings/           # Settings screen
│   │   └── Example/            # Complete example feature
│   │
│   └── Resources/              # Assets, localization, Info.plist
│
├── BoilerplateTests/           # Unit tests
└── BoilerplateUITests/         # UI tests
```

## Architecture

### MVVM with @Observable

ViewModels use Swift's `@Observable` macro for reactive state management:

```swift
@Observable
final class ExampleListViewModel {
    private(set) var items: [ExampleItem] = []
    private(set) var loadingState: LoadingState<[ExampleItem]> = .idle

    func loadItems() async { ... }
}
```

### Dependency Injection

Dependencies are injected via SwiftUI's environment:

```swift
@main
struct BoilerplateApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(APIClient())
                .environment(Router.shared)
        }
    }
}
```

### Type-Safe Navigation

Navigation uses a centralized router with type-safe routes:

```swift
enum Route: Hashable {
    case home
    case exampleList
    case exampleDetail(id: String)
    case settings
}

// Navigate from anywhere
router.navigate(to: .exampleDetail(id: "123"))
```

## Key Components

### Networking

```swift
// Define endpoints
enum APIEndpoint {
    case getItems(page: Int, limit: Int)
    case createItem(CreateItemRequest)
}

// Make requests
let items: [Item] = try await apiClient.request(.getItems(page: 1, limit: 20))
```

### Persistence

```swift
// SwiftData models
@Model
final class ExampleItem {
    var title: String
    var description: String?
}

// UserDefaults wrapper
@UserDefault(key: "hasCompletedOnboarding", defaultValue: false)
static var hasCompletedOnboarding: Bool

// Keychain storage
try KeychainManager.shared.saveString(token, for: "accessToken")
```

### UI Components

```swift
// Primary button with loading state
PrimaryButton(title: "Submit", isLoading: isLoading) {
    await submit()
}

// Form text field with validation
FormTextField(
    label: "Email",
    text: $email,
    validationMessage: emailError
)

// Loading/Error/Empty states
switch loadingState {
case .loading:
    LoadingView()
case .error(let error):
    ErrorView(error: error, onRetry: refresh)
case .loaded(let data):
    ContentView(data: data)
}
```

## Configuration

### Environment Variables

Configure environments in `AppEnvironment.swift`:

```swift
enum AppEnvironment {
    case development
    case staging
    case production

    var baseURL: URL {
        switch self {
        case .development: return URL(string: "https://api-dev.example.com")!
        case .staging: return URL(string: "https://api-staging.example.com")!
        case .production: return URL(string: "https://api.example.com")!
        }
    }
}
```

### Feature Flags

Enable/disable features in `FeatureFlags.swift`:

```swift
@Observable
final class FeatureFlags {
    var newOnboardingEnabled = false
    var analyticsEnabled = true
}
```

## Testing

### Run Tests

```bash
# Unit tests
xcodebuild test -scheme Boilerplate -destination 'platform=iOS Simulator,name=iPhone 15'

# Or use Xcode: ⌘U
```

### Writing Tests

```swift
import Testing
@testable import Boilerplate

@Test("ViewModel loads items successfully")
func testLoadItems() async throws {
    let mockAPI = MockAPIClient()
    let viewModel = ExampleListViewModel(apiService: mockAPI)

    await viewModel.refresh()

    #expect(viewModel.items.count > 0)
    #expect(viewModel.loadingState.isLoaded)
}
```

## Code Quality

### SwiftLint

```bash
# Install SwiftLint
brew install swiftlint

# Run linter
swiftlint lint
```

### SwiftFormat

```bash
# Install SwiftFormat
brew install swiftformat

# Format code
swiftformat .
```

## License

MIT License - see [LICENSE](LICENSE) for details.

---

Built with the [10x-oss](https://github.com/10x-oss) boilerplate.
