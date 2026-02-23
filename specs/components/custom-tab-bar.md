# CustomTabBar Spec

## Table of Contents

- [Overview](#overview)
- [UI Layout](#ui-layout)
- [User Interactions](#user-interactions)
- [Architecture & Components](#architecture--components)
- [Tab Index Reference](#tab-index-reference)
- [State Management](#state-management)
- [Design Tokens](#design-tokens)
- [Accessibility](#accessibility)
- [Edge Cases & Error States](#edge-cases--error-states)

---

## Overview

`CustomTabBar` is a fixed-height navigation bar rendered at the bottom of each top-level view (Home, Templates, Profile). It renders three tab buttons and communicates the active tab via a two-way `@Binding<Int>`. It replaces the system `TabView` to allow custom styling and persistent placement inside each full-screen view's own `VStack`.

```
App Root
  ├── HomeView               (selectedTab == 0) — renders CustomTabBar
  ├── TemplateLibraryView    (selectedTab == 1) — renders CustomTabBar
  └── ProfileView            (selectedTab == 2) — renders CustomTabBar
```

Each top-level view owns a `@Binding var selectedTab: Int` (threaded down from the root coordinator) and conditionally switches which content view is displayed. `CustomTabBar` receives a `$selectedTab` binding and mutates it when a tab is tapped.

---

## UI Layout

```
+------------------------------------------------+
|  [house.fill]   [checklist]   [person.circle]  |
|    Home          Templates        Profile       |
+------------------------------------------------+
     ↑ selected                ↑ unselected
   (primary color)         (textSecondary color)
```

- Fixed height: **60 pt**.
- Three equally-spaced tab buttons, each using `frame(maxWidth: .infinity)`.
- Each button renders a system icon (24 pt) vertically stacked above a caption label.
- A 1 pt separator line sits at the very top of the bar (`overlay` aligned `.top`).
- Background: `Color.theme.background`.

---

## User Interactions

| Interaction      | Result                                                  |
| ---------------- | ------------------------------------------------------- |
| Tap "Home"       | Sets `selectedTab = 0`; icon and label turn primary     |
| Tap "Templates"  | Sets `selectedTab = 1`; icon and label turn primary     |
| Tap "Profile"    | Sets `selectedTab = 2`; icon and label turn primary     |

There are no scroll or swipe gestures on the tab bar itself. There are no long-press or haptic interactions.

---

## Architecture & Components

### Component Tree

```
CustomTabBar (@Binding selectedTab)
  ├── TabBarButton (Home,      index 0)
  ├── TabBarButton (Templates, index 1)
  └── TabBarButton (Profile,   index 2)
```

---

### `CustomTabBar`

The public-facing component.

| Property      | Type           | Purpose                                        |
| ------------- | -------------- | ---------------------------------------------- |
| `selectedTab` | `Binding<Int>` | Two-way binding to the active tab index (0–2)  |

Renders an `HStack(spacing: 0)` of three `TabBarButton` instances at a fixed height, with a top divider applied as an `.overlay`.

---

### `TabBarButton` (private)

An internal button used exclusively by `CustomTabBar`.

| Property     | Type         | Purpose                                                |
| ------------ | ------------ | ------------------------------------------------------ |
| `icon`       | `String`     | SF Symbol name rendered as the button icon             |
| `title`      | `String`     | Label text displayed below the icon                    |
| `isSelected` | `Bool`       | Drives foreground color (primary vs. textSecondary)    |
| `action`     | `() -> Void` | Called when the button is tapped                       |

Renders a `Button` wrapping a `VStack(icon + label)`. Uses `frame(maxWidth: .infinity)` so all three buttons share equal width.

---

## Tab Index Reference

| Index | SF Symbol             | Label     | Destination View       |
| ----- | --------------------- | --------- | ---------------------- |
| 0     | `house.fill`          | Home      | `HomeView`             |
| 1     | `checklist`           | Templates | `TemplateLibraryView`  |
| 2     | `person.circle.fill`  | Profile   | `ProfileView`          |

---

## State Management

`selectedTab` is owned by the root coordinator or each top-level view and passed into `CustomTabBar` as a binding. `CustomTabBar` never owns state — it only reads and writes through the binding.

```swift
// In HomeView (same pattern in TemplateLibraryView & ProfileView)
@Binding var selectedTab: Int

// ...

CustomTabBar(selectedTab: $selectedTab)
```

`CustomTabBar` has no view models, no async operations, and no side effects beyond writing the `selectedTab` binding on tap.

---

## Design Tokens

| Token                   | Value / Source                  | Applied To                          |
| ----------------------- | ------------------------------- | ----------------------------------- |
| Height                  | `60 pt` (`Constants.height`)    | `HStack.frame(height:)`             |
| Icon size               | `24 pt` (`Constants.iconSize`)  | `Image.font(.system(size:))`        |
| Selected foreground     | `Color.theme.primary`           | Icon + label when `isSelected`      |
| Unselected foreground   | `Color.theme.textSecondary`     | Icon + label when not selected      |
| Background              | `Color.theme.background`        | Bar background                      |
| Divider color           | `Color.secondary.opacity(0.2)`  | Top separator line                  |
| Label font              | `Font.theme.caption`            | Tab label `Text`                    |
| Icon-to-label spacing   | `.spacing.xxSmall`              | `VStack(spacing:)` inside each button |

---

## Accessibility

- Each `TabBarButton` is a `Button`, which inherits SwiftUI's default accessibility role of `.button`.
- VoiceOver reads the `title` string (e.g. "Home", "Templates", "Profile") as the button's accessibility label because `Text(title)` is a direct child of the button.
- The SF Symbol `Image` is decorative in this context (the label conveys the same meaning), so no additional image accessibility label is needed.

**Known Gap**: `isSelected` is not explicitly annotated with `.accessibilityAddTraits(.isSelected)`. VoiceOver users cannot currently distinguish which tab is active. This should be added to `TabBarButton`.

---

## Edge Cases & Error States

| Case                                       | Handling                                                                     |
| ------------------------------------------ | ---------------------------------------------------------------------------- |
| `selectedTab` out of range (< 0 or > 2)    | No crash; no tab renders as selected (all icons use `textSecondary` color)   |
| Re-tapping the already-selected tab        | `selectedTab` is written with the same value; no visible change              |
| Very narrow screen (e.g. iPad split view)  | Buttons scale down proportionally via `frame(maxWidth: .infinity)` — no wrapping |
