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
    @Binding var selectedTab: Int

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            // Custom header
            HStack(alignment: .center) {
                Text("Habit Templates")
                    .font(.theme.title)
                    .foregroundStyle(.theme.textPrimary)

                Spacer()

                Button {
                    showingCreateSheet = true
                } label: {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 28))
                        .foregroundStyle(.theme.primary)
                }
            }
            .padding(.horizontal, .spacing.medium)
            .padding(.top, .spacing.medium)
            .padding(.bottom, .spacing.small)

            // Content
            Group {
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.templates.isEmpty {
                    emptyStateView
                } else {
                    templateList
                }
            }
        }
        .background(.theme.background)
        .safeAreaInset(edge: .bottom) {
            CustomTabBar(selectedTab: $selectedTab)
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
                        .listRowBackground(Color.theme.cardBackground)
                    }
                } header: {
                    Text("Active (\(viewModel.activeTemplates.count))")
                        .font(.theme.subheadline)
                        .foregroundStyle(.theme.textSecondary)
                        .textCase(nil)
                        .listRowInsets(EdgeInsets())
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
                        .listRowBackground(Color.theme.cardBackground)
                    }
                } header: {
                    Text("Inactive (\(viewModel.inactiveTemplates.count))")
                        .font(.theme.subheadline)
                        .foregroundStyle(.theme.textSecondary)
                        .textCase(nil)
                        .listRowInsets(EdgeInsets())
                }
            } else if viewModel.activeTemplates.isEmpty {
                Section {
                    Text("No inactive templates.")
                        .font(.theme.caption)
                        .foregroundStyle(.theme.textSecondary)
                } header: {
                    Text("Inactive")
                        .font(.theme.subheadline)
                        .foregroundStyle(.theme.textSecondary)
                        .textCase(nil)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .refreshable {
            await viewModel.loadTemplates()
        }
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
    TemplateLibraryView(selectedTab: .constant(1))
}
