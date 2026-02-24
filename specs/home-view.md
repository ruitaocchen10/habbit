# Habbit Home View Spec

## Table of Contents

- [Overview](#overview)
- [UI Layout](#ui-layout)
- [User Interactions](#user-interactions)
- [Architecture & Components](#architecture--components)
- [State Management](#state-management)
- [Data Fetching](#data-fetching)
- [Edge Cases & Error States](#edge-cases--error-states)

---

## Overview

`HomeView` is the main home screen (tab index 0). It is a coordinator view that composes two independent sub-components — `WeekCalendarView` and `DailyHabitView` — and owns both of their view models. It is responsible for the greeting header, for bridging the selected date from the calendar to the habit list, and for triggering cross-component refreshes (e.g. refreshing week completion dot indicators after a habit is toggled).

```
HomeView (@State CalendarViewModel, @State HabitViewModel)
  ├── Greeting Header     (time-of-day greeting + user name + avatar placeholder)
  ├── WeekCalendarView    (week strip + day selection) — see calendar.md
  └── DailyHabitView      (habit list for selected date) — see habitview.md
```

`HomeView` has no view model of its own. All presentation logic lives in `CalendarViewModel` and `HabitViewModel` respectively.

---

## UI Layout

```
+-----------------------------------------------+
|  Good Morning          [avatar placeholder]   |  <- Greeting header
|  Rui                                          |
+-----------------------------------------------+
|  M    T    W    T    F    S    S              |  <- WeekCalendarView
|  [*]                                          |    (see calendar.md)
+-----------------------------------------------+
|  Today's Habits                               |  <- DailyHabitView
|  ┌─────────────────────────────────────────┐ |    (see habitview.md)
|  │ Morning Run                         [o] │ |
|  │ Meditate                            [x] │ |
|  │ Read 20 min                         [o] │ |
|  └─────────────────────────────────────────┘ |
+-----------------------------------------------+
|         [house]  [list]  [person]             |  <- CustomTabBar
+-----------------------------------------------+
```

### Greeting Header

Located at the top of the scroll view, with `medium` horizontal padding and `medium` top padding.

```
Good Morning          ●
Rui
```

| Element               | Details                                                                                     |
| --------------------- | ------------------------------------------------------------------------------------------- |
| Greeting line         | Time-of-day string (`body` font, `textSecondary` color), displayed above the name           |
| Name line             | Display name (`title` font, `textPrimary` color)                                            |
| Avatar placeholder    | 44pt circle filled with `backgroundTertiary` color; right-aligned via `Spacer`              |

#### Greeting Logic

The greeting string is derived from the current hour (`Calendar.current.component(.hour, from: Date())`):

| Hour range | Greeting text    |
| ---------- | ---------------- |
| 0–11       | "Good Morning"   |
| 12–16      | "Good Afternoon" |
| 17–23      | "Good Evening"   |

#### Display Name Logic

Derived from the authenticated user's session in priority order:

1. `userMetadata["full_name"]` (string) → first space-separated word (first name only)
2. `session.user.email` → prefix before `@`, capitalized
3. Fallback: `"there"` (renders as e.g. "Good Morning, there")

---

## User Interactions

`HomeView` itself has no direct interactions — all interactions are delegated to its child components.

| Interaction                    | Handled by         | Spec reference   |
| ------------------------------ | ------------------ | ---------------- |
| Tap a day in the week strip    | `WeekCalendarView` | `calendar.md`    |
| Swipe week strip left/right    | `WeekCalendarView` | `calendar.md`    |
| Toggle a habit completion      | `DailyHabitView`   | `habitview.md`   |
| Tap a tab bar button           | `CustomTabBar`     | `custom-tab-bar.md` |

---

## Architecture & Components

### Component Tree

```
HomeView
  ├── Greeting header (inline VStack / HStack)
  ├── WeekCalendarView(viewModel: calendarViewModel)
  ├── DailyHabitView(viewModel: habitViewModel, selectedDate: calendarViewModel.selectedDate)
  └── CustomTabBar(selectedTab: $selectedTab)          ← safeAreaInset(.bottom)
```

---

### `HomeView`

The root screen view for tab 0.

| Property / Dependency        | Type / Source                         | Purpose                                                                        |
| ---------------------------- | ------------------------------------- | ------------------------------------------------------------------------------ |
| `authManager`                | `@Environment(AuthManager.self)`      | Reads `session.user.userMetadata` to derive display name                       |
| `calendarViewModel`          | `@State CalendarViewModel`            | Owns week navigation + selected date state                                     |
| `habitViewModel`             | `@State HabitViewModel`               | Owns habit list + completion state for the selected date                       |
| `selectedTab`                | `@Binding Int`                        | Passed in from `MainTabView`; forwarded to `CustomTabBar`                      |

**Computed properties (private)**:

| Property      | Return type | Logic                                                                   |
| ------------- | ----------- | ----------------------------------------------------------------------- |
| `greeting`    | `String`    | Hour-based switch: "Good Morning" / "Good Afternoon" / "Good Evening"   |
| `displayName` | `String`    | Full name first word → email prefix → "there" (see Display Name Logic)  |

**Layout**: A `ScrollView` wrapping a `VStack(alignment: .leading, spacing: .spacing.medium)` containing the greeting header, `WeekCalendarView`, and `DailyHabitView`. `CustomTabBar` is inset via `.safeAreaInset(edge: .bottom)`. Background: `Color.theme.background`.

---

## State Management

`HomeView` is the single source of truth for both child view models. Neither `WeekCalendarView` nor `DailyHabitView` creates its own view model.

```
HomeView
  @State calendarViewModel: CalendarViewModel   → passed to WeekCalendarView
  @State habitViewModel:    HabitViewModel      → passed to DailyHabitView

  // Cross-component bridge: habit toggle → refresh week dots
  habitViewModel.onToggleComplete = {
      Task { await calendarViewModel.loadWeekCompletionCounts() }
  }
```

The bridge is wired inside `.task(id: calendarViewModel.selectedDate)` so it is set fresh each time the selected date changes:

```swift
.task(id: calendarViewModel.selectedDate) {
    habitViewModel.onToggleComplete = {
        Task { await calendarViewModel.loadWeekCompletionCounts() }
    }
    await habitViewModel.loadData(for: calendarViewModel.selectedDate)
}
```

`HabitViewModel` exposes `onToggleComplete: (() -> Void)?` — `HomeView` assigns this callback so that after every successful toggle, the week strip dot indicators are refreshed.

---

## Data Fetching

All async calls use `async/await` on `@MainActor`-isolated view models.

### On View Appear

`HomeView` kicks off the initial calendar fetch on `.task` (fires once on appear):

```swift
.task {
    await calendarViewModel.loadWeekCompletionCounts()
}
```

The initial habit load is driven separately by `.task(id: calendarViewModel.selectedDate)`, which fires on appear (since `selectedDate` is set to `Date()` on init) and again whenever the selected date changes.

### On Selected Date Change

`.task(id: calendarViewModel.selectedDate)` fires automatically, reloading `habitViewModel` for the new date:

```swift
.task(id: calendarViewModel.selectedDate) {
    habitViewModel.onToggleComplete = { ... }
    await habitViewModel.loadData(for: calendarViewModel.selectedDate)
}
```

### On Habit Toggle

After `HabitViewModel.toggleCompletion` succeeds, it invokes `onToggleComplete`, which triggers `calendarViewModel.loadWeekCompletionCounts()` to refresh the dot indicators in the week strip.

---

## Edge Cases & Error States

| Case                                   | Handling                                                                                    |
| -------------------------------------- | ------------------------------------------------------------------------------------------- |
| No `full_name` in OAuth metadata       | Falls back to email prefix (capitalized) or "there"; greeting still renders                 |
| User not yet authenticated on appear   | `AuthManager` redirects to `LoginView` before `HomeView` is ever shown; not reachable       |
| Calendar fetch fails                   | Dots silently omitted (non-critical); no error shown to user — see `calendar.md`             |
| Habit fetch fails                      | `habitViewModel.errorMessage` is set; `DailyHabitView` renders error state — see `habitview.md` |
| Habit toggle fails                     | Optimistic update reverted; `habitViewModel.errorMessage` shown — see `habitview.md`         |
| Selected date is a future date         | `DailyHabitView` shows the habit list with disabled checkboxes — see `habitview.md`          |
