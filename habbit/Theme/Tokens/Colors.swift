//
//  Colors.swift
//  habbit
//
//  Design System Color Tokens
//

import SwiftUI

extension Color {
    struct Theme {
        // MARK: - Primary Palette (Spring Green - Growth & Renewal)

        /// Primary brand color - fresh spring green, like new grass and growth
        static let primary = Color(hex: "#4CAF50")

        /// Lighter shade of primary - light sage green for hover states
        static let primaryLight = Color(hex: "#81C784")

        /// Darker shade of primary - deep forest green for pressed states
        static let primaryDark = Color(hex: "#388E3C")

        // MARK: - Semantic Colors

        /// Success color - vibrant grass green for completed habits
        static let success = Color(hex: "#66BB6A")

        /// Warning color - warm golden yellow, like spring sunshine
        static let warning = Color(hex: "#FFC107")

        /// Error color - soft coral red, gentler than harsh red
        static let error = Color(hex: "#EF5350")

        /// Info color - spring sky blue
        static let info = Color(hex: "#42A5F5")

        // MARK: - Neutral Palette (Warm Spring Tones)

        /// Primary background color - warm cream, soft and inviting
        static let background = Color(hex: "#FFFEF9")

        /// Secondary background - very light sage with subtle green tint
        static let backgroundSecondary = Color(hex: "#F5F9F5")

        /// Tertiary background - warm beige for subtle dividers
        static let backgroundTertiary = Color(hex: "#EBE8E0")

        /// Primary text color - deep olive, warmer than pure black
        static let textPrimary = Color(hex: "#2C3E2C")

        /// Secondary text - soft gray-green for captions and metadata
        static let textSecondary = Color(hex: "#6B7B6B")

        /// Tertiary text - light sage gray for disabled states
        static let textTertiary = Color(hex: "#B0BCB0")

        // MARK: - Heatmap Gradient (Spring Green Progression)

        /// No completions (light neutral)
        static let heatmap0 = Color(hex: "#EBE8E0")

        /// 1-2 completions (pale spring green)
        static let heatmap1 = Color(hex: "#C8E6C9")

        /// 3-4 completions (light grass green)
        static let heatmap2 = Color(hex: "#81C784")

        /// 5-6 completions (vibrant spring green)
        static let heatmap3 = Color(hex: "#4CAF50")

        /// 7+ completions (deep forest green)
        static let heatmap4 = Color(hex: "#2E7D32")

        /// Returns heatmap color based on completion count
        static func heatmapColor(for count: Int) -> Color {
            switch count {
            case 0:
                return heatmap0
            case 1...2:
                return heatmap1
            case 3...4:
                return heatmap2
            case 5...6:
                return heatmap3
            default:
                return heatmap4
            }
        }

        // MARK: - Chart Colors (Spring Palette)

        /// Primary data series - spring green
        static let chart1 = Color(hex: "#4CAF50")

        /// Secondary data series - cherry blossom pink
        static let chart2 = Color(hex: "#F48FB1")

        /// Tertiary data series - spring sky blue
        static let chart3 = Color(hex: "#42A5F5")

        /// Quaternary data series - soft lavender
        static let chart4 = Color(hex: "#9575CD")
    }
}

// MARK: - Convenience Access

extension Color {
    /// Shorthand access to theme colors: `.theme.primary`
    static var theme: Theme.Type { Theme.self }
}

extension ShapeStyle where Self == Color {
    /// Shorthand access to theme colors for ShapeStyle contexts: `.background(.theme.primary)`
    static var theme: Color.Theme.Type { Color.Theme.self }
}

// MARK: - Hex Initializer

extension Color {
    /// Initialize a Color from a hex string (supports #RGB, #RRGGBB, #RRGGBBAA)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RRGGBB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // RRGGBBAA (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
