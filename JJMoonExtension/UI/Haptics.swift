import UIKit

/// Impact feedback for the panel's controls, with one generator per style
/// kept for the life of the process instead of a new one per tap.
@MainActor
enum Haptics {
    private static let light = UIImpactFeedbackGenerator(style: .light)
    private static let medium = UIImpactFeedbackGenerator(style: .medium)
    private static let rigid = UIImpactFeedbackGenerator(style: .rigid)

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .medium: medium.impactOccurred()
        case .rigid: rigid.impactOccurred()
        default: light.impactOccurred()
        }
    }
}
