//
//  Typography.swift
//  habbit
//
//  Design System Typography Tokens
//

import SwiftUI

extension Font {
    struct Theme {
        // MARK: - Type Scale

        /// Large title - 34pt, bold - Screen titles, onboarding
        static let largeTitle: Font = .system(size: 34, weight: .bold)

        /// Title - 28pt, bold - Section headers, greeting
        static let title: Font = .system(size: 28, weight: .bold)

        /// Title 2 - 22pt, bold - Card titles, modal headers
        static let title2: Font = .system(size: 22, weight: .bold)

        /// Title 3 - 20pt, semibold - Subsection headers
        static let title3: Font = .system(size: 20, weight: .semibold)

        /// Headline - 17pt, semibold - List headers, emphasized text
        static let headline: Font = .system(size: 17, weight: .semibold)

        /// Body - 17pt, regular - Body text, default text
        static let body: Font = .system(size: 17, weight: .regular)

        /// Body Emphasized - 17pt, medium - Emphasized body text
        static let bodyEmphasized: Font = .system(size: 17, weight: .medium)

        /// Callout - 16pt, regular - Secondary body text
        static let callout: Font = .system(size: 16, weight: .regular)

        /// Subheadline - 15pt, regular - Metadata, descriptions
        static let subheadline: Font = .system(size: 15, weight: .regular)

        /// Footnote - 13pt, regular - Captions, helper text
        static let footnote: Font = .system(size: 13, weight: .regular)

        /// Caption - 12pt, regular - Timestamps, tertiary info
        static let caption: Font = .system(size: 12, weight: .regular)

        /// Caption Emphasized - 12pt, medium - Emphasized captions
        static let captionEmphasized: Font = .system(size: 12, weight: .medium)

        // MARK: - Specialized Styles

        /// Button text - 17pt, semibold
        static let button: Font = .system(size: 17, weight: .semibold)

        /// Small button text - 15pt, semibold
        static let buttonSmall: Font = .system(size: 15, weight: .semibold)

        /// Large numbers/stats - 28pt, semibold
        static let statLarge: Font = .system(size: 28, weight: .semibold)

        /// Medium numbers/stats - 20pt, semibold
        static let statMedium: Font = .system(size: 20, weight: .semibold)

        /// Small numbers/stats - 17pt, medium
        static let statSmall: Font = .system(size: 17, weight: .medium)
    }
}

// MARK: - Convenience Access

extension Font {
    /// Shorthand access to theme fonts: `.theme.title`
    static var theme: Theme.Type { Theme.self }
}

