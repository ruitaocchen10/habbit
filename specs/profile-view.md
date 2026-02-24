# Habbit Profile View Spec

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

`ProfileView` is the profile screen (tab index 2). It displays the authenticated user's identity (avatar, name, email), two at-a-glance stat cards (current streak and total completions), a GitHub-style activity heatmap for the past year, and a sign-out button.

`ProfileView` owns a `ProfileViewModel` that fetches and aggregates completion stats. The `ActivityHeatmapView` component and `ProfileViewModel` are documented separately — see [`activity-heatmap.md`](components/activity-heatmap.md).

```
ProfileView (@State ProfileViewModel, @Environment AuthManager)
  ├── User Info section   (avatar, display name, email)
  ├── Stats section       (StatCard × 2: current streak, total completions)
  ├── Activity section    (ActivityHeatmapView) — see activity-heatmap.md
  └── Sign Out button
```

---

## UI Layout

```
+-----------------------------------------------+
|               Profile            (nav title)  |
+-----------------------------------------------+
|                                               |
|                  [avatar]                     |  <- 80pt circle; top padding large
|                                               |
|               Display Name                   |  <- title2, bold, textPrimary
|              user@email.com                  |  <- body, textSecondary
|                                               |
|  Stats                                        |  <- section title: title3, semibold
|  ┌──────────────────┐ ┌──────────────────┐   |
|  │  🔥 (background) │ │  ✅ (background) │   |  <- StatCard × 2
|  │  42              │ │  317             │   |
|  │  Current Streak  │ │  Total           │   |
|  │                  │ │  Completions     │   |
|  └──────────────────┘ └──────────────────┘   |
|                                               |
|  Activity                                     |  <- section title: title3, semibold
|  [ActivityHeatmapView]                        |  <- see activity-heatmap.md
|                                               |
|  [         Sign Out          ]                |  <- red full-width button
|                                               |
+-----------------------------------------------+
|         [house]  [list]  [person]             |  <- CustomTabBar
+-----------------------------------------------+
```

All content sits inside a `ScrollView` with a `VStack(spacing: 24)`. The `ScrollView` and `CustomTabBar` are arranged in a `VStack(spacing: 0)` inside a `NavigationStack`. `CustomTabBar` is placed directly below the `ScrollView` (not via `.safeAreaInset`).

---

### User Info Section

`VStack(spacing: .spacing.medium)` centered horizontally.

| Element       | Details                                                                                  |
| ------------- | ---------------------------------------------------------------------------------------- |
| Avatar        | 80pt circle; `AsyncImage` from OAuth `avatar_url` metadata when available; fallback is `person.circle.fill` SF Symbol in `textSecondary` color; `scaledToFill` + `.clipShape(Circle())` |
| Display name  | `Text(displayName)`, `title2` font, `bold` weight, `textPrimary`                        |
| Email         | `Text(email)`, `body` font, `textSecondary`                                              |

Avatar is given `padding(.top, .spacing.large)`. The section has `frame(maxWidth: .infinity)` and `padding(.horizontal)`.

---

### Stats Section

`VStack(alignment: .leading, spacing: .spacing.small)`.

- Section title: `"Stats"` in `title3` font, `semibold`, `textPrimary`, with `padding(.horizontal)`.
- Two `StatCard` views in an `HStack(spacing: .spacing.small)` with `padding(.horizontal)`.
- While `profileVM.isLoading == true`, both cards display `"-"` as the value.

| Card              | Value source                  | Icon                    | Icon color          |
| ----------------- | ----------------------------- | ----------------------- | ------------------- |
| Current Streak    | `profileVM.currentStreak`     | `"flame.fill"`          | `Color.orange`      |
| Total Completions | `profileVM.totalCompletions`  | `"checkmark.seal.fill"` | `Color.theme.primary` |

---

### Activity Section

`VStack(alignment: .leading, spacing: .spacing.small)` with `padding(.horizontal)`.

- Section title: `"Activity"` in `title3` font, `semibold`, `textPrimary`, with `padding(.horizontal)`.
- `ActivityHeatmapView(completionsByDate: profileVM.completionsByDate)` — see [`activity-heatmap.md`](components/activity-heatmap.md) for full details.

---

### Sign Out Button

Full-width button with:
- Label: `"Sign Out"`, `body` font, `medium` weight, white foreground.
- Background: `Color.red`.
- Corner radius: `.radius.medium`.
- Padding: `padding(.horizontal)`, `padding(.top, .spacing.medium)`.
- Action: `Task { await authManager.signOut() }`.

---

## User Interactions

| Interaction        | Result                                                                                  |
| ------------------ | --------------------------------------------------------------------------------------- |
| Tap "Sign Out"     | Calls `AuthManager.signOut()`; on success, `ContentView` switches to `LoginView`        |
| Scroll             | Standard vertical scroll through the profile content                                    |
| Horizontal scroll (heatmap) | Scrolls the heatmap grid — handled internally by `ActivityHeatmapView`       |

---

## Architecture & Components

### Component Tree

```
ProfileView (@Environment AuthManager, @State ProfileViewModel)
  ├── NavigationStack
  │     └── VStack(spacing: 0)
  │           ├── ScrollView
  │           │     ├── User Info Section
  │           │     │     ├── AsyncImage (avatar)         ← or SF Symbol fallback
  │           │     │     ├── Text (display name)
  │           │     │     └── Text (email)
  │           │     ├── Stats Section
  │           │     │     ├── StatCard (Current Streak)
  │           │     │     └── StatCard (Total Completions)
  │           │     ├── Activity Section
  │           │     │     └── ActivityHeatmapView(completionsByDate:)
  │           │     └── Sign Out Button
  │           └── CustomTabBar(selectedTab:)
```

