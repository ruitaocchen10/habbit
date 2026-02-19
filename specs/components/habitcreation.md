# Habbit Template Creation & Management Spec

## Table of Contents

- [Overview](#overview)
- [UI Layout](#ui-layout)
- [User Interactions](#user-interactions)
- [Data Requirements](#data-requirements)
- [Architecture & Components](#architecture--components)
- [State Management](#state-management)
- [Data Fetching](#data-fetching)
- [User Flows](#user-flows)
- [Animations & Transitions](#animations--transitions)
- [Edge Cases & Error States](#edge-cases--error-states)

---

## Overview

The Template Management system allows users to create, organize, activate, and deactivate habit templates. Templates serve as reusable habit definitions that, when activated, appear in the daily habit list from their `activated_at` date forward.

**Key Concepts**:

- **Inactive Templates (Template Library)**: `isActive = false` — Templates that exist but don't appear in daily views
- **Active Templates**: `isActive = true` — Templates that generate daily habit entries
- **Template Lifecycle**: Create → Stored as inactive → Activate when needed → Deactivate when paused → Optionally delete

**System Components**:

```
TemplateLibraryView           (browse & manage all templates)
  ├── Active Templates Section    (currently generating daily habits)
  ├── Inactive Templates Section  (stored but not active)
  └── Create Template Button      (opens TemplateFormView)

TemplateFormView              (create or edit a single template)
  └── Form fields: name, description, icon, color, active toggle
```

**Navigation**: Template Library is accessible from the home screen via:

- **Option A (Recommended)**: Tab bar item (Templates tab)
- **Option B**: Modal sheet triggered by a "+" button in HomeView toolbar
- **Option C**: Settings section ("Manage Habits")

---

## UI Layout

### Template Library View

```
┌─────────────────────────────────────┐
│  Habit Templates               [+]  │  <- Title + Create button
├─────────────────────────────────────┤
│                                     │
│  ACTIVE (3)                         │  <- Section header
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                     │
│  💧  Drink Water                    │  <- TemplateRow
│      Stay hydrated              [•] │     (active toggle on)
│                                     │
│  🏃  Morning Run                    │
│      30 min cardio              [•] │
│                                     │
│  📖  Read 30 min                    │
│      Daily reading              [•] │
│                                     │
│  INACTIVE (5)                       │  <- Section header
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                     │
│  🧘  Meditation                     │
│      10 min mindfulness         [ ] │
│                                     │
│  🎸  Guitar Practice                │
│      Learn new chords           [ ] │
│                                     │
│  📝  Journal                        │
│                                     │
│  ...                                │
│                                     │
│  (Empty state if no templates)      │
│  "No habit templates yet.           │
│   Tap + to create your first one."  │
└─────────────────────────────────────┘
```

### Template Form View (Sheet / Navigation Push)

```
┌─────────────────────────────────────┐
│  < Cancel    New Habit        Save  │  <- Navigation bar
├─────────────────────────────────────┤
│                                     │
│  Habit Name *                       │
│  ┌───────────────────────────────┐ │
│  │ Morning Run                   │ │
│  └───────────────────────────────┘ │
│                                     │
│  Description                        │
│  ┌───────────────────────────────┐ │
│  │ 30 min cardio around the park │ │
│  └───────────────────────────────┘ │
│                                     │
│  Icon                               │
│  🏃  (Tap to choose from SF Symbols)│
│                                     │
│  Color                              │
│  🔴 🟠 🟡 🟢 🔵 🟣 (Color picker)   │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                     │
│  Active                        [•]  │  <- Toggle
│  When active, this habit appears    │
│  in your daily list                 │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                     │
│  (Delete Template button if editing)│
└─────────────────────────────────────┘
```

---

## User Interactions

### Template Library View

| Interaction                            | Result                                                                             |
| -------------------------------------- | ---------------------------------------------------------------------------------- |
| Tap "+" (Create) button                | Opens TemplateFormView in sheet/push mode for creating a new template              |
| Tap a template row                     | Opens TemplateFormView in edit mode for that template                              |
| Toggle active/inactive switch on a row | Immediately updates `is_active` in database; activates or deactivates the template |
| Swipe left on template row             | Reveals contextual actions: Edit, Delete                                           |
| Pull to refresh                        | Reloads all templates from Supabase                                                |
| Search (future)                        | Filters templates by name                                                          |

### Template Form View

| Interaction                 | Result                                                                                                        |
| --------------------------- | ------------------------------------------------------------------------------------------------------------- |
| Type in "Habit Name" field  | Updates local state; required field (Save button disabled if empty)                                           |
| Type in "Description" field | Updates local state; optional                                                                                 |
| Tap icon picker             | Opens icon selection sheet (grid of SF Symbols); updates template icon                                        |
| Tap color swatch            | Selects color; updates template color                                                                         |
| Toggle "Active" switch      | Sets whether the template is active on creation/update; if toggled on, sets `activated_at = Date()`           |
| Tap "Save"                  | Validates form, inserts/updates template in Supabase, dismisses form, refreshes TemplateLibraryView           |
| Tap "Cancel"                | Dismisses form without saving; prompts confirmation if changes were made                                      |
| Tap "Delete Template"       | Shows confirmation alert; deletes template and all associated completions (or soft-delete with cascade rules) |

---

## Data Requirements

### Tables Used

| Table               | Usage                                                             |
| ------------------- | ----------------------------------------------------------------- |
| `habit_templates`   | CRUD operations for all habit templates (active and inactive)     |
| `habit_completions` | Referenced to show completion history; deleted on template delete |

### Queries

#### Fetch All Templates (for Template Library View)

```sql
SELECT *
FROM habit_templates
WHERE user_id = :userId
ORDER BY is_active DESC, name ASC
```

Result: Array of `HabitTemplate` objects, grouped in UI by `is_active`.

#### Create New Template

```sql
INSERT INTO habit_templates (
  user_id, name, description, icon, color, is_active, activated_at
) VALUES (
  :userId, :name, :description, :icon, :color, :isActive, :activatedAt
)
RETURNING *
```

If `isActive = true`, `activatedAt = now()`. Otherwise, `activatedAt = null`.

#### Update Template

```sql
UPDATE habit_templates
SET name = :name,
    description = :description,
    icon = :icon,
    color = :color,
    is_active = :isActive,
    activated_at = :activatedAt,
    updated_at = now()
WHERE id = :templateId
  AND user_id = :userId
RETURNING *
```

When toggling from inactive → active: set `activated_at = now()`.
When toggling from active → inactive: keep existing `activated_at` (for historical reference).

#### Delete Template

```sql
DELETE FROM habit_templates
WHERE id = :templateId
  AND user_id = :userId
```

Cascades to `habit_completions` (either via database CASCADE or explicit delete in transaction).

**Alternative (Soft Delete)**: Add `is_archived` column; set to `true` instead of deleting.

---

## Architecture & Components

### Component Tree

```
TemplateLibraryView (@Observable TemplateViewModel)
  +-- TemplateSection ("Active")
  |     +-- TemplateRow (xN)
  +-- TemplateSection ("Inactive")
  |     +-- TemplateRow (xM)
  +-- EmptyStateView (if no templates)

TemplateFormView (@Observable TemplateFormViewModel)
  +-- TextField (name)
  +-- TextField (description)
  +-- IconPicker
  +-- ColorPicker
  +-- Toggle (is_active)
  +-- DeleteButton (edit mode only)
```

---

### `TemplateViewModel` - Template CRUD & State

An `@Observable` class managing all habit templates for the current user.

| Property       | Type              | Purpose                                                  |
| -------------- | ----------------- | -------------------------------------------------------- |
| `templates`    | `[HabitTemplate]` | All templates (active + inactive), fetched from Supabase |
| `isLoading`    | `Bool`            | `true` while fetching templates                          |
| `errorMessage` | `String?`         | Non-nil when a fetch or mutation fails                   |

| Computed Property   | Type              | Purpose                                       |
| ------------------- | ----------------- | --------------------------------------------- |
| `activeTemplates`   | `[HabitTemplate]` | Filters `templates` where `isActive == true`  |
| `inactiveTemplates` | `[HabitTemplate]` | Filters `templates` where `isActive == false` |

| Method                                      | Purpose                                                                  |
| ------------------------------------------- | ------------------------------------------------------------------------ |
| `loadTemplates()`                           | Fetches all templates from `habit_templates` table                       |
| `createTemplate(_ template: HabitTemplate)` | Inserts new template; refreshes `templates` array                        |
| `updateTemplate(_ template: HabitTemplate)` | Updates existing template; refreshes `templates` array                   |
| `toggleActive(for template: HabitTemplate)` | Flips `is_active`; sets `activated_at` if activating; updates database   |
| `deleteTemplate(_ template: HabitTemplate)` | Deletes template and associated completions; refreshes `templates` array |

---

### `TemplateFormViewModel` - Form State & Validation

An `@Observable` class managing the state of the template creation/edit form.

| Property       | Type      | Purpose                                    |
| -------------- | --------- | ------------------------------------------ |
| `name`         | `String`  | Template name (required)                   |
| `description`  | `String`  | Template description (optional)            |
| `icon`         | `String?` | SF Symbol name                             |
| `color`        | `String?` | Hex color string                           |
| `isActive`     | `Bool`    | Whether template is active on save         |
| `isSaving`     | `Bool`    | `true` while save operation is in progress |
| `errorMessage` | `String?` | Non-nil when validation or save fails      |

| Computed Property | Type   | Purpose                                   |
| ----------------- | ------ | ----------------------------------------- |
| `isValid`         | `Bool` | Returns `true` if `name.isEmpty == false` |
| `canSave`         | `Bool` | Returns `isValid && !isSaving`            |

| Method                               | Purpose                                                                                  |
| ------------------------------------ | ---------------------------------------------------------------------------------------- |
| `save()`                             | Validates, calls `TemplateViewModel.createTemplate` or `.updateTemplate`, dismisses form |
| `delete()`                           | Calls `TemplateViewModel.deleteTemplate`, dismisses form                                 |
| `reset()`                            | Clears all form fields (for creating new template)                                       |
| `load(from template: HabitTemplate)` | Populates form fields from existing template (for editing)                               |

---

### `TemplateLibraryView`

Root view for browsing and managing all habit templates.

- Displays two sections: **Active** and **Inactive**, each containing a list of `TemplateRow` views.
- Shows `ProgressView` when `isLoading == true`.
- Shows empty state when `templates.isEmpty && !isLoading`.
- Toolbar contains a "+" button to create a new template (opens `TemplateFormView` in a sheet).

---

### `TemplateRow`

A single row in the template list.

| Element       | Notes                                                                                         |
| ------------- | --------------------------------------------------------------------------------------------- |
| Icon          | SF Symbol from `template.icon`, tinted with `template.color`                                  |
| Name          | `Text(template.name)`, primary font                                                           |
| Description   | `Text(template.description ?? "")`, secondary font, truncated to 1 line                       |
| Active Toggle | `Toggle` bound to `template.isActive`; calls `templateViewModel.toggleActive(for:)` on change |
| Swipe Actions | Edit (opens form), Delete (shows confirmation)                                                |

---

### `TemplateFormView`

Sheet or navigation-pushed view for creating or editing a template.

- **Create mode**: All fields empty; "Save" creates a new template.
- **Edit mode**: Fields pre-filled from existing template; "Save" updates; "Delete" button shown.
- **Navigation bar**: "Cancel" (left), title (center), "Save" (right, disabled if `!isValid`).
- **Form fields**:
  - `TextField` for name (required, with asterisk)
  - `TextField` for description (optional, multiline)
  - Icon picker (button that opens icon selection sheet)
  - Color picker (horizontal row of color swatches)
  - `Toggle` for "Active" with explanatory subtext
- **Delete button** (edit mode only): Red destructive button at bottom of form.

---

### `IconPickerView` (Future / Optional)

Sheet displaying a grid of SF Symbols for icon selection.

- Searchable grid of common habit icons (fitness, food, wellness, learning, etc.)
- Tapping an icon dismisses the sheet and updates the form.

For MVP: use a simple `TextField` where users type an SF Symbol name, or provide a preset list.

---

## State Management

### Template Library Flow

`TemplateViewModel` is created as `@State` in `TemplateLibraryView` and passed to child components.

```swift
// In TemplateLibraryView
@State private var viewModel = TemplateViewModel()

var body: some View {
    NavigationStack {
        TemplateListContent(viewModel: viewModel)
            .task {
                await viewModel.loadTemplates()
            }
    }
}
```

### Template Form Flow

`TemplateFormViewModel` is created as `@State` in `TemplateFormView`. It holds a reference to `TemplateViewModel` to call save/delete methods.

```swift
// In TemplateFormView
@State private var formViewModel = TemplateFormViewModel()
@Environment(\.dismiss) private var dismiss

// On save:
await formViewModel.save() // internally calls templateViewModel.createTemplate or .updateTemplate
dismiss()
```

---

## Data Fetching

All Supabase calls use `async/await` and are dispatched from `Task { }` blocks. Main actor isolation is used for all property mutations.

### On View Appear

```swift
func loadTemplates() async {
    isLoading = true
    errorMessage = nil
    defer { isLoading = false }

    do {
        let userId = try await SupabaseService.client.auth.session.user.id
        templates = try await SupabaseService.client
            .from("habit_templates")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("is_active", ascending: false)
            .order("name", ascending: true)
            .execute()
            .value
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

### Create Template

```swift
func createTemplate(_ template: HabitTemplate) async {
    do {
        let userId = try await SupabaseService.client.auth.session.user.id
        let data: [String: Any] = [
            "user_id": userId.uuidString,
            "name": template.name,
            "description": template.description ?? "",
            "icon": template.icon ?? "",
            "color": template.color ?? "",
            "is_active": template.isActive,
            "activated_at": template.isActive ? Date().isoDateString : nil
        ]
        try await SupabaseService.client
            .from("habit_templates")
            .insert(data)
            .execute()

        await loadTemplates() // Refresh list
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

### Update Template

```swift
func updateTemplate(_ template: HabitTemplate) async {
    do {
        let userId = try await SupabaseService.client.auth.session.user.id
        var data: [String: Any] = [
            "name": template.name,
            "description": template.description ?? "",
            "icon": template.icon ?? "",
            "color": template.color ?? "",
            "is_active": template.isActive,
            "updated_at": Date().isoDateString
        ]

        // If activating, set activated_at to now
        if template.isActive && template.activatedAt == nil {
            data["activated_at"] = Date().isoDateString
        }

        try await SupabaseService.client
            .from("habit_templates")
            .update(data)
            .eq("id", value: template.id.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()

        await loadTemplates() // Refresh list
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

### Toggle Active Status

```swift
func toggleActive(for template: HabitTemplate) async {
    var updatedTemplate = template
    updatedTemplate.isActive.toggle()

    // If activating, set activated_at to now
    if updatedTemplate.isActive {
        updatedTemplate.activatedAt = Date()
    }

    await updateTemplate(updatedTemplate)
}
```

### Delete Template

```swift
func deleteTemplate(_ template: HabitTemplate) async {
    do {
        let userId = try await SupabaseService.client.auth.session.user.id

        // Delete associated completions first (if not handled by CASCADE)
        try await SupabaseService.client
            .from("habit_completions")
            .delete()
            .eq("template_id", value: template.id.uuidString)
            .execute()

        // Delete template
        try await SupabaseService.client
            .from("habit_templates")
            .delete()
            .eq("id", value: template.id.uuidString)
            .eq("user_id", value: userId.uuidString)
            .execute()

        await loadTemplates() // Refresh list
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

---

## User Flows

### Flow 1: Creating a New Habit Template

1. User opens `TemplateLibraryView` (from tab bar or modal).
2. Taps "+" button in toolbar.
3. `TemplateFormView` opens in a sheet (create mode).
4. User fills in:
   - **Name**: "Morning Run" (required)
   - **Description**: "30 min cardio" (optional)
   - **Icon**: Selects 🏃 from icon picker
   - **Color**: Selects orange
   - **Active toggle**: OFF (will activate later)
5. Taps "Save".
6. `TemplateFormViewModel.save()` validates and calls `TemplateViewModel.createTemplate()`.
7. New template inserted into `habit_templates` with `is_active = false`, `activated_at = null`.
8. Sheet dismisses; user returns to `TemplateLibraryView`.
9. New template appears in **Inactive** section.

---

### Flow 2: Activating a Habit Template

**Option A: Toggle in Library View**

1. User sees "Morning Run" in **Inactive** section.
2. Toggles the switch to ON.
3. `TemplateViewModel.toggleActive(for:)` updates `is_active = true`, `activated_at = now()`.
4. Template moves to **Active** section.
5. From this moment, "Morning Run" appears in daily habit lists (see [`habitview.md`](habitview.md)).

**Option B: Activate During Creation**

1. In step 4 of Flow 1, user toggles "Active" to ON before saving.
2. Template is created with `is_active = true`, `activated_at = now()`.
3. Appears immediately in **Active** section.

---

### Flow 3: Deactivating a Habit Template

1. User sees "Morning Run" in **Active** section.
2. Toggles the switch to OFF.
3. `TemplateViewModel.toggleActive(for:)` updates `is_active = false`.
4. Template moves to **Inactive** section.
5. "Morning Run" no longer appears in daily habit lists from tomorrow onward.
6. **Historical completions are preserved** for stats and heatmap.

---

### Flow 4: Editing a Habit Template

1. User taps on "Morning Run" row in **Inactive** section.
2. `TemplateFormView` opens in edit mode, fields pre-filled.
3. User changes description to "45 min cardio" and icon to 🏃‍♀️.
4. Taps "Save".
5. `TemplateFormViewModel.save()` calls `TemplateViewModel.updateTemplate()`.
6. Template updated in database.
7. Sheet dismisses; updated template visible in library.

---

### Flow 5: Deleting a Habit Template

**Option A: Swipe to Delete**

1. User swipes left on "Morning Run" row.
2. "Delete" button appears.
3. User taps "Delete".
4. Confirmation alert: "Delete 'Morning Run'? This will also delete all completion history."
5. User confirms.
6. `TemplateViewModel.deleteTemplate()` deletes template and completions.
7. Template removed from library.

**Option B: Delete in Edit Form**

1. User taps "Morning Run" to edit.
2. Scrolls to bottom of form, taps red "Delete Template" button.
3. Confirmation alert shown.
4. User confirms.
5. Template deleted; form dismisses.

---

## Animations & Transitions

| Interaction                     | Animation                                                                       |
| ------------------------------- | ------------------------------------------------------------------------------- |
| Template form presentation      | `.sheet` modal slide-up transition                                              |
| Template created / deleted      | List row insertion / deletion with `.animation(.easeInOut)`                     |
| Template moved between sections | Row animates from Inactive → Active (or vice versa) with `.move` transition     |
| Active toggle switch            | Built-in toggle animation; row moves to new section with `.animation(.default)` |
| Pull to refresh                 | Standard iOS refresh spinner                                                    |

---

## Edge Cases & Error States

| Case                                           | Handling                                                                                               |
| ---------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| No templates exist                             | Empty state: "No habit templates yet. Tap + to create your first one."                                 |
| All templates are active                       | "Inactive" section shows: "No inactive templates."                                                     |
| All templates are inactive                     | "Active" section shows: "No active templates. Toggle a template to activate it."                       |
| Name field is empty on save                    | "Save" button disabled; red underline on field; hint: "Name is required"                               |
| Network error on create / update / delete      | `errorMessage` shown as alert or inline banner; changes not saved                                      |
| User tries to delete template with completions | Confirmation alert warns: "This will delete X completions. Continue?"                                  |
| User edits active template                     | Changes apply immediately; daily habit list reflects updated name/icon/color on next reload            |
| User activates template in the past            | `activated_at` is set to today; template appears in daily lists from today forward (not retroactively) |
| User creates duplicate template names          | Allowed (no unique constraint on name); user can create multiple "Meditate" templates if desired       |
| User cancels form with unsaved changes         | Confirmation alert: "Discard changes?" (only if form is dirty)                                         |
| Swipe action conflicts with scroll             | Standard iOS swipe gesture handling; vertical scroll takes precedence over incomplete swipe            |
| Database cascade delete fails                  | Handle in transaction; if cascade doesn't work, manually delete completions first                      |

---

## Future Enhancements

- **Template Categories**: Group templates by type (Health, Productivity, Wellness, etc.)
- **Template Sharing**: Share template definitions with friends (without completions)
- **Template Scheduling**: Set specific days of the week for a template (e.g., "Gym" only Mon/Wed/Fri)
- **Template Streaks**: Show per-template streaks and stats in the library
- **Bulk Activation**: Toggle multiple templates on/off at once (seasonal habits)
- **Archived Templates**: Soft-delete with `is_archived` flag instead of hard delete
- **Template Import/Export**: Export templates as JSON for backup or migration

---

## Summary

The Template Management system provides a complete CRUD interface for habit templates, separating template definitions from their daily activation state. This architecture allows users to maintain a personal library of habits they can activate or deactivate as their routines change, while preserving all historical completion data for long-term tracking and analytics.
