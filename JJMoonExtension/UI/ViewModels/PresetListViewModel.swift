import AudioToolbox
import Foundation
import Observation

/// State and actions behind `PresetBar`: the factory and user lists, the
/// current preset, and the save / rename / delete flow with its sheets.
@MainActor
@Observable
final class PresetListViewModel {
    private(set) var title = "Default"
    private(set) var currentNumber: Int?
    private(set) var userPresets: [AUAudioUnitPreset] = []
    let factoryPresets = FactoryPresets.all

    var isPickerShown = false
    var isSaveSheetShown = false
    var saveName = ""
    var renameTarget: AUAudioUnitPreset?
    var renameText = ""
    var errorMessage: String?

    // A sheet can't be raised while the dropdown is still up, so "Save As…"
    // and Rename only mark what to do and close the popover; the actual
    // sheet is presented once the popover has gone (see
    // `presentPendingSheetAfterDismissal`).
    private var pendingSave = false
    private var pendingRename: AUAudioUnitPreset?

    @ObservationIgnored private let audioUnit: JJMoonAudioUnit?
    @ObservationIgnored private var observations: [NSKeyValueObservation] = []

    var isAvailable: Bool { audioUnit != nil }

    var isRenameSheetShown: Bool {
        get { renameTarget != nil }
        set { if !newValue { renameTarget = nil } }
    }

    var isErrorShown: Bool {
        get { errorMessage != nil }
        set { if !newValue { errorMessage = nil } }
    }

    /// Cheap on purpose — views may construct this more than once. The
    /// KVO wiring and the first load happen in `start()`.
    init(audioUnit: JJMoonAudioUnit?) {
        self.audioUnit = audioUnit
    }

    /// Load the lists and follow the audio unit's `currentPreset` and
    /// `userPresets`, which a host may change on any thread. Idempotent.
    func start() {
        reload()
        guard let audioUnit, observations.isEmpty else { return }
        let onChange: @Sendable () -> Void = { [weak self] in
            Task { @MainActor in self?.reload() }
        }
        observations = [
            audioUnit.observe(\.currentPreset) { _, _ in onChange() },
            audioUnit.observe(\.userPresets) { _, _ in onChange() },
        ]
    }

    func isDirty() -> Bool {
        audioUnit?.isPresetDirty() ?? false
    }

    // MARK: - Picker

    func openPicker() {
        reload()
        isPickerShown = true
    }

    func requestSave() {
        pendingSave = true
        isPickerShown = false
    }

    func requestRename(_ preset: AUAudioUnitPreset) {
        pendingRename = preset
        isPickerShown = false
    }

    /// Run on every picker visibility change; cancelled if it changes again.
    func presentPendingSheetAfterDismissal() async {
        guard !isPickerShown, pendingSave || pendingRename != nil else { return }
        // Let the popover finish dismissing first — UIKit drops a sheet
        // presented while another dismissal is still running.
        do {
            try await Task.sleep(for: .milliseconds(350))
        } catch {
            return
        }
        if pendingSave {
            pendingSave = false
            saveName = suggestedSaveName
            isSaveSheetShown = true
        } else if let preset = pendingRename {
            pendingRename = nil
            renameText = preset.name
            renameTarget = preset
        }
    }

    // MARK: - Actions

    func selectFactory(_ number: Int) {
        audioUnit?.currentPreset = audioUnit?.factoryPresets?.first { $0.number == number }
        reload()
        isPickerShown = false
    }

    func select(_ preset: AUAudioUnitPreset) {
        audioUnit?.currentPreset = preset
        reload()
        isPickerShown = false
    }

    func save() {
        guard let audioUnit else {
            errorMessage = "Effect is not loaded."
            return
        }
        do {
            try audioUnit.saveCurrentStateAsUserPreset(name: saveName)
            isSaveSheetShown = false
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func confirmRename() {
        guard let preset = renameTarget else { return }
        renameTarget = nil
        do {
            try audioUnit?.renameUserPreset(preset, to: renameText)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ preset: AUAudioUnitPreset) {
        do {
            try audioUnit?.removeUserPreset(preset)
            reload()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Loading

    private var suggestedSaveName: String {
        if let current = audioUnit?.currentPreset, current.number < 0 {
            return current.name
        }
        return ""
    }

    private func reload() {
        userPresets = (audioUnit?.userPresets ?? []).sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
        title = audioUnit?.currentPreset?.name ?? "Default"
        currentNumber = audioUnit?.currentPreset?.number
    }
}
