import SwiftUI

/// Ledger Green theme for Vendorpay - Freelance Invoice Log - unique per-app palette.
enum Theme {
    static let accent = Color(red: 0.180, green: 0.620, blue: 0.357)
    static let background = Color(red: 0.047, green: 0.102, blue: 0.078)
    static let cardBackground = Color(red: 0.047, green: 0.102, blue: 0.078).opacity(0.6)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.6)
    static let danger = Color(red: 0.86, green: 0.24, blue: 0.24)

    static let titleFont = Font.system(.largeTitle, design: .rounded).weight(.bold)
    static let headlineFont = Font.system(.headline, design: .rounded)
    static let bodyFont = Font.system(.body, design: .rounded)
    static let captionFont = Font.system(.caption, design: .rounded)

    static let cornerRadius: CGFloat = 16
}
