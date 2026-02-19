//
//  TemplateLibraryView.swift
//  habbit
//
//  Browse and manage all habit templates (active and inactive)
//

import SwiftUI

struct TemplateLibraryView: View {
    @State private var viewModel = TemplateViewModel()
    @State private var showingCreateSheet = false
    @State private var showingEditSheet = false
    @State private var selectedTemplate: HabitTemplate?
    @State private var showingDeleteAlert = false
    @State private var templateToDelete: HabitTemplate?

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.templates.isEmpty {
                    emptyStateView
                } else {
                    templateList
                }
            }
            .navigationTitle("Habit Templates")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.theme.primary)
                    }
                }
            }
            .sheet(isPresented: $showingCreateSheet) {
                TemplateFormView(viewModel: viewModel, template: nil)
            }
            .sheet(isPresented: $showingEditSheet) {
                if let template = selectedTemplate {
                    TemplateFormView(viewModel: viewModel, template: template)
                }
            }
            .alert("Delete Template", isPresented: $showingDeleteAlert, presenting: templateToDelete) { template in
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        await viewModel.deleteTemplate(template)
                    }
                }
            } message: { template in
                Text("Are you sure you want to delete '\(template.name)'? This will also delete all completion history.")
            }
            .task {
                await viewModel.loadTemplates()
            }
            .refreshable {
                await viewModel.loadTemplates()
            }
        }
    }

    // MARK: - Subviews

    private var templateList: some View {
        List {
            // Active Templates Section
            if !viewModel.activeTemplates.isEmpty {
                Section {
                    ForEach(viewModel.activeTemplates) { template in
                        TemplateRow(
                            template: template,
                            onToggle: {
                                Task {
                                    await viewModel.toggleActive(for: template)
                                }
                            },
                            onEdit: {
                                selectedTemplate = template
                                showingEditSheet = true
                            },
                            onDelete: {
                                templateToDelete = template
                                showingDeleteAlert = true
                            }
                        )
                    }
                } header: {
                    Text("ACTIVE (\(viewModel.activeTemplates.count))")
                }
            }

            // Inactive Templates Section
            if !viewModel.inactiveTemplates.isEmpty {
                Section {
                    ForEach(viewModel.inactiveTemplates) { template in
                        TemplateRow(
                            template: template,
                            onToggle: {
                                Task {
                                    await viewModel.toggleActive(for: template)
                                }
                            },
                            onEdit: {
                                selectedTemplate = template
                                showingEditSheet = true
                            },
                            onDelete: {
                                templateToDelete = template
                                showingDeleteAlert = true
                            }
                        )
                    }
                } header: {
                    Text("INACTIVE (\(viewModel.inactiveTemplates.count))")
                }
            } else if viewModel.activeTemplates.isEmpty {
                // Show message only if there are active templates but no inactive ones
                Section {
                    Text("No inactive templates.")
                        .font(.theme.caption)
                        .foregroundStyle(.theme.textSecondary)
                } header: {
                    Text("INACTIVE")
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var loadingView: some View {
        VStack(spacing: .spacing.small) {
            ProgressView()
                .tint(.theme.primary)
            Text("Loading templates...")
                .font(.theme.caption)
                .foregroundStyle(.theme.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: .spacing.medium) {
            Image(systemName: "checklist")
                .font(.system(size: 64))
                .foregroundStyle(.theme.textTertiary)

            Text("No habit templates yet")
                .font(.theme.title3)
                .fontWeight(.medium)
                .foregroundStyle(.theme.textPrimary)

            Text("Tap + to create your first habit template")
                .font(.theme.body)
                .foregroundStyle(.theme.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                showingCreateSheet = true
            } label: {
                Label("Create Template", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(.theme.primary)
            .padding(.top, .spacing.small)
        }
        .padding(.spacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview

#Preview {
    TemplateLibraryView()
}
