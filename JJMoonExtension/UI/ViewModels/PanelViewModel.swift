import Observation

/// State and actions behind `JJMoonMainView`: the bypass switch, the paywall,
/// and keeping the DSP's license gate in step with the entitlement.
@MainActor
@Observable
final class PanelViewModel {
    @ObservationIgnored let audioUnit: JJMoonAudioUnit?
    @ObservationIgnored let entitlement: EntitlementService
    let presets: PresetListViewModel

    var isBypassed = false {
        didSet { audioUnit?.shouldBypassEffect = isBypassed }
    }
    var isPaywallShown = false

    var accessState: AccessState { entitlement.accessState }

    init(audioUnit: JJMoonAudioUnit?, entitlement: EntitlementService) {
        self.audioUnit = audioUnit
        self.entitlement = entitlement
        self.presets = PresetListViewModel(audioUnit: audioUnit)
    }

    /// Pick up the host's bypass state, then re-check the entitlement and
    /// push the result into the kernel.
    func start() async {
        isBypassed = audioUnit?.shouldBypassEffect ?? false
        await entitlement.refresh()
        audioUnit?.applyLicenseFromStore()
    }

    func accessStateChanged() {
        audioUnit?.applyLicenseFromStore()
    }

    func showPaywall() {
        isPaywallShown = true
    }
}