---

### `ProfileView`

| Property / Dependency | Type / Source                    | Purpose                                                         |
| --------------------- | -------------------------------- | --------------------------------------------------------------- |
| `authManager`         | `@Environment(AuthManager.self)` | Reads session metadata for name / email / avatar; calls `signOut()` |
| `profileVM`           | `@State ProfileViewModel`        | Owns all stats and heatmap data fetching                        |
| `selectedTab`         | `@Binding Int`                   | Forwarded to `CustomTabBar`                                     |

**Computed properties (private)**:

| Property      | Return type | Logic                                                                                              |
| ------------- | ----------- | -------------------------------------------------------------------------------------------------- |
| `displayName` | `String`    | `userMetadata["full_name"]` (string) → fallback: `session.user.email` → fallback: `"User"`        |
| `email`       | `String`    | `session.user.email` → fallback: `""`                                                              |
| `avatarURL`   | `URL?`      | `userMetadata["avatar_url"]` (string) parsed as `URL`; `nil` if missing or unparseable             |

---

### `StatCard`

A private view used exclusively within `ProfileView`.

```
ZStack(alignment: .bottomTrailing)
  Image(systemName: icon)       ← decorative, 56pt, bold, opacity 12%
  VStack(alignment: .leading)
    Text(value)                 ← largeTitle font, bold, numericText transition
    Text(label)                 ← subheadline font, textSecondary, fixed size vertical
```

| Property   | Type     | Notes                                                                    |
| ---------- | -------- | ------------------------------------------------------------------------ |
| `value`    | `String` | Numeric string (or `"-"` during loading)                                 |
| `label`    | `String` | Descriptive label (e.g. "Current Streak", "Total Completions")           |
| `icon`     | `String` | SF Symbol name for the decorative background                             |
| `iconColor`| `Color`  | Tint applied to the decorative icon                                      |

**Design tokens**:

| Token            | Value / Source           | Applied to                                  |
| ---------------- | ------------------------ | ------------------------------------------- |
| Background       | `Color.theme.cardBackground` | Card fill                               |
| Corner radius    | `.radius.large`          | `cornerRadius` modifier                     |
| Content padding  | `.spacing.medium`        | Inner `VStack` padding                      |
| Value font       | `Font.theme.largeTitle`  | Stat number text                            |
| Label font       | `Font.theme.subheadline` | Stat description text                       |
| Icon size        | 56pt, `.bold` weight     | Decorative background SF Symbol             |
| Icon opacity     | 12% (`opacity(0.12)`)    | Decorative background icon                  |

The value text uses `.contentTransition(.numericText())` so that number changes animate smoothly.

---

## State Management

`ProfileViewModel` is created as `@State` in `ProfileView` and is not shared with any sibling or parent view. `ActivityHeatmapView` is a pure display component that receives only the pre-aggregated `completionsByDate` dictionary — it has no reference to the view model.

```
ProfileView
  @State profileVM: ProfileViewModel
    |
    +-- .task { await profileVM.loadStats() }     ← triggered on view appear
    |
    +-- StatCard(value: "\(profileVM.currentStreak)", ...)
    +-- StatCard(value: "\(profileVM.totalCompletions)", ...)
    +-- ActivityHeatmapView(completionsByDate: profileVM.completionsByDate)
```

While `profileVM.isLoading == true`:
- `StatCard` values display `"-"`.
- `ActivityHeatmapView` receives an empty `[:]` dictionary and renders all cells at level 0.

See [`activity-heatmap.md`](components/activity-heatmap.md) for `ProfileViewModel` property and method documentation.

---

## Data Fetching

All fetching is delegated to `ProfileViewModel.loadStats()`. `ProfileView` only triggers the fetch:

```swift
// In ProfileView
.task {
    await profileVM.loadStats()
}
```

`loadStats()` fetches the past year of `habit_completions` in a single query, then derives `currentStreak`, `totalCompletions`, and `completionsByDate` from the result. See [`activity-heatmap.md → Data Fetching`](components/activity-heatmap.md#data-fetching) for the full query and aggregation logic.

---

## Edge Cases & Error States

| Case                                    | Handling                                                                                          |
| --------------------------------------- | ------------------------------------------------------------------------------------------------- |
| No `avatar_url` in OAuth metadata       | `avatarURL` is `nil`; `person.circle.fill` SF Symbol shown as fallback                           |
| Avatar URL is invalid / image fails     | `AsyncImage` placeholder (`person.circle.fill`) shown while loading or on error                  |
| No `full_name` in OAuth metadata        | Falls back to `session.user.email`; if also missing, shows `"User"`                              |
| Stats loading in progress               | `StatCard` values show `"-"`; heatmap renders all cells at level 0 (no spinner inside the cards) |
| Stats fetch fails                       | `profileVM.errorMessage` is set (non-nil); no error UI is currently shown in `ProfileView` — the screen renders with `"-"` stats and an empty heatmap |
| Sign-out error                          | `AuthManager.errorMessage` is set; no dedicated error UI is shown from `ProfileView`; the user remains on the profile screen |
| New user with no completions            | `currentStreak = 0`, `totalCompletions = 0`; heatmap renders all cells at level 0 (beige)        |
