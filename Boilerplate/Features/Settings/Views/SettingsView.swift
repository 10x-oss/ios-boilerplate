import SwiftUI

/// Settings screen view
struct SettingsView: View {
    // MARK: - Environment

    @Environment(AuthService.self) private var authService
    @Environment(AnalyticsService.self) private var analyticsService
    @Environment(Router.self) private var router

    // MARK: - State

    @State private var viewModel: SettingsViewModel?
    @State private var showingSignOutConfirmation = false
    @State private var showingClearCacheConfirmation = false

    #if DEBUG
    @State private var showingResetDataConfirmation = false
    #endif

    // MARK: - Body

    var body: some View {
        List {
            if let viewModel {
                // Account section
                accountSection

                // Preferences section
                preferencesSection(viewModel)

                // Appearance section
                appearanceSection(viewModel)

                // Support section
                supportSection

                // About section
                aboutSection(viewModel)

                #if DEBUG
                // Debug section
                debugSection(viewModel)
                #endif

                // Sign out
                signOutSection
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            if viewModel == nil {
                viewModel = SettingsViewModel(
                    authService: authService,
                    analyticsService: analyticsService
                )
            }
        }
        .confirmationDialog(
            "Sign Out",
            isPresented: $showingSignOutConfirmation,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                Task {
                    await viewModel?.signOut()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to sign out?")
        }
        .confirmationDialog(
            "Clear Cache",
            isPresented: $showingClearCacheConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear Cache", role: .destructive) {
                viewModel?.clearCache()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will clear all cached data. You may need to re-download some content.")
        }
        #if DEBUG
            .confirmationDialog(
                "Reset All Data",
                isPresented: $showingResetDataConfirmation,
                titleVisibility: .visible
            ) {
                Button("Reset All Data", role: .destructive) {
                    viewModel?.resetAllData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will delete all app data including your account. This cannot be undone.")
            }
        #endif
    }

    // MARK: - Sections

    private var accountSection: some View {
        Section("Account") {
            if let user = authService.currentUser {
                NavigationLink {
                    ProfileView()
                } label: {
                    HStack(spacing: UIConstants.Spacing.md) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(Color.accentColor.opacity(0.2))

                            Text(user.initials)
                                .font(.headline)
                                .foregroundStyle(.accentColor)
                        }
                        .frame(width: UIConstants.AvatarSize.medium, height: UIConstants.AvatarSize.medium)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(user.name)
                                .font(.headline)

                            Text(user.email)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, UIConstants.Spacing.xs)
                }
            }
        }
    }

    private func preferencesSection(_ viewModel: SettingsViewModel) -> some View {
        Section("Preferences") {
            Toggle("Haptic Feedback", isOn: Binding(
                get: { viewModel.hapticsEnabled },
                set: { viewModel.hapticsEnabled = $0 }
            ))

            Toggle("Sound Effects", isOn: Binding(
                get: { viewModel.soundsEnabled },
                set: { viewModel.soundsEnabled = $0 }
            ))

            Toggle("Notifications", isOn: Binding(
                get: { viewModel.notificationsEnabled },
                set: { viewModel.notificationsEnabled = $0 }
            ))
        }
    }

    private func appearanceSection(_ viewModel: SettingsViewModel) -> some View {
        Section("Appearance") {
            Picker("Theme", selection: Binding(
                get: { viewModel.selectedTheme },
                set: { viewModel.selectedTheme = $0 }
            )) {
                ForEach(AppThemeOption.allCases) { theme in
                    Label(theme.displayName, systemImage: theme.icon)
                        .tag(theme)
                }
            }
        }
    }

    private var supportSection: some View {
        Section("Support") {
            Link(destination: AppConstants.Support.helpURL) {
                Label("Help Center", systemImage: "questionmark.circle")
            }

            Button {
                // TODO: Open email composer
            } label: {
                Label("Contact Support", systemImage: "envelope")
            }

            Link(destination: AppConstants.Support.privacyURL) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }

            Link(destination: AppConstants.Support.termsURL) {
                Label("Terms of Service", systemImage: "doc.text")
            }
        }
    }

    private func aboutSection(_ viewModel: SettingsViewModel) -> some View {
        Section("About") {
            LabeledContent("Version", value: viewModel.appVersion)
            LabeledContent("Build", value: viewModel.buildNumber)

            Button {
                showingClearCacheConfirmation = true
            } label: {
                Label("Clear Cache", systemImage: "trash")
            }
        }
    }

    #if DEBUG
    private func debugSection(_ viewModel: SettingsViewModel) -> some View {
        Section("Debug") {
            Button {
                viewModel.resetOnboarding()
            } label: {
                Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
            }

            Button(role: .destructive) {
                showingResetDataConfirmation = true
            } label: {
                Label("Reset All Data", systemImage: "exclamationmark.triangle")
            }
        }
    }
    #endif

    private var signOutSection: some View {
        Section {
            Button(role: .destructive) {
                showingSignOutConfirmation = true
            } label: {
                HStack {
                    Spacer()
                    Text("Sign Out")
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView()
    }
    .environment(AuthService(apiClient: APIClient()))
    .environment(AnalyticsService())
    .environment(Router.shared)
}
