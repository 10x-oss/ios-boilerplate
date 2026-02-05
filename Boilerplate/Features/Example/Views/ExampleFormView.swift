import SwiftData
import SwiftUI

/// Example form view for creating/editing items
struct ExampleFormView: View {
    // MARK: - Properties

    var viewModel: ExampleListViewModel?
    var existingItem: ExampleItem?

    // MARK: - Environment

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // MARK: - State

    @State private var title = ""
    @State private var description = ""
    @State private var isSaving = false
    @State private var error: String?

    @FocusState private var focusedField: Field?

    // MARK: - Computed Properties

    private var isEditing: Bool {
        existingItem != nil
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var hasChanges: Bool {
        if let existingItem {
            return title != existingItem.title ||
                description != (existingItem.itemDescription ?? "")
        }
        return !title.isEmpty || !description.isEmpty
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // Title section
                Section {
                    TextField("Title", text: $title)
                        .focused($focusedField, equals: .title)
                } header: {
                    Text("Title")
                } footer: {
                    if title.isEmpty {
                        Text("Title is required")
                            .foregroundStyle(.red)
                    }
                }

                // Description section
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .focused($focusedField, equals: .description)
                }

                // Error
                if let error {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Item" : "New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Create") {
                        Task {
                            await save()
                        }
                    }
                    .disabled(!isFormValid || isSaving)
                }
            }
            .interactiveDismissDisabled(hasChanges)
            .loadingOverlay(isSaving, message: isEditing ? "Saving..." : "Creating...")
        }
        .onAppear {
            loadExistingData()
            focusedField = .title
        }
    }

    // MARK: - Field Enum

    private enum Field {
        case title
        case description
    }

    // MARK: - Methods

    private func loadExistingData() {
        if let existingItem {
            title = existingItem.title
            description = existingItem.itemDescription ?? ""
        }
    }

    private func save() async {
        guard isFormValid else { return }

        isSaving = true
        error = nil

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedDescription = description.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalDescription = trimmedDescription.isEmpty ? nil : trimmedDescription

        do {
            if let existingItem {
                // Update existing item
                existingItem.update(title: trimmedTitle, description: finalDescription)
                modelContext.saveIfNeeded()
                HapticService.shared.success()
                Logger.shared.data("Updated item: \(existingItem.id)", level: .info)
            } else if let viewModel {
                // Create new item via API
                try await viewModel.createItem(title: trimmedTitle, description: finalDescription)
            } else {
                // Create locally without API
                let newItem = ExampleItem(title: trimmedTitle, itemDescription: finalDescription)
                modelContext.insert(newItem)
                modelContext.saveIfNeeded()
                HapticService.shared.success()
                Logger.shared.data("Created local item: \(newItem.id)", level: .info)
            }

            dismiss()
        } catch {
            self.error = error.localizedDescription
            HapticService.shared.error()
            Logger.shared.error(error, context: "Failed to save item")
        }

        isSaving = false
    }
}

// MARK: - Preview

#Preview("Create") {
    ExampleFormView()
        .modelContainer(SwiftDataContainer.preview)
}

#Preview("Edit") {
    ExampleFormView(existingItem: .preview)
        .modelContainer(SwiftDataContainer.preview)
}
