# Viably Design System — Tokens

## Color System

### Primary Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `primary` | `#4CAF50` | Primary brand color, CTAs, selected states, active elements |
| `primaryLight` | `#81C784` | Hover states, lighter accents |
| `primaryDark` | `#388E3C` | Pressed states, emphasis |

### Semantic Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `success` | `#66BB6A` | Completed habits, success messages, positive feedback |
| `warning` | `#FFC107` | Warnings, streaks at risk, attention needed |
| `error` | `#EF5350` | Errors, destructive actions, failed states |
| `info` | `#42A5F5` | Informational messages, tips, neutral feedback |

### Neutral Palette

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#EDE8DC` | Primary screen background |
| `backgroundSecondary` | `#F0EBE2` | Secondary backgrounds, grouped content |
| `backgroundTertiary` | `#E0D9CE` | Tertiary backgrounds, subtle dividers |
| `cardBackground` | `#FFFFFF` | Card surfaces, habit rows, template rows |
| `textPrimary` | `#2C3E2C` | Primary text, headings |
| `textSecondary` | `#6B7B6B` | Secondary text, captions, metadata |
| `textTertiary` | `#B0BCB0` | Disabled text, placeholder text |

### Heatmap Gradient

| Level | Hex | Completions |
|-------|-----|-------------|
| `heatmap0` | `#EBE8E0` | 0 |
| `heatmap1` | `#C8E6C9` | 1–2 |
| `heatmap2` | `#81C784` | 3–4 |
| `heatmap3` | `#4CAF50` | 5–6 |
| `heatmap4` | `#2E7D32` | 7+ |

### Chart Colors

| Token | Hex | Usage |
|-------|-----|-------|
| `chart1` | `#4CAF50` | Primary data series |
| `chart2` | `#F48FB1` | Secondary data series |
| `chart3` | `#42A5F5` | Tertiary data series |
| `chart4` | `#9575CD` | Quaternary data series |

---

## Typography

**Font**: Fira Sans Condensed — all styles use `.custom("FiraSansCondensed-...")`.

| Style | Size | Weight | Usage |
|-------|------|--------|-------|
| `largeTitle` | 34pt | Bold | Screen titles, onboarding |
| `title` | 28pt | Bold | Section headers, greeting |
| `title2` | 22pt | Bold | Card titles, modal headers |
| `title3` | 20pt | SemiBold | Subsection headers |
| `headline` | 17pt | SemiBold | List headers, emphasized text |
| `body` | 17pt | Regular | Body text, default text |
| `bodyEmphasized` | 17pt | Medium | Emphasized body text |
| `callout` | 16pt | Regular | Secondary body text |
| `subheadline` | 15pt | Regular | Metadata, descriptions |
| `footnote` | 13pt | Regular | Captions, helper text |
| `caption` | 12pt | Regular | Timestamps, tertiary info |
| `captionEmphasized` | 12pt | Medium | Emphasized captions |
| `button` | 17pt | SemiBold | Primary and secondary button labels |
| `buttonSmall` | 15pt | SemiBold | Small button labels, tab bar labels |
| `statLarge` | 28pt | SemiBold | Large stat numbers (profile, streaks) |
| `statMedium` | 20pt | SemiBold | Medium stat numbers |
| `statSmall` | 17pt | Medium | Small stat numbers |

---

## Spacing

4pt base unit.

| Token | Value |
|-------|-------|
| `xxSmall` | 4pt |
| `xSmall` | 8pt |
| `small` | 12pt |
| `medium` | 16pt |
| `large` | 24pt |
| `xLarge` | 32pt |
| `xxLarge` | 48pt |
| `xxxLarge` | 64pt |

---

## Corner Radius

| Token | Value | Usage |
|-------|-------|-------|
| `radiusSmall` | 8pt | Small buttons, tags, chips |
| `radiusMedium` | 12pt | Cards, input fields, medium buttons |
| `radiusLarge` | 16pt | Large cards, modals |
| `radiusXLarge` | 24pt | Hero elements, special cards |
| `radiusCapsule` | 999pt | Pill-shaped elements, `DayCell` |
| `radiusCircle` | 50% | Avatars, completion dots |

---

## Shadows

| Token | Configuration |
|-------|--------------|
| `shadowSmall` | `color: black.opacity(0.05), radius: 2, x: 0, y: 1` |
| `shadowMedium` | `color: black.opacity(0.1), radius: 8, x: 0, y: 4` |
| `shadowLarge` | `color: black.opacity(0.15), radius: 16, x: 0, y: 8` |

---

## Borders

| Token | Width |
|-------|-------|
| `borderThin` | 1pt |
| `borderMedium` | 2pt |
| `borderThick` | 3pt |

Border colors: `backgroundTertiary` for neutral, `primary` for active/selected.
