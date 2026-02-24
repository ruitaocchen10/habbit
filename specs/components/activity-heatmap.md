# Activity Heatmap Component Spec

## Table of Contents

- [Overview](#overview)
- [UI Layout](#ui-layout)
- [User Interactions](#user-interactions)
- [Data Requirements](#data-requirements)
- [Architecture & Components](#architecture--components)
- [State Management](#state-management)
- [Data Fetching](#data-fetching)
- [Design Tokens](#design-tokens)
- [Edge Cases & Error States](#edge-cases--error-states)

---

## Overview

`ActivityHeatmapView` is a GitHub-style activity grid showing the past 52 weeks (plus the current partial week) of habit completions. It lives inside `ProfileView` beneath the Stats cards and is a read-only display component — it accepts a pre-aggregated dictionary and has no interaction beyond scrolling.

`ProfileViewModel` owns all data fetching and aggregation. `ProfileView` passes the result directly into the view.

```
ProfileView (@State ProfileViewModel)
  ├── User Info section
  ├── Stats section (StatCard × 2)
  └── Activity section
        └── ActivityHeatmapView(completionsByDate:)   ← this spec
```

---

## UI Layout

```
+---------------------------------------------------------------+
|  Su              Jan          Feb          Mar               |  <- month labels row
|  Tu  [ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]...   |
|  Th  [ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]...   |  <- 7-row day grid
|  Sa  [ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ][ ]...   |    scrolls horizontally
|                                                               |    oldest ← → newest
|  Less  □ □ □ □ □  More                                       |  <- legend row
+---------------------------------------------------------------+
```

### Grid structure

- **Columns** = weeks, oldest on the left, most recent on the right. 53 total columns (52 weeks back + current partial week).
- **Rows** = days of the week, Sunday (index 0) at the top, Saturday (index 6) at the bottom.
- Each cell is an 11 × 11 pt `RoundedRectangle(cornerRadius: 2)` filled with a color from the heatmap palette.
- Future dates within the current week are rendered as `Color.clear` placeholders.
- The grid is horizontally scrollable; on appear it jumps to the trailing (most recent) edge.

### Day label column (fixed, non-scrolling)

A fixed 20 pt wide column to the left of the grid. Labels appear only for every other row to avoid crowding:

| Row index | Label |
| --------- | ----- |
| 0 (Sun)   | `Su`  |
| 1 (Mon)   | *(empty)* |
| 2 (Tue)   | `Tu`  |
| 3 (Wed)   | *(empty)* |
| 4 (Thu)   | `Th`  |
| 5 (Fri)   | *(empty)* |
| 6 (Sat)   | `Sa`  |

### Month label row

- Rendered as the top row of each scrollable week column (height: 16 pt).
- A 3-letter abbreviated month name (e.g. `Jan`) is shown when that week contains the 1st day of a month.
- The leftmost column (week index 0) always shows its month abbreviation for orientation.
- All other week columns that do not contain a 1st render an empty string.

### Legend row

Pinned below the grid with `xSmall` top padding. Reads left to right:

```
Less  [level-0] [level-1] [level-2] [level-3] [level-4]  More
```

Legend cells use the same 11 × 11 pt size and represent counts 0, 1, 3, 5, 7.

---

## User Interactions

`ActivityHeatmapView` is read-only. The only supported interaction is horizontal scrolling.

| Interaction             | Result                                              |
| ----------------------- | --------------------------------------------------- |
| Horizontal swipe/scroll | Scrolls the week columns left or right              |
| View appear             | Automatically scrolls to the most recent week (trailing anchor) |

There are no tap targets, selection states, or navigation actions on individual cells.

---

## Data Requirements

### Tables Used

| Table               | Usage                                                             |
| ------------------- | ----------------------------------------------------------------- |
| `habit_completions` | One row per completed habit instance; aggregated by `completed_date` |

### Query (logical equivalent)

```sql
SELECT completed_date, COUNT(*) AS count
FROM habit_completions
WHERE user_id  = :userId
  AND completed_date >= :oneYearAgo
GROUP BY completed_date
```

### Aggregated shape passed to the view

```swift
// Dictionary keys are ISO date strings ("yyyy-MM-dd")
let completionsByDate: [String: Int]
// e.g. ["2025-01-15": 3, "2025-01-16": 5, "2025-02-01": 1]
```

Any date absent from the dictionary is treated as 0 completions.

---

## Architecture & Components

### Component Tree

```
ActivityHeatmapView(completionsByDate: [String: Int])
  ├── dayLabelsColumn          (fixed VStack, non-scrolling)
  └── scrollableGrid           (ScrollViewReader > ScrollView(.horizontal))
        └── weekColumn × 53   (VStack: month label + 7 day cells)
  └── heatmapLegend            (HStack: "Less", 5 cells, "More")
```

---

### `ActivityHeatmapView`

The sole public view. It is a pure display component with no view model of its own.

| Property            | Type            | Purpose                                              |
| ------------------- | --------------- | ---------------------------------------------------- |
| `completionsByDate` | `[String: Int]` | Date strings (`yyyy-MM-dd`) mapped to completion count |

**Layout constants** (private, not configurable from outside):

| Constant          | Value  | Purpose                                  |
| ----------------- | ------ | ---------------------------------------- |
| `cellSize`        | 11 pt  | Width and height of each day cell        |
| `cellSpacing`     | 2 pt   | Gap between cells (horizontal and vertical) |
| `monthLabelHeight`| 16 pt  | Height of the month label row            |
| `dayLabelWidth`   | 20 pt  | Width of the fixed day-label column      |

---

### `ProfileViewModel`

An `@Observable` class created as `@State` in `ProfileView`. It is responsible for fetching, aggregating, and exposing stats data.

| Property            | Type            | Purpose                                                       |
| ------------------- | --------------- | ------------------------------------------------------------- |
| `currentStreak`     | `Int`           | Consecutive days with ≥1 completion (backwards from today)    |
| `totalCompletions`  | `Int`           | Total number of completion rows in the past year              |
| `completionsByDate` | `[String: Int]` | Aggregated date → count dictionary passed to `ActivityHeatmapView` |
| `isLoading`         | `Bool`          | True while the Supabase query is in-flight                    |
| `errorMessage`      | `String?`       | Set to `error.localizedDescription` on failure; `nil` on success |

| Method        | Purpose                                                                                 |
| ------------- | --------------------------------------------------------------------------------------- |
| `loadStats()` | Fetches the past year of completions, aggregates them, and sets all published properties |

---

## State Management

`ProfileViewModel` is created as `@State` inside `ProfileView` and is not shared with any other view. `ActivityHeatmapView` receives only the already-computed `completionsByDate` dictionary — it has no reference to the view model.

```
ProfileView (@State profileVM: ProfileViewModel)
  |
  +-- profileVM.loadStats()        ← triggered by .task on appear
  |
  +-- ActivityHeatmapView(
        completionsByDate: profileVM.completionsByDate
      )
```

While `profileVM.isLoading` is `true`, `completionsByDate` is an empty dictionary `[:]`, so the heatmap renders all cells at level 0 (no completions color).

---

## Data Fetching

All Supabase calls use `async/await`. `ProfileViewModel` is `@MainActor`-isolated, so all property mutations are safe.

### On View Appear

```swift
// In ProfileView
.task {
    await profileVM.loadStats()
}
```

### Inside `loadStats()`

1. Retrieve the authenticated user's UUID from `SupabaseService.client.auth.session`.
2. Calculate `oneYearAgo` as 1 year before `Date()` using `Calendar.current`.
3. Query `habit_completions` filtered by `user_id` and `completed_date >= oneYearAgo`.
4. Aggregate the result array into `[String: Int]` by iterating and incrementing `byDate[completion.completedDate.isoDateString]`.
5. Set `completionsByDate`, `totalCompletions`, and `currentStreak` from the aggregated data.

### Streak calculation

Counts consecutive days with ≥1 completion going backwards from today:

- If today has 0 completions, start counting from yesterday (streak is still alive for the current day).
- Walk backwards day-by-day until a day with 0 completions is found.
- The count of days walked is the `currentStreak`.

---

## Design Tokens

### Heatmap color ramp

| Level | Completion count | Hex       | Description          |
| ----- | ---------------- | --------- | -------------------- |
| 0     | 0                | `#EBE8E0` | Light neutral beige  |
| 1     | 1–2              | `#C8E6C9` | Pale spring green    |
| 2     | 3–4              | `#81C784` | Light grass green    |
| 3     | 5–6              | `#4CAF50` | Vibrant spring green |
| 4     | 7+               | `#2E7D32` | Deep forest green    |

Accessed via `Color.theme.heatmapColor(for: count)`.

### Spacing & shape

| Token                 | Value  | Applied To                              |
| --------------------- | ------ | --------------------------------------- |
| Card padding          | 16 pt (`spacing.medium`) | All four sides of the card container |
| Card corner radius    | 12 pt (`radius.medium`)  | Card background                      |
| Cell corner radius    | 2 pt                     | Each day cell and legend cell        |
| Legend spacing        | 8 pt (`spacing.xSmall`)  | Between legend items                 |

### Typography

| Token           | Value                                      | Applied To                     |
| --------------- | ------------------------------------------ | ------------------------------ |
| `Font.theme.caption` | FiraSansCondensed-Regular, 12 pt      | Day labels, month labels, legend "Less"/"More" text |

### Colors

| Token                        | Applied To                              |
| ---------------------------- | --------------------------------------- |
| `Color.theme.backgroundSecondary` | Card background (`#F0EBE2`)        |
| `Color.theme.textTertiary`        | Day labels, month labels, legend text |

---

## Edge Cases & Error States

| Case                              | Handling                                                                                  |
| --------------------------------- | ----------------------------------------------------------------------------------------- |
| Data loading in progress          | `completionsByDate` is `[:]`; all cells render at level 0 (beige). No skeleton or spinner inside the heatmap itself. |
| Network / auth error              | `profileVM.errorMessage` is set; heatmap stays at all-level-0. No error UI is shown inside `ActivityHeatmapView`. |
| No completions (new user)         | All cells render at level 0; legend and labels still display normally.                    |
| Future dates in the current week  | Rendered as `Color.clear` transparent placeholders (no colored cell).                     |
| Current week is a full 7-day week | All 7 cells are valid dates; no transparent placeholders needed.                          |
| Very high completion count (> 7)  | `heatmapColor(for:)` uses `default:` branch → level 4 (deep forest green). No overflow.   |
| First column month label          | Always shows the abbreviated month name of its first non-nil date for orientation, even if that date is not the 1st of the month. |
