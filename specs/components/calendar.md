# Habbit Calendar Component Spec

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

`WeekCalendarView` displays the current week as a horizontal strip of day cells and lets the user select a day or navigate between weeks. It is a sibling component of `DailyHabitView` on the home screen — see [`habitview.md`](habitview.md) for the habit list component.

`WeekCalendarView` owns a `CalendarViewModel` that manages week navigation and day selection state. It exposes `selectedDate`, which `HomeView` (the coordinator) uses to trigger habit data reloads in `DailyHabitView`.

```
HomeView
  ├── WeekCalendarView   (navigation + day selection) — this spec
  └── DailyHabitView     (habit list for selected date) — see habitview.md
```

---

## UI Layout

```
+---------------------------------------------+
|  < Mon  Tue  Wed  Thu  Fri  Sat  Sun  >     |  <- Week strip with nav arrows
|         [*]                                  |    Selected day highlighted
|  Tuesday, Feb 18                             |    Selected date label
+---------------------------------------------+
```

- Displays 7 day cells (Mon-Sun) for the current week offset.
- Each cell shows:
  - Abbreviated day name (Mon, Tue, ...)
  - Day number (1-31)
  - A small filled dot indicator if the day has any completions
- The selected day is highlighted (filled background, contrasting text).
- Today's date is additionally distinguished (e.g. accent color ring or bold day number) even when not selected.
- Left (`<`) and right (`>`) arrow buttons flank the strip to navigate weeks.
- A selected date label sits below the strip, formatted as `"EEEE, MMM d"` (e.g. "Tuesday, Feb 18").

---

## User Interactions

| Interaction               | Result                                                                        |
| ------------------------- | ----------------------------------------------------------------------------- |
| Tap a day cell            | Selects that day; `DailyHabitView` reacts and reloads habits for the new date |
| Tap `<` arrow             | Navigates one week backward; keeps same weekday selected                      |
| Tap `>` arrow             | Navigates one week forward; keeps same weekday selected                       |
| Swipe left on week strip  | Navigates one week forward                                                    |
| Swipe right on week strip | Navigates one week backward                                                   |

---

## Data Requirements

### Tables Used

| Table               | Usage                                                       |
| ------------------- | ----------------------------------------------------------- |
| `habit_completions` | Per-day completion counts for the week strip dot indicators |

### Completion Dot Indicator

Fetched by `CalendarViewModel` when the visible week changes:

```sql
SELECT completed_date, COUNT(*) AS count
FROM habit_completions
WHERE user_id = :userId
  AND completed_date BETWEEN :weekStart AND :weekEnd
GROUP BY completed_date
```

Result stored as `[Date: Int]` for O(1) lookup per day cell.

---

## Architecture & Components

### Component Tree

```
WeekCalendarView (@Observable CalendarViewModel)
  +-- WeekStripView
  |     +-- DayCell (x7)
  +-- Selected date label
```

---

### `CalendarViewModel` - Week Navigation State

An `@Observable` class created as `@State` in `HomeView` and passed to `WeekCalendarView`. Concerns: week navigation and day selection only.

| Property                  | Type          | Purpose                                                                     |
| ------------------------- | ------------- | --------------------------------------------------------------------------- |
| `selectedDate`            | `Date`        | Currently selected calendar day; defaults to `Date()`                       |
| `weekOffset`              | `Int`         | Number of weeks from the current week (0 = this week, -1 = last week, etc.) |
| `visibleWeek`             | `[Date]`      | Computed: 7 dates for the week at `weekOffset`                              |
| `completionCountsForWeek` | `[Date: Int]` | Completion counts per day for the visible week (powers dot indicators)      |

