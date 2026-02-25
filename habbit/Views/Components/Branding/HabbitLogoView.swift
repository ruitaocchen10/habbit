//
//  HabbitLogoView.swift
//  habbit
//
//  App logo and branding component.
//  Use HabbitLogoView anywhere the app mark is needed.
//

import SwiftUI

// MARK: - Habbit Logo View

/// The Habbit app logo: a spring-green gradient rounded square containing a white
/// bold "H" lettermark. The crossbar tilts upward toward the right, embedding a
/// checkmark motif into the classic letterform — reflecting habit completion.
///
/// Usage:
/// ```swift
/// HabbitLogoView()              // default 72 pt
/// HabbitLogoView(size: 120)     // custom size
/// ```
struct HabbitLogoView: View {

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

            // White H lettermark with checkmark-tilt crossbar
            HabbitLettermark()
                .frame(width: size * 0.55, height: size * 0.60)
        }
    }
}

// MARK: - H Lettermark

/// Draws a bold white "H" whose crossbar tilts upward from left to right,
/// embedding a checkmark motif into the letterform.
private struct HabbitLettermark: View {
    var body: some View {
        Canvas { context, size in
            let w = size.width
            let h = size.height

            let barW:  CGFloat = w * 0.20   // thickness of each vertical stroke
            let leftX: CGFloat = w * 0.06   // left edge of left bar
            let rightX: CGFloat = w * 0.74  // left edge of right bar (0.74 + 0.20 = 0.94)
            let barRadius: CGFloat = barW * 0.45

            // Left vertical bar
            let leftBar = Path(
                roundedRect: CGRect(x: leftX, y: 0, width: barW, height: h),
                cornerRadius: barRadius
            )

            // Right vertical bar
            let rightBar = Path(
                roundedRect: CGRect(x: rightX, y: 0, width: barW, height: h),
                cornerRadius: barRadius
            )

            // Crossbar: a parallelogram where the left side sits lower than the right,
            // creating a ~15° upward tilt — the checkmark motif.
            let crossbarThickness: CGFloat = barW * 0.90
            let cbLeftTop  = CGPoint(x: leftX + barW, y: h * 0.46)
            let cbRightTop = CGPoint(x: rightX,       y: h * 0.33)
            let cbRightBot = CGPoint(x: rightX,       y: h * 0.33 + crossbarThickness)
            let cbLeftBot  = CGPoint(x: leftX + barW, y: h * 0.46 + crossbarThickness)

            var crossbar = Path()
            crossbar.move(to: cbLeftTop)
            crossbar.addLine(to: cbRightTop)
            crossbar.addLine(to: cbRightBot)
            crossbar.addLine(to: cbLeftBot)
            crossbar.closeSubpath()

            context.fill(leftBar,  with: .foreground)
            context.fill(rightBar, with: .foreground)
            context.fill(crossbar, with: .foreground)
        }
        .foregroundStyle(.white)
    }
}

// MARK: - Previews

#Preview("Login Branding — 72 pt") {
    HabbitLogoView(size: 72)
        .padding(32)
        .background(Color(hexString: "#EDE8DC"))
}

#Preview("Large — 200 pt") {
    HabbitLogoView(size: 200)
        .padding(40)
        .background(Color(hexString: "#EDE8DC"))
}
