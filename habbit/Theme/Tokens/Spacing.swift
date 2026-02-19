//
//  Spacing.swift
//  habbit
//
//  Design System Spacing Tokens (4pt base unit)
//

import SwiftUI

extension CGFloat {
    struct Spacing {
        /// 4pt - Tight spacing, icon padding
        static let xxSmall: CGFloat = 4

        /// 8pt - Compact spacing, between related elements
        static let xSmall: CGFloat = 8

        /// 12pt - Standard spacing within components
        static let small: CGFloat = 12

        /// 16pt - Default padding, margins
        static let medium: CGFloat = 16

        /// 24pt - Section spacing, card padding
        static let large: CGFloat = 24

        /// 32pt - Screen margins, major sections
        static let xLarge: CGFloat = 32

        /// 48pt - Large gaps, spacers
        static let xxLarge: CGFloat = 48

        /// 64pt - Maximum spacing, empty states
        static let xxxLarge: CGFloat = 64
    }
}

// MARK: - Convenience Access

extension CGFloat {
    /// Shorthand access to spacing values: `.spacing.medium`
    static var spacing: Spacing.Type { Spacing.self }
}

// MARK: - EdgeInsets Convenience

extension EdgeInsets {
    struct Theme {
        /// Button padding - 12pt vertical, 16pt horizontal
        static let button = EdgeInsets(
            top: .spacing.small,
            leading: .spacing.medium,
            bottom: .spacing.small,
            trailing: .spacing.medium
        )

        /// Small button padding - 8pt vertical, 12pt horizontal
        static let buttonSmall = EdgeInsets(
            top: .spacing.xSmall,
            leading: .spacing.small,
            bottom: .spacing.xSmall,
            trailing: .spacing.small
        )

        /// Card padding - 24pt all sides
        static let card = EdgeInsets(
            top: .spacing.large,
            leading: .spacing.large,
            bottom: .spacing.large,
            trailing: .spacing.large
        )

        /// Screen padding - 16pt horizontal
        static let screen = EdgeInsets(
            top: 0,
            leading: .spacing.medium,
            bottom: 0,
            trailing: .spacing.medium
        )

        /// List item padding - 16pt all sides
        static let listItem = EdgeInsets(
            top: .spacing.medium,
            leading: .spacing.medium,
            bottom: .spacing.medium,
            trailing: .spacing.medium
        )
    }
}

// MARK: - EdgeInsets Convenience Access

extension EdgeInsets {
    /// Shorthand access to theme edge insets: `.theme.button`
    static var theme: Theme.Type { Theme.self }
}