| Method                       | Purpose                                                                                  |
| ---------------------------- | ---------------------------------------------------------------------------------------- |
| `loadWeekCompletionCounts()` | Fetches per-day completion counts for the visible week                                   |
| `selectDay(_ date: Date)`    | Updates `selectedDate`                                                                   |
| `goToPreviousWeek()`         | Decrements `weekOffset`; keeps same weekday selected; calls `loadWeekCompletionCounts()` |
| `goToNextWeek()`             | Increments `weekOffset`; keeps same weekday selected; calls `loadWeekCompletionCounts()` |

---

### `WeekCalendarView`

Root view for the calendar strip. Takes `CalendarViewModel` directly (passed from `HomeView`).

- Renders `WeekStripView` and the selected date label.
- Has no knowledge of habits or `HabitViewModel`.

---

### `WeekStripView`

A horizontal `HStack` of 7 `DayCell` views flanked by arrow buttons.

- Attaches a `DragGesture` to detect left/right swipe, calling `goToNextWeek()` / `goToPreviousWeek()`.
- Uses `.animation(.easeInOut)` when `weekOffset` changes to slide the strip.

---

### `DayCell`

A `Button` representing one day in the week strip.

| Property          | Notes                                             |
| ----------------- | ------------------------------------------------- |
| `date`            | The calendar date this cell represents            |
| `isSelected`      | Whether this is the currently selected day        |
| `isToday`         | Whether this date is today (for distinct styling) |
| `completionCount` | Number of completions on this day (0 = no dot)    |

Appearance:

- Selected: filled capsule background (`.tint`), white text.
- Today (not selected): accent-colored day number text, no fill.
- Default: secondary text, no fill.
- Completion dot: small filled circle below the day number, visible when `completionCount > 0`.

---

## State Management

`CalendarViewModel` is created as `@State` in `HomeView` and passed to `WeekCalendarView`. It has no reference to `HabitViewModel`. `HomeView` observes `calendarViewModel.selectedDate` and uses `.task(id:)` to trigger habit reloads in `DailyHabitView` — see [`habitview.md`](habitview.md) for details.

```
HomeView (@State CalendarViewModel, @State HabitViewModel)
  |
  +-- WeekCalendarView(viewModel: calendarViewModel)
  |     [reads/writes selectedDate, weekOffset, completionCountsForWeek]
  |
  +-- DailyHabitView(viewModel: habitViewModel)   <- see habitview.md
        [reloads when calendarViewModel.selectedDate changes]
```

---

## Data Fetching

All Supabase calls use `async/await` and are dispatched from `Task { }` blocks. Main actor isolation is used for all property mutations.

### On View Appear

`HomeView` kicks off both the calendar and habit fetches in parallel:

```swift
// In HomeView
.task {
    async let calendar: () = calendarViewModel.loadWeekCompletionCounts()
    async let habits: () = habitViewModel.loadData(for: calendarViewModel.selectedDate)
    await calendar
    await habits
}
```

### On Day Selection

```swift
func selectDay(_ date: Date) {
    selectedDate = date
    // HomeView's .task(id: selectedDate) fires automatically, reloading HabitViewModel
}
```

### On Week Navigation

```swift
func goToNextWeek() {
    weekOffset += 1
    selectedDate = correspondingDay(in: visibleWeek, for: selectedDate)
    Task {
        await loadWeekCompletionCounts()
        // selectedDate change also triggers HabitViewModel reload via HomeView
    }
}
```

---

## Animations & Transitions

| Interaction                      | Animation                                                                              |
| -------------------------------- | -------------------------------------------------------------------------------------- |
| Day cell selection               | `.animation(.easeInOut(duration: 0.2), value: selectedDate)` on the capsule background |
| Week navigation (arrows / swipe) | Slide transition on the week strip: `.transition(.slide)` driven by `weekOffset`       |

---

## Edge Cases & Error States

| Case                         | Handling                                                         |
| ---------------------------- | ---------------------------------------------------------------- |
| Network error on week counts | Dots silently omitted (non-critical); no error shown to user     |
| Week navigation boundaries   | No hard limit; users can navigate freely into the past or future |
