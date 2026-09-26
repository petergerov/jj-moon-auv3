import CoreGraphics

/// Rack-panel geometry shared by the main view and its sections — matches the
/// desktop design's headerHeight/earWidth/footerStripHeight constants, scaled
/// down for a host-embedded extension view.
enum PanelMetrics {
    static let earWidth: CGFloat = 18
    static let footerHeight: CGFloat = 12
    static let contentGutter: CGFloat = 12
    static var sideInset: CGFloat { earWidth + contentGutter }

    // Four sections of three knobs need three breakpoints. Four across only
    // fits on an iPad-width host; a 2x2 grid is the shape that works for most
    // of the range; a phone stacks. Comp carries a gain-reduction bar under
    // its knobs, so it runs a little taller than the other three and the
    // equal-height plates leave them slightly short — a bar's worth, which is
    // what a needle in the same place would have cost several times over.
    static let gridThreshold: CGFloat = 520
    static let wideThreshold: CGFloat = 900

    static let columnSpacing: CGFloat = 20
    static let knobRowSpacing: CGFloat = 8

    // Each section rides on its own sub-plate, screwed onto the front
    // panel — so the sections read as separate modules the way they do on
    // the reference hardware, and the hairline dividers the old layout
    // needed are no longer necessary.
    static let plateInset: CGFloat = 17

    /// How many sections sit side by side at this width.
    static func sectionColumns(forPanelWidth width: CGFloat) -> Int {
        if width >= wideThreshold { return 4 }
        if width >= gridThreshold { return 2 }
        return 1
    }

    /// The knob size the three-in-a-row sections draw at.
    static func knobDiameter(forPanelWidth width: CGFloat) -> CGFloat {
        let content = width - sideInset * 2
        let columns = CGFloat(sectionColumns(forPanelWidth: width))
        let columnWidth = (content - columnSpacing * (columns - 1)) / columns
        let slot = (columnWidth - plateInset * 2 - knobRowSpacing * 2) / 3
        return min(96, max(42, slot))
    }
}
