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
|  M    T    W    T    F    S    S            |  <- Week strip (single-letter day names)
|       [*]                                   |    Selected day highlighted
+---------------------------------------------+
```

- Displays 7 day cells (Mon-Sun) for the current week offset.
- Each cell shows:
  - Single-letter day name (M, T, W, T, F, S, S) using `EEEEE` date format
  - Day number (1-31) inside a 40pt circle
  - A small filled dot indicator below the circle if the day has any completions
- The selected day is highlighted (filled `primary` circle, white text).
- Today's date is additionally distinguished with a lighter primary green filled circle and white bold number, even when not selected.
- Navigation between weeks is via swipe gesture (left = next week, right = previous week). No visible arrow buttons.

---

## User Interactions

| Interaction               | Result                                                                        |
| ------------------------- | ----------------------------------------------------------------------------- |
| Tap a day cell            | Selects that day; `DailyHabitView` reacts and reloads habits for the new date |
| Swipe left on week strip  | Navigates one week forward (with drag offset visual feedback)                 |
| Swipe right on week strip | Navigates one week backward (with drag offset visual feedback)                |

**Swipe gesture constants** (in `WeekStripView`):

| Constant | Value | Purpose |
| -------- | ----- | ------- |
| `swipeThreshold` | 50pt | Minimum swipe distance to trigger week navigation |
| `minimumDragDistance` | 20pt | Minimum drag before gesture is recognized |
| `dragMultiplier` | 0.3 | Resistance factor applied to drag offset for visual feedback |
| `animationDuration` | 0.2s | Duration of transition animation |

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

A vertical stack containing a row of single-letter day names and a row of 7 `DayCell` views. No arrow buttons — week navigation is swipe-only.

- Attaches a `DragGesture` to detect left/right swipe, calling `goToNextWeek()` / `goToPreviousWeek()` when `dragOffset` exceeds `swipeThreshold` (50pt).
- Applies `dragMultiplier` (0.3) to the drag offset for a resistance feel during in-progress swipe.
- Resets `dragOffset` and animates to the new week on gesture end.
- Day names row uses `EEEEE` date format (single letters: M, T, W, T, F, S, S).

---

### `DayCell`

A `Button` representing one day in the week strip.

| Property          | Notes                                             |
| ----------------- | ------------------------------------------------- |
| `date`            | The calendar date this cell represents            |
| `isSelected`      | Whether this is the currently selected day        |
| `isToday`         | Whether this date is today (for distinct styling) |
| `completionCount` | Number of completions on this day (0 = no dot)    |
| `onTap`           | Callback invoked when the cell is tapped          |

**Constants**:

| Constant | Value | Purpose |
| -------- | ----- | ------- |
| `cellHeight` | 48pt | Total cell height |
| `circleSize` | 40pt | Background circle diameter |
| `dotSize` | 6pt | Completion dot diameter |
| `animationDuration` | 0.2s | Selection animation duration |

Appearance:

- **Selected**: filled `primary` circle, white day number.
- **Today (not selected)**: light primary green filled circle, white bold day number.
- **Default**: no background, `textPrimary` day number.
- **Completion dot**: 6pt filled circle below the day number, visible when `completionCount > 0`; `primary` color on default cells, white on selected/today cells.

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

| Interaction                  | Animation                                                                              |
| ---------------------------- | -------------------------------------------------------------------------------------- |
| Day cell selection           | `.animation(.easeInOut(duration: 0.2), value: isSelected)` on the circle background   |
| Week navigation (swipe)      | Drag offset provides live visual feedback; on gesture end, strip snaps to new week     |

---

## Edge Cases & Error States

| Case                         | Handling                                                         |
| ---------------------------- | ---------------------------------------------------------------- |
| Network error on week counts | Dots silently omitted (non-critical); no error shown to user     |
| Week navigation boundaries   | No hard limit; users can navigate freely into the past or future |
