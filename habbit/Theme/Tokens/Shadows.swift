//
//  Shadows.swift
//  habbit
//
//  Design System Shadow Tokens
//

import SwiftUI

// MARK: - Shadow View Modifiers

extension View {
    /// Small shadow - subtle elevation for list items
    /// - Shadow: color: black.opacity(0.05), radius: 2, x: 0, y: 1
    func shadowSmall() -> some View {
        self.shadow(
            color: .black.opacity(0.05),
            radius: 2,
            x: 0,
            y: 1
        )
    }

    /// Medium shadow - cards, floating elements
    /// - Shadow: color: black.opacity(0.1), radius: 8, x: 0, y: 4
    func shadowMedium() -> some View {
        self.shadow(
            color: .black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    /// Large shadow - modals, overlays
    /// - Shadow: color: black.opacity(0.15), radius: 16, x: 0, y: 8
    func shadowLarge() -> some View {
        self.shadow(
            color: .black.opacity(0.15),
            radius: 16,
            x: 0,
            y: 8
        )
    }
}

// MARK: - Shadow Configuration Structs (for manual use)

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

extension ShadowStyle {
    struct Theme {
        /// Small shadow - subtle elevation for list items
        static let small = ShadowStyle(
            color: .black.opacity(0.05),
            radius: 2,
            x: 0,
            y: 1
        )

        /// Medium shadow - cards, floating elements
        static let medium = ShadowStyle(
            color: .black.opacity(0.1),
            radius: 8,
            x: 0,
            y: 4
        )

        /// Large shadow - modals, overlays
        static let large = ShadowStyle(
            color: .black.opacity(0.15),
            radius: 16,
            x: 0,
            y: 8
        )
    }
}

// MARK: - Border Tokens

extension CGFloat {
    struct Border {
        /// 1pt - Dividers, subtle outlines
        static let thin: CGFloat = 1

        /// 2pt - Input focus states, emphasized borders
        static let medium: CGFloat = 2

        /// 3pt - Strong emphasis, selection indicators
        static let thick: CGFloat = 3
    }
}

// MARK: - Border Convenience Access

extension CGFloat {
    /// Shorthand access to border widths: `.border.thin`
    static var border: Border.Type { Border.self }
}

// MARK: - Border View Modifier

extension View {
    /// Apply a themed border with specified width and color
    func themeBorder(width: CGFloat = .border.thin, color: Color = .theme.backgroundTertiary) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: .radius.medium)
                .strokeBorder(color, lineWidth: width)
        )
    }
}
