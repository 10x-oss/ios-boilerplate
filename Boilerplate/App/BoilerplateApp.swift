import SwiftData
import SwiftUI

@main
struct BoilerplateApp: App {
    // MARK: - Dependencies

    private let router = Router.shared
    private let apiClient = APIClient()
    private let authService: AuthService
    private let analyticsService = AnalyticsService()

    // MARK: - Initialization

    init() {
        authService = AuthService(apiClient: apiClient)
        configureAppearance()
    }

    // MARK: - Body

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
                .environment(apiClient)
                .environment(authService)
                .environment(analyticsService)
        }
        .modelContainer(SwiftDataContainer.shared)
    }

    // MARK: - Private Methods

    private func configureAppearance() {
        // Configure global appearance settings
        #if DEBUG
        Logger.shared.app("App launched in \(AppEnvironment.current.rawValue) mode")
        #endif
    }
}

// MARK: - Root View

struct RootView: View {
    @Environment(Router.self) private var router
    @Environment(AuthService.self) private var authService

    var body: some View {
        @Bindable var router = router

        NavigationStack(path: $router.path) {
            Group {
                if authService.isAuthenticated {
                    HomeView()
                } else if UserDefaultsWrapper.hasCompletedOnboarding {
                    LoginView()
                } else {
                    OnboardingView()
                }
            }
            .navigationDestination(for: Route.self) { route in
                destinationView(for: route)
            }
        }
        .sheet(item: $router.presentedSheet) { sheet in
            sheetView(for: sheet)
        }
    }

    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .home:
            HomeView()
        case .exampleList:
            ExampleListView()
        case .exampleDetail(let id):
            ExampleDetailView(itemId: id)
        case .exampleForm(let item):
            ExampleFormView(existingItem: item)
        case .settings:
            SettingsView()
        case .profile:
            ProfileView()
        }
    }

    @ViewBuilder
    private func sheetView(for sheet: Sheet) -> some View {
        switch sheet {
        case .login:
            LoginView()
        case .signUp:
            SignUpView()
        }
    }
}

// MARK: - Home View (Placeholder)

struct HomeView: View {
    @Environment(Router.self) private var router

    var body: some View {
        List {
            Section("Features") {
                Button("Example Feature") {
                    router.navigate(to: .exampleList)
                }
            }

            Section("Account") {
                Button("Settings") {
                    router.navigate(to: .settings)
                }
            }
        }
        .navigationTitle("Home")
    }
}

// MARK: - Onboarding View (Placeholder)

struct OnboardingView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "star.fill")
                .font(.system(size: 80))
                .foregroundStyle(.accent)

            Text("Welcome to Boilerplate")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Your starting point for building great iOS apps")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            PrimaryButton(title: "Get Started") {
                UserDefaultsWrapper.hasCompletedOnboarding = true
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

// MARK: - Profile View (Placeholder)

struct ProfileView: View {
    @Environment(AuthService.self) private var authService

    var body: some View {
        List {
            if let user = authService.currentUser {
                Section {
                    LabeledContent("Name", value: user.name)
                    LabeledContent("Email", value: user.email)
                }
            }

            Section {
                Button("Sign Out", role: .destructive) {
                    Task {
                        await authService.signOut()
                    }
                }
            }
        }
        .navigationTitle("Profile")
    }
}
