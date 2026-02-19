# Habbit Design System

## Table of Contents

- [Design Philosophy](#design-philosophy)
- [Color System](#color-system)
- [Typography](#typography)
- [Spacing System](#spacing-system)
- [Layout & Structure](#layout--structure)
- [Components Library](#components-library)
- [Patterns & Best Practices](#patterns--best-practices)

---

## Design Philosophy

### Vision

Habbit's design is **vibrant, energetic, and celebrates progress**. Every interaction should make users feel motivated and supported in their habit-building journey. The interface combines the energy of social accountability with the clarity of data-driven insights.

### Personality Traits

- **Energetic** - Bright colors, smooth animations, and punchy visual feedback
- **Supportive** - Encouraging language, positive reinforcement, celebrate small wins
- **Social** - Warm, approachable, community-focused
- **Clear** - Data is beautiful but never overwhelming; information hierarchy is obvious

### Design Principles

1. **Encourage without overwhelming** - Show progress clearly but don't guilt users
2. **Make data beautiful** - Heatmaps and stats should inspire, not intimidate
3. **Celebrate small wins** - Every completion deserves recognition
4. **Social first** - Design for connection and shared accountability
5. **Consistency breeds habits** - Predictable UI patterns mirror habit formation

---

## Color System

### Primary Palette (Spring Green - Growth & Renewal)

| Token | Hex | Usage |
|-------|-----|-------|
| `primary` | `#4CAF50` | Fresh spring green - primary brand color, CTAs, selected states, active elements |
| `primaryLight` | `#81C784` | Light sage green - hover states, lighter accents |
| `primaryDark` | `#388E3C` | Deep forest green - pressed states, emphasis |

**Design Rationale**: Spring green represents growth, renewal, and the fresh energy of habit formation. This color evokes the feeling of new grass, sprouting plants, and natural progress.

---

### Semantic Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `success` | `#66BB6A` | Vibrant grass green - completed habits, success messages, positive feedback |
| `warning` | `#FFC107` | Warm golden yellow (spring sunshine) - warnings, streaks at risk, attention needed |
| `error` | `#EF5350` | Soft coral red - errors, destructive actions, failed states |
| `info` | `#42A5F5` | Spring sky blue - informational messages, tips, neutral feedback |

---

### Neutral Palette (Warm Spring Tones)

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#FFFEF9` | Warm cream - primary background, soft and inviting |
| `backgroundSecondary` | `#F5F9F5` | Very light sage - secondary backgrounds, cards, grouped content (subtle green tint) |
| `backgroundTertiary` | `#EBE8E0` | Warm beige - tertiary backgrounds, subtle dividers |
| `textPrimary` | `#2C3E2C` | Deep olive - primary text, headings (warmer than pure black) |
| `textSecondary` | `#6B7B6B` | Soft gray-green - secondary text, captions, metadata |
| `textTertiary` | `#B0BCB0` | Light sage gray - disabled text, placeholder text |

**Design Rationale**: Warm neutrals with green undertones create a cohesive spring aesthetic. The cream background feels inviting and soft, while the olive text provides excellent readability with a natural, organic feel.

---

### Data Visualization Colors

#### Heatmap Gradient (Spring Green Progression)

| Level | Hex | Usage |
|-------|-----|-------|
| `heatmap0` | `#EBE8E0` | No completions (light neutral) |
| `heatmap1` | `#C8E6C9` | 1-2 completions (pale spring green) |
| `heatmap2` | `#81C784` | 3-4 completions (light grass green) |
| `heatmap3` | `#4CAF50` | 5-6 completions (vibrant spring green) |
| `heatmap4` | `#2E7D32` | 7+ completions (deep forest green) |

**Design Rationale**: The heatmap uses a cohesive green progression that matches the primary brand color. Each step represents increasing growth and progress, reinforcing the spring growth metaphor.

#### Chart Colors (Spring Palette)

| Token | Hex | Usage |
|-------|-----|-------|
| `chart1` | `#4CAF50` | Spring green - primary data series |
| `chart2` | `#F48FB1` | Cherry blossom pink - secondary data series |
| `chart3` | `#42A5F5` | Spring sky blue - tertiary data series |
| `chart4` | `#9575CD` | Soft lavender - quaternary data series |

**Design Rationale**: Chart colors evoke a spring garden - fresh greens, blooming pinks, clear blue skies, and soft purple florals.

---

## Typography

### Type Scale

| Style | Font | Size | Weight | Line Height | Usage |
|-------|------|------|--------|-------------|-------|
| `largeTitle` | SF Pro | 34pt | Bold | 41pt | Screen titles, onboarding |
| `title` | SF Pro | 28pt | Bold | 34pt | Section headers, greeting |
| `title2` | SF Pro | 22pt | Bold | 28pt | Card titles, modal headers |
| `title3` | SF Pro | 20pt | Semibold | 25pt | Subsection headers |
| `headline` | SF Pro | 17pt | Semibold | 22pt | List headers, emphasized text |
| `body` | SF Pro | 17pt | Regular | 22pt | Body text, default text |
| `callout` | SF Pro | 16pt | Regular | 21pt | Secondary body text |
| `subheadline` | SF Pro | 15pt | Regular | 20pt | Metadata, descriptions |
| `footnote` | SF Pro | 13pt | Regular | 18pt | Captions, helper text |
| `caption` | SF Pro | 12pt | Regular | 16pt | Timestamps, tertiary info |

### Font Weights

- **Bold (700)** - Screen titles, primary headings, emphasis
- **Semibold (600)** - Buttons, section headers, labels
- **Medium (500)** - Active/selected states
- **Regular (400)** - Body text, default state

### Usage Guidelines

- **Headings**: Use bold or semibold weights for hierarchy
- **Buttons**: Always use semibold for text
- **Numbers/Stats**: Use medium or semibold to emphasize data
- **Today's date**: Bold when not selected (see `DayCell`)

---

## Spacing System

### Scale (4pt base unit)

| Token | Value | Usage |
|-------|-------|-------|
| `xxSmall` | 4pt | Tight spacing, icon padding |
| `xSmall` | 8pt | Compact spacing, between related elements |
| `small` | 12pt | Standard spacing within components |
| `medium` | 16pt | Default padding, margins |
| `large` | 24pt | Section spacing, card padding |
| `xLarge` | 32pt | Screen margins, major sections |
| `xxLarge` | 48pt | Large gaps, spacers |
| `xxxLarge` | 64pt | Maximum spacing, empty states |

### Component Spacing

- **Button padding**: Vertical `small` (12pt), Horizontal `medium` (16pt)
- **Card padding**: `large` (24pt)
- **List item spacing**: `medium` (16pt) between items
- **Screen padding**: `medium` (16pt) horizontal margins
- **Section spacing**: `large` (24pt) between major sections

---

## Layout & Structure

### Corner Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radiusSmall` | 8pt | Small buttons, tags, chips |
| `radiusMedium` | 12pt | Cards, input fields, medium buttons |
| `radiusLarge` | 16pt | Large cards, modals |
| `radiusXLarge` | 24pt | Hero elements, special cards |
| `radiusCapsule` | 999pt | Pill-shaped elements, `DayCell` |
| `radiusCircle` | 50% | Avatars, completion dots |

### Shadows

| Token | Configuration | Usage |
|-------|--------------|-------|
| `shadowSmall` | `color: black.opacity(0.05), radius: 2, x: 0, y: 1` | Subtle elevation, list items |
| `shadowMedium` | `color: black.opacity(0.1), radius: 8, x: 0, y: 4` | Cards, floating elements |
| `shadowLarge` | `color: black.opacity(0.15), radius: 16, x: 0, y: 8` | Modals, overlays |

### Borders

| Token | Width | Usage |
|-------|-------|-------|
| `borderThin` | 1pt | Dividers, subtle outlines |
| `borderMedium` | 2pt | Input focus states, emphasized borders |
| `borderThick` | 3pt | Strong emphasis, selection indicators |

**Border Colors**: Use `backgroundTertiary` (#E5E5EA) for neutral borders, `primary` for active/selected borders.

---

## Components Library

### Buttons

#### Primary Button

**Visual**:
- Background: `primary` color
- Text: White, `semibold` weight
- Padding: 12pt vertical, 16pt horizontal
- Corner radius: `radiusMedium` (12pt)
- Min height: 44pt (touch target)

**States**:
- Default: Full opacity
- Pressed: 70% opacity
- Disabled: 40% opacity, gray background

**Usage**: Primary actions, CTAs (e.g., "Create Habit", "Save", "Post")

---

#### Secondary Button

**Visual**:
- Background: `backgroundSecondary` with blur effect (`.regularMaterial`)
- Text: `primary` color, `semibold` weight
- Padding: 12pt vertical, 16pt horizontal
- Corner radius: `radiusMedium` (12pt)

**Usage**: Secondary actions, OAuth buttons (see `LoginView.swift:61-80`)

---

#### Ghost Button

**Visual**:
- Background: Transparent
- Text: `primary` color, `semibold` weight
- Padding: 8pt vertical, 12pt horizontal

**Usage**: Tertiary actions, navigation items, "Cancel" buttons

---

### Calendar Components

#### DayCell

**Reference**: `habbit/Views/Components/DayCell.swift`

**Visual**:
- Size: 44pt wide, 64pt tall
- Shape: Capsule (`radiusCapsule`)
- Spacing: 4pt between day name, number, and dot

**States**:
- **Default**: Clear background, `textSecondary` day name, `textPrimary` day number
- **Today (not selected)**: Day number in `primary` color, bold weight
- **Selected**: `primary` background, white text
- **With completions**: 6pt dot below number, `primary` color (white when selected)

**Animation**: `.easeInOut(duration: 0.2)` on selection

---

#### Completion Dot

**Visual**:
- Size: 6pt diameter
- Shape: Circle
- Color: `primary` (or white on selected background)
- Opacity: 0 when no completions, 1 when completions exist

**Usage**: Indicates habit completion on calendar days

---

### Cards

#### Social Post Card

**Visual** _(to be designed)_:
- Background: `background` (white)
- Shadow: `shadowMedium`
- Corner radius: `radiusLarge` (16pt)
- Padding: `large` (24pt)
- Spacing: `medium` (16pt) between elements

**Content**:
- User avatar (32pt circle)
- Username (`headline` style)
- Post timestamp (`caption` style, `textSecondary`)
- Completed habits list
- Optional photo
- Comment/like actions

---

#### Habit Row

**Visual** _(to be designed)_:
- Min height: 56pt
- Padding: `medium` (16pt) horizontal
- Background: `background`
- Divider: `borderThin`, `backgroundTertiary` color

**Content**:
- Habit name (`body` style, `textPrimary`)
- Completion checkbox (28pt, `radiusMedium`)
- Swipe actions (edit, delete)

**States**:
- Completed: Strikethrough text, checkmark in `success` color
- Incomplete: Empty checkbox

---

### Heatmap Cell

**Visual** _(to be designed)_:
- Size: 12pt square (or larger for iPad)
- Shape: Rounded square (`radiusSmall` or 2pt)
- Spacing: 2pt gap between cells
- Color: `heatmap0` through `heatmap4` based on completion count

**Interaction**:
- Tap: Show tooltip with date and completion count
- Hover (iPad): Preview completions for that day

---

### Inputs

#### Text Field

**Visual**:
- Background: `backgroundSecondary`
- Padding: `small` (12pt) vertical, `medium` (16pt) horizontal
- Corner radius: `radiusMedium` (12pt)
- Border: `borderMedium` (2pt) on focus, `primary` color

**States**:
- Default: No border
- Focused: `primary` border
- Error: `error` border, helper text in `error` color

---

## Patterns & Best Practices

### Loading States

- Use native SwiftUI `ProgressView()` with `.tint(primary)` color
- For skeleton screens: Use `backgroundSecondary` with subtle shimmer animation
- Loading text: "Loading habits..." in `textSecondary`

---

### Empty States

**Visual**:
- Icon: SF Symbol, 48pt size, `textTertiary` color
- Heading: `title3` style, "No habits yet"
- Description: `subheadline` style, `textSecondary`
- CTA: Primary button, "Create Your First Habit"

**Spacing**:
- 24pt gap between icon and heading
- 12pt gap between heading and description
- 24pt gap before CTA button

---

### Error States

**Visual**:
- Background: `error` color at 10% opacity
- Icon: `exclamationmark.triangle.fill`, `error` color
- Text: `callout` style, `error` color
- Padding: `medium` (16pt)
- Corner radius: `radiusMedium` (12pt)

**Usage**: Network errors, form validation errors, failed operations

---

### Success States / Feedback

**Toast/Banner**:
- Background: `success` color
- Text: White, `subheadline` style, semibold
- Padding: `small` (12pt) vertical, `medium` (16pt) horizontal
- Corner radius: `radiusMedium` (12pt)
- Shadow: `shadowMedium`
- Duration: 2-3 seconds
- Animation: Slide in from top, fade out

**Haptic Feedback**:
- On habit completion: `.notification(.success)` haptic
- On streak milestone: `.notification(.success)` + visual confetti (optional)

---

### Animations

| Interaction | Animation | Duration | Easing |
|-------------|-----------|----------|--------|
| Button press | Scale down to 0.95 | 0.1s | `.easeInOut` |
| Selection (e.g., `DayCell`) | Background color change | 0.2s | `.easeInOut` |
| Week navigation | Slide transition | 0.3s | `.easeInOut` |
| Modal presentation | Slide up | 0.3s | `.spring(response: 0.3)` |
| Completion checkmark | Scale + rotation | 0.4s | `.spring(response: 0.4)` |
| Toast/Banner | Slide in/fade out | 0.3s | `.easeOut` / `.easeIn` |

**Principles**:
- Keep animations snappy (< 0.5s) to maintain energy
- Use spring animations for playful, organic feel
- Avoid animations on every interaction; reserve for meaningful feedback

---

### Accessibility

- **Minimum touch targets**: 44pt × 44pt (Apple HIG standard)
- **Color contrast**: Minimum 4.5:1 for body text, 3:1 for large text
- **Dynamic Type**: Support iOS Dynamic Type for all text styles
- **VoiceOver**: Label all interactive elements, provide hints for complex interactions
- **Reduce Motion**: Respect `UIAccessibility.isReduceMotionEnabled`, use opacity changes instead of animations

---

## Implementation Notes

### File Structure

```
habbit/
└── Theme/
    ├── Tokens/
    │   ├── Colors.swift          // Color+Theme extension
    │   ├── Typography.swift      // Font+Theme extension
    │   ├── Spacing.swift         // CGFloat constants
    │   ├── CornerRadius.swift    // CGFloat constants
    │   └── Shadows.swift         // ViewModifier for shadows
    └── Components/
        ├── HabbitButton.swift         // Primary/Secondary button components
        ├── CompletionButton.swift     // Checkmark button for habits
        ├── HeatmapCell.swift          // Heatmap calendar cell
        └── SocialPostCard.swift       // Social post card component
```

### Token Usage Example

```swift
// In any SwiftUI view:
Text("Hello, Habbit!")
    .font(.theme.title)
    .foregroundStyle(.theme.primary)
    .padding(.theme.spacing.medium)
    .background(.theme.background)
    .cornerRadius(.theme.radius.medium)
```

### Component Usage Example

```swift
// Using a reusable component:
HabbitButton(style: .primary, title: "Complete Habit") {
    // Action
}
```

---

## Revision History

| Date | Version | Changes |
|------|---------|---------|
| 2026-02-19 | 1.1 | Updated to spring theme aesthetic - greens, warm neutrals, spring palette |
| 2026-02-19 | 1.0 | Initial design system spec created |

---

**Next Steps**:
1. Finalize color hex values (replace placeholders)
2. Implement token files in `Theme/Tokens/`
3. Refactor existing components to use theme tokens
4. Build reusable component library
5. Document component usage in Xcode previews
