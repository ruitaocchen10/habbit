//
//  CornerRadius.swift
//  habbit
//
//  Design System Corner Radius Tokens
//

import SwiftUI

extension CGFloat {
    struct Radius {
        /// 8pt - Small buttons, tags, chips
        static let small: CGFloat = 8

        /// 12pt - Cards, input fields, medium buttons
        static let medium: CGFloat = 12

        /// 16pt - Large cards, modals
        static let large: CGFloat = 16

        /// 24pt - Hero elements, special cards
        static let xLarge: CGFloat = 24

        /// 999pt - Pill-shaped elements (capsule effect)
        static let capsule: CGFloat = 999
    }
}

// MARK: - Convenience Access

extension CGFloat {
    /// Shorthand access to corner radius values: `.radius.medium`
    static var radius: Radius.Type { Radius.self }
}

// MARK: - RoundedCornerStyle Convenience

extension RoundedCornerStyle {
    struct Theme {
        /// Small rounded corners (8pt)
        static let small = RoundedCornerStyle.continuous

        /// Medium rounded corners (12pt) - default for most elements
        static let medium = RoundedCornerStyle.continuous

        /// Large rounded corners (16pt)
        static let large = RoundedCornerStyle.continuous

        /// Extra large rounded corners (24pt)
        static let xLarge = RoundedCornerStyle.continuous
    }
}

// MARK: - Shape Extensions

extension RoundedRectangle {
    struct Theme {
        /// Small rounded rectangle (8pt radius)
        static func small() -> RoundedRectangle {
            RoundedRectangle(cornerRadius: .radius.small, style: .continuous)
        }

        /// Medium rounded rectangle (12pt radius)
        static func medium() -> RoundedRectangle {
            RoundedRectangle(cornerRadius: .radius.medium, style: .continuous)
        }

        /// Large rounded rectangle (16pt radius)
        static func large() -> RoundedRectangle {
            RoundedRectangle(cornerRadius: .radius.large, style: .continuous)
        }

        /// Extra large rounded rectangle (24pt radius)
        static func xLarge() -> RoundedRectangle {
            RoundedRectangle(cornerRadius: .radius.xLarge, style: .continuous)
        }
    }
}

// MARK: - RoundedRectangle Convenience Access

extension RoundedRectangle {
    /// Shorthand access to theme rounded rectangles: `RoundedRectangle.theme.medium()`
    static var theme: Theme.Type { Theme.self }
}
