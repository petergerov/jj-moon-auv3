import SwiftUI

// One row: wordmark (+ strapline), preset selector, IN/OUT meters, power
// switch. The preset selector is the only flexible item, so it takes
// whatever width the brand stack, meters and switch leave.
struct PanelHeader: View {
    @Bindable var viewModel: PanelViewModel

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center, spacing: 8) {
                FinishSelector(theme: GearTheme.current)
                    .frame(width: 26, height: 26)
                    // Nudged down and given its own gap: centred on the
                    // row it reads as sitting above the wordmark, whose
                    // visual weight is below its own frame centre.
                    .offset(y: 2)
                    .padding(.trailing, 5)
                    .layoutPriority(1)

                Wordmark()
                    .layoutPriority(1)

                PresetBar(viewModel: viewModel.presets)
                    .frame(minWidth: 96, maxWidth: 340)

                LevelMeterView(audioUnit: viewModel.audioUnit)
                    .layoutPriority(1)

                BypassToggle(isBypassed: $viewModel.isBypassed)
                    .frame(width: 22, height: 38)
                    .layoutPriority(1)
            }

            if showsAccessBanner, viewModel.accessState.bannerText != nil {
                AccessBanner(state: viewModel.accessState, onUnlock: viewModel.showPaywall)
            }
        }
    }

    // The companion app puts its own trial banner in the chrome above the
    // panel, so a second copy inside the panel header just says the same
    // thing twice. A host has no such chrome, so there the panel keeps it —
    // it is the only way into the paywall from inside a DAW.
    private var showsAccessBanner: Bool {
        Bundle.main.bundlePath.hasSuffix(".appex")
    }
}

private struct Wordmark: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text("j.j.moon")
                .font(.custom("Georgia-BoldItalic", size: 18))
                .foregroundStyle(GearTheme.textLight)
                .shadow(color: .black.opacity(0.75), radius: 0, x: 0, y: 1.5)
                .shadow(color: .black.opacity(0.35), radius: 3, x: 0, y: 2)
                .lineLimit(1)
                // Keeps its full size while there is room and only
                // compresses on a narrow phone, so the preset window
                // beside it never has to truncate first.
                .minimumScaleFactor(0.6)

            Text("MIC'D ACOUSTIC SHAPE")
                .font(.system(size: 8, weight: .heavy))
                .tracking(1.1)
                .foregroundStyle(GearTheme.textMuted)
                .shadow(color: .black.opacity(0.55), radius: 0, x: 0, y: 1)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("j.j.moon, mic'd acoustic shape")
    }
}
