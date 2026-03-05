//
//  ViablyLogoView.swift
//  viably
//
//  App logo and branding component.
//  Use ViablyLogoView anywhere the app mark is needed.
//

import SwiftUI

// MARK: - Viably Logo View

/// The Viably app logo: a spring-green gradient rounded square containing a bold
/// white checkmark centered at ~50% of the square's width.
///
/// Usage:
/// ```swift
/// ViablyLogoView()              // default 72 pt
/// ViablyLogoView(size: 120)     // custom size
/// ```
struct ViablyLogoView: View {

    /// Bounding size (width = height) of the logo square.
    var size: CGFloat = 72

    private var cornerRadius: CGFloat { size * 0.225 }

    var body: some View {
        ZStack {
            // Background: light spring green → deep forest green gradient
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hexString: "#81C784"),
                            Color(hexString: "#2E7D32")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)

            // Bold white checkmark
            Image(systemName: "checkmark")
                .font(.system(size: size * 0.45, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Previews

#Preview("Login Branding — 72 pt") {
    ViablyLogoView(size: 72)
        .padding(32)
        .background(Color(hexString: "#EDE8DC"))
}

#Preview("Large — 200 pt") {
    ViablyLogoView(size: 200)
        .padding(40)
        .background(Color(hexString: "#EDE8DC"))
}
