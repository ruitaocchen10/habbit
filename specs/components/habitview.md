# Habbit Daily Habit View Spec

## Table of Contents

- [Overview](#overview)
- [UI Layout](#ui-layout)
- [User Interactions](#user-interactions)
- [Data Requirements](#data-requirements)
- [Architecture & Components](#architecture--components)
- [State Management](#state-management)
- [Data Fetching](#data-fetching)
- [Animations & Transitions](#animations--transitions)
- [Edge Cases & Error States](#edge-cases--error-states)

---

## Overview

`DailyHabitView` displays the list of habits for a given calendar date and allows the user to toggle each habit as complete or incomplete. It is a sibling component of `WeekCalendarView` on the home screen — see [`calendar.md`](calendar.md) for the week strip navigation component.

`DailyHabitView` receives `selectedDate` from `HomeView` (the coordinator) and has no knowledge of week navigation or `CalendarViewModel`. It owns a `HabitViewModel` that handles all data fetching and mutation for the current date.

```
HomeView
  ├── WeekCalendarView   (navigation + day selection) — see calendar.md
  └── DailyHabitView     (habit list for selected date) — this spec
```

---

## UI Layout

```
+---------------------------------------------+
|  o  Morning Run                              |  +
|  x  Meditate                                 |  | DailyHabitView
|  o  Read 20 min                              |  +
|                                              |
|  (No habits for this day)                    |  <- Empty state
+---------------------------------------------+
```

- A scrollable list of `HabitRowView` items, one per active habit template for the selected date.
- Each row contains:
  - Checkbox (circle toggle) — filled when completed, outline when not.
  - Habit icon (SF Symbol, from `habit_templates.icon`), tinted with `habit_templates.color`.
  - Habit name.
- A `ProgressView` is shown while data is loading.
- An empty-state message is shown when there are no active habits for the date.

---

## User Interactions

| Interaction        | Result                                                                                                |
| ------------------ | ----------------------------------------------------------------------------------------------------- |
| Tap habit checkbox | Toggles completion for that habit on the selected date (inserts or deletes a `habit_completions` row) |

Future dates: Habit checkboxes are disabled when `selectedDate` is in the future — users cannot mark future habits as complete. The list is still visible for browsing.

---

## Data Requirements

### Tables Used

| Table               | Usage                                            |
| ------------------- | ------------------------------------------------ |
| `habit_templates`   | Active habits to display for the selected date   |
| `habit_completions` | Which habits were completed on the selected date |

### Active Habits for a Date

A habit template appears in the list for a given date if:

```
habit_templates.user_id = currentUser.id
AND habit_templates.is_active = true
AND habit_templates.activated_at <= selected_date
```

Deactivated templates (`is_active = false`) are not shown. Historical display of deactivated habits is deferred to a later iteration.

### Completions for a Date

```sql
SELECT template_id
FROM habit_completions
WHERE user_id = :userId
  AND completed_date = :selectedDate
```

Result stored as `Set<UUID>` of `template_id`s for O(1) lookup when rendering each row.

---

## Architecture & Components

### Component Tree

```
DailyHabitView (@Observable HabitViewModel)
  +-- HabitRowView (xn)
```

---

### `HabitViewModel` - Habit Data for a Date

An `@Observable` class created as `@State` in `HomeView` and passed to `DailyHabitView`. Concerns: fetching and mutating habits for a specific date only.

| Property             | Type              | Purpose                                      |
| -------------------- | ----------------- | -------------------------------------------- |
| `activeTemplates`    | `[HabitTemplate]` | Active habit templates for the selected date |
| `completionsForDate` | `Set<UUID>`       | `template_id`s completed on the current date |
| `isLoading`          | `Bool`            | `true` while fetching data                   |
| `errorMessage`       | `String?`         | Non-nil when a fetch or toggle fails         |

| Method                                                         | Purpose                                                                                   |
| -------------------------------------------------------------- | ----------------------------------------------------------------------------------------- |
| `loadData(for date: Date)`                                     | Fetches `activeTemplates` and `completionsForDate` for the given date                     |
| `toggleCompletion(for template: HabitTemplate, on date: Date)` | Inserts or deletes a `habit_completions` row; updates `completionsForDate` optimistically |

---

### `DailyHabitView`

Root view for the habit list. Takes `HabitViewModel` directly (passed from `HomeView`).

- Renders a `ScrollView` + `LazyVStack` of `HabitRowView` items.
- Shows a `ProgressView` when `isLoading == true`.
- Shows an empty-state message when `activeTemplates.isEmpty && !isLoading`.
- Has no knowledge of week navigation or `CalendarViewModel`.

---

### `HabitRowView`

A single row in the habit list.

| Element         | Notes                                                                                                             |
| --------------- | ----------------------------------------------------------------------------------------------------------------- |
| Checkbox button | `circle` (unchecked) / `checkmark.circle.fill` (checked) SF Symbol; disabled when `selectedDate` is in the future |
| Habit icon      | SF Symbol from `habit_templates.icon`; tinted with `habit_templates.color`                                        |
| Habit name      | `Text(template.name)`                                                                                             |

Tapping the checkbox calls `habitViewModel.toggleCompletion(for: template, on: selectedDate)`.

---

## State Management

`HabitViewModel` is created as `@State` in `HomeView` and passed down to `DailyHabitView`. `HomeView` triggers a reload whenever `calendarViewModel.selectedDate` changes using `.task(id:)`:

```swift
// In HomeView
DailyHabitView(viewModel: habitViewModel)
    .task(id: calendarViewModel.selectedDate) {
        await habitViewModel.loadData(for: calendarViewModel.selectedDate)
    }
```

`HabitViewModel` accepts a `Date` parameter and has no reference to `CalendarViewModel` — the two view models are fully decoupled.

After a successful completion toggle, `HomeView` refreshes the week strip dot indicators by calling `calendarViewModel.loadWeekCompletionCounts()`.

---

## Data Fetching

All Supabase calls use `async/await` and are dispatched from `Task { }` blocks. Main actor isolation is used for all property mutations.

### On Date Change

Triggered automatically by `HomeView`'s `.task(id: calendarViewModel.selectedDate)`:

```swift
func loadData(for date: Date) async {
    isLoading = true
    defer { isLoading = false }
    do {
        async let templates = fetchActiveTemplates(for: date)
        async let completions = fetchCompletions(for: date)
        (activeTemplates, completionsForDate) = try await (templates, completions)
    } catch {
        errorMessage = error.localizedDescription
    }
}
```

### Completion Toggle

Optimistic update: immediately flip the local `completionsForDate` set, then sync to Supabase. If the backend call fails, revert the set and set `errorMessage`.

```swift
func toggleCompletion(for template: HabitTemplate, on date: Date) {
    let alreadyCompleted = completionsForDate.contains(template.id)
    // Optimistic update
    if alreadyCompleted {
        completionsForDate.remove(template.id)
    } else {
        completionsForDate.insert(template.id)
    }
    Task {
        do {
            if alreadyCompleted {
                try await SupabaseService.client
                    .from("habit_completions")
                    .delete()
                    .eq("user_id", value: userId)
                    .eq("template_id", value: template.id)
                    .eq("completed_date", value: date.isoDateString)
                    .execute()
            } else {
                try await SupabaseService.client
                    .from("habit_completions")
                    .insert(["user_id": userId, "template_id": template.id, "completed_date": date.isoDateString])
                    .execute()
            }
        } catch {
            // Revert optimistic update
            if alreadyCompleted {
                completionsForDate.insert(template.id)
            } else {
                completionsForDate.remove(template.id)
            }
            errorMessage = error.localizedDescription
        }
    }
}
```

---

## Animations & Transitions

| Interaction                     | Animation                                                               |
| ------------------------------- | ----------------------------------------------------------------------- |
| Habit list update (date change) | `.animation(.easeInOut, value: activeTemplates)` on the `LazyVStack`    |
| Checkbox toggle                 | Scale pulse: `scaleEffect` briefly increases to 1.2 then returns to 1.0 |

---

## Edge Cases & Error States

| Case                                  | Handling                                                                                 |
| ------------------------------------- | ---------------------------------------------------------------------------------------- |
| No active habits for the selected day | Empty state: "No habits for this day. Add habits in Settings."                           |
| Future date selected                  | Habit list is visible but checkboxes are disabled; label: "Can't complete future habits" |
| Network error on load                 | `errorMessage` shown; retry button calls `loadData(for:)`                                |
| Network error on toggle               | Optimistic update reverted; `errorMessage` shown                                         |
| Week before any habit was activated   | Empty state shown (no templates match the `activated_at <= date` filter)                 |
