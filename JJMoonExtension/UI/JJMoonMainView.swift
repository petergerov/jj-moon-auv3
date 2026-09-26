import SwiftUI

struct JJMoonMainView: View {
    let parameterTree: ObservableAUParameterGroup
    let audioUnit: JJMoonAudioUnit?

    @State private var viewModel: PanelViewModel

    init(parameterTree: ObservableAUParameterGroup, audioUnit: JJMoonAudioUnit?, entitlement: EntitlementService) {
        self.parameterTree = parameterTree
        self.audioUnit = audioUnit
        _viewModel = State(initialValue: PanelViewModel(audioUnit: audioUnit, entitlement: entitlement))
    }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                ChassisBackground(theme: GearTheme.current)

                HStack(spacing: 0) {
                    RackEar(theme: GearTheme.current).frame(width: PanelMetrics.earWidth)
                    Spacer(minLength: 0)
                    RackEar(theme: GearTheme.current).frame(width: PanelMetrics.earWidth)
                }

                ScrollView(.vertical, showsIndicators: false) {
                    // Spacers above/below the panel content, plus a
                    // minHeight matching the full container: when the host
                    // gives more height than the panel needs, this centres
                    // it in the chassis rather than pinning it to the top
                    // and leaving a dead expanse of chassis below; when the
                    // host is short, the spacers collapse and it scrolls.
                    VStack(spacing: 0) {
                        Spacer(minLength: 0)
                        panelContent(width: geo.size.width)
                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: geo.size.height)
                }
                .frame(width: geo.size.width, height: geo.size.height)

                FooterRivetStrip(theme: GearTheme.current)
                    .frame(width: geo.size.width, height: PanelMetrics.footerHeight)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .task {
            await viewModel.start()
        }
        .onChange(of: viewModel.accessState) {
            viewModel.accessStateChanged()
        }
        .sheet(isPresented: $viewModel.isPaywallShown) {
            PaywallView(entitlement: viewModel.entitlement, showsCloseWhenAllowed: true) {
                viewModel.isPaywallShown = false
            }
            .presentationDetents([.large])
        }
    }

    // The panel's actual content — header, divider, sections, footer — at
    // its natural size for a given width, with no outer chassis/scrolling
    // wrapper. `body` embeds this inside the always-fills GeometryReader/
    // ScrollView above; `AudioUnitViewController` also hosts it standalone
    // to *measure* the height a host should be asked for via
    // `preferredContentSize`, so that initial request reflects this view's
    // real layout instead of a hand-tuned guess that drifts out of sync
    // with it.
    func panelContent(width: CGFloat) -> some View {
        let sideInset = PanelMetrics.sideInset
        return VStack(spacing: 0) {
            PanelHeader(viewModel: viewModel)
            .padding(.horizontal, sideInset)
            .padding(.top, 10)
            .padding(.bottom, 8)

            EngravedGroove()
                .padding(.horizontal, sideInset)

            // Above the four blocks, not under them. Input is the first
            // thing to set on a live rig — every threshold downstream is
            // absolute, so nothing below is worth judging until this is
            // right — and at the bottom of a scrolling panel it was off
            // screen at the moment it mattered.
            MasterStrip(group: parameterTree.master, audioUnit: audioUnit, width: width)
                .padding(.horizontal, sideInset)
                .padding(.top, 12)

            SectionsLayout(parameterTree: parameterTree, audioUnit: audioUnit, width: width)
                .environment(\.knobDiameter, PanelMetrics.knobDiameter(forPanelWidth: width))
                .padding(.horizontal, sideInset)
                .padding(.top, 10)
                .padding(.bottom, 8)

            VersionFooter()
                .padding(.horizontal, sideInset)
                .padding(.bottom, PanelMetrics.footerHeight + 6)
        }
        .frame(width: width)
    }
}

/// A scored line with the light catching its lower lip, rather than a flat
/// hairline.
private struct EngravedGroove: View {
    var body: some View {
        VStack(spacing: 0) {
            Rectangle().fill(.black.opacity(0.45)).frame(height: 1)
            Rectangle().fill(GearTheme.panelEdgeLight.opacity(0.35)).frame(height: 1)
        }
    }
}

private struct VersionFooter: View {
    var body: some View {
        ModelPlate(text: "MODEL JJMO  ·  ACOUSTIC GUITAR CURVE  ·  \(appVersionString)")
            .frame(maxWidth: .infinity)
    }

    private var appVersionString: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        return "v\(v)"
    }
}
