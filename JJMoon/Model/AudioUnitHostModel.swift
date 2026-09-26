import SwiftUI
import AudioToolbox
import AVFAudio
import UIKit

@MainActor
@Observable
class AudioUnitHostModel {
    enum LoadState {
        case loading
        case loaded(UIViewController)
        case failed(String)
    }

    private let playEngine = SimplePlayEngine()
    private let entitlement: EntitlementService
    private(set) var loadState: LoadState = .loading
    private(set) var isPlaying = false
    private(set) var playbackError: String?
    var source: SimplePlayEngine.Source {
        get { playEngine.source }
        set { setSource(newValue) }
    }

    /// The effect's editor, once it has loaded.
    var editor: UIViewController? {
        if case .loaded(let viewController) = loadState { viewController } else { nil }
    }

    let type = "aufx"
    let subType = "Jjmo"
    let manufacturer = "Grov"

    private var didStart = false

    init(entitlement: EntitlementService) {
        self.entitlement = entitlement
    }

    /// Load the AUv3 after the scene is active. The host engine is not created until Play.
    func start() async {
        guard !didStart else { return }
        didStart = true
        loadState = .loading
        await waitUntilActive()

        let viewController = await playEngine.initComponent(
            type: type,
            subType: subType,
            manufacturer: manufacturer,
            entitlement: entitlement
        )

        if let viewController {
            loadState = .loaded(viewController)
        } else {
            let message = playEngine.lastError ?? "Built-in effect failed to load."
            loadState = .failed(message)
            playbackError = message
        }
        // Load the effect and leave it stopped — don't start the demo loop
        // (or the microphone) until the user taps Play.
    }

    private func waitUntilActive() async {
        if UIApplication.shared.applicationState == .active { return }
        for await _ in NotificationCenter.default.notifications(named: UIApplication.didBecomeActiveNotification) {
            break
        }
    }

    func startPlaying() async {
        playbackError = nil
        await playEngine.startPlaying()
        isPlaying = playEngine.isPlaying
        if !isPlaying {
            playbackError = playEngine.lastError ?? "Could not start audio. Check volume and the silent switch."
        }
    }

    func stopPlaying() {
        playEngine.stopPlaying()
        isPlaying = false
        playbackError = nil
    }

    func setSource(_ source: SimplePlayEngine.Source) {
        let wasPlaying = isPlaying
        playEngine.setSource(source)
        isPlaying = playEngine.isPlaying
        if wasPlaying {
            Task { await startPlaying() }
        }
    }
}
