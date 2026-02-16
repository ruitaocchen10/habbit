# CLAUDE.md

## Project Description

Habbit is a social habit tracking iOS app that helps users maintain long-term habits with community support.

**Core Features**:

- **Weekly Calendar View**: Main page displays the current week with daily habit lists. Users check off habits as they complete them each day.
- **Social Posts**: Users create daily posts sharing completed habits, comments, and photos. Posts are visible to friends, creating accountability and community.
- **Profile & Stats**: User profiles display streaks, completion counts, and a GitHub-style heatmap calendar where color intensity reflects daily task completion.
- **Habit Templates**: Users create reusable habit templates and activate them to make those habits appear daily until the template is deactivated.

## Bash Commands for Building and Testing

```bash
# Build for debug
xcodebuild -project habbit.xcodeproj -scheme habbit -configuration Debug build

# Build for release
xcodebuild -project habbit.xcodeproj -scheme habbit -configuration Release build

# Clean build folder
xcodebuild -project habbit.xcodeproj -scheme habbit clean

# Run on simulator
xcodebuild -project habbit.xcodeproj -scheme habbit -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
```

## Tech Stack and Architecture

**Technical Details**:

- **Framework**: SwiftUI with Swift 5.0
- **Target**: iOS 26.2, iPhone and iPad (universal)
- **Bundle ID**: com.ruitaochen.habbit
- **Development Team**: NS8CC9Z25V

**Key Features Enabled**:

- Swift concurrency with main actor isolation
- File system synchronized root groups (files auto-discovered)
- No UIKit dependencies

## Coding Style and Guidelines

**SwiftUI Conventions**:

- Use declarative SwiftUI views, avoid imperative UIKit patterns
- Leverage `@State`, `@Binding`, `@ObservedObject`, and `@EnvironmentObject` for state management
- Keep views focused and composable, extract complex views into separate components

**Code Organization**:

- Group related views in dedicated files (e.g., `CalendarView.swift`, `ProfileView.swift`)
- Place reusable components in a `Components/` folder
- Keep models and data structures in a `Models/` folder
- Use clear, descriptive names for views and functions

**Best Practices**:

- Utilize SwiftUI previews for rapid iteration
- Prefer value types (structs) over reference types (classes) where possible
- Use Swift's strong typing and avoid force unwrapping when possible
- Follow Swift naming conventions (camelCase for variables/functions, PascalCase for types)
