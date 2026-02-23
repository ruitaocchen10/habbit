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
        static let largeTitle: Font = .custom("FiraSansCondensed-Bold", size: 34)

        /// Title - 28pt, bold - Section headers, greeting
        static let title: Font = .custom("FiraSansCondensed-Bold", size: 28)

        /// Title 2 - 22pt, bold - Card titles, modal headers
        static let title2: Font = .custom("FiraSansCondensed-Bold", size: 22)

        /// Title 3 - 20pt, semibold - Subsection headers
        static let title3: Font = .custom("FiraSansCondensed-SemiBold", size: 20)

        /// Headline - 17pt, semibold - List headers, emphasized text
        static let headline: Font = .custom("FiraSansCondensed-SemiBold", size: 17)

        /// Body - 17pt, regular - Body text, default text
        static let body: Font = .custom("FiraSansCondensed-Regular", size: 17)

        /// Body Emphasized - 17pt, medium - Emphasized body text
        static let bodyEmphasized: Font = .custom("FiraSansCondensed-Medium", size: 17)

        /// Callout - 16pt, regular - Secondary body text
        static let callout: Font = .custom("FiraSansCondensed-Regular", size: 16)

        /// Subheadline - 15pt, regular - Metadata, descriptions
        static let subheadline: Font = .custom("FiraSansCondensed-Regular", size: 15)

        /// Footnote - 13pt, regular - Captions, helper text
        static let footnote: Font = .custom("FiraSansCondensed-Regular", size: 13)

        /// Caption - 12pt, regular - Timestamps, tertiary info
        static let caption: Font = .custom("FiraSansCondensed-Regular", size: 12)

        /// Caption Emphasized - 12pt, medium - Emphasized captions
        static let captionEmphasized: Font = .custom("FiraSansCondensed-Medium", size: 12)

        // MARK: - Specialized Styles

        /// Button text - 17pt, semibold
        static let button: Font = .custom("FiraSansCondensed-SemiBold", size: 17)

        /// Small button text - 15pt, semibold
        static let buttonSmall: Font = .custom("FiraSansCondensed-SemiBold", size: 15)

        /// Large numbers/stats - 28pt, semibold
        static let statLarge: Font = .custom("FiraSansCondensed-SemiBold", size: 28)

        /// Medium numbers/stats - 20pt, semibold
        static let statMedium: Font = .custom("FiraSansCondensed-SemiBold", size: 20)

        /// Small numbers/stats - 17pt, medium
        static let statSmall: Font = .custom("FiraSansCondensed-Medium", size: 17)
    }
}

// MARK: - Convenience Access

extension Font {
    /// Shorthand access to theme fonts: `.theme.title`
    static var theme: Theme.Type { Theme.self }
}
