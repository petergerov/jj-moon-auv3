import Foundation
import AudioToolbox

/// Curve target voice — steel-string, nylon concert, or flamenco.
enum JJMoonCurveVoices {
    static let names = ["Steel", "Nylon", "Flamenco"]
    static let steel = 0
    static let nylon = 1
    static let flamenco = 2
    static let defaultIndex = steel
}

let JJMoonParameterSpecs = ParameterTreeSpec {
    ParameterGroupSpec(identifier: "curve", name: "Shape") {
        // One Amount for the whole target curve — the point of the plug-in.
        // Wood and Presence are character; Voice picks the target shape.
        ParameterSpec(address: .curveAmount, identifier: "curveAmount", name: "Curve",
                      units: .percent, valueRange: 0.0...100.0, defaultValue: 68.0, unitName: "%")
        ParameterSpec(address: .curveWood, identifier: "curveWood", name: "Wood",
                      units: .percent, valueRange: 0.0...100.0, defaultValue: 55.0, unitName: "%")
        ParameterSpec(address: .curvePresence, identifier: "curvePresence", name: "Presence",
                      units: .percent, valueRange: 0.0...100.0, defaultValue: 42.0, unitName: "%")
        ParameterSpec(address: .curveOn, identifier: "curveOn", name: "Curve On",
                      units: .boolean, valueRange: 0.0...1.0, defaultValue: 1.0)
        ParameterSpec(address: .curveVoice, identifier: "curveVoice", name: "Voice",
                      units: .indexed,
                      valueRange: 0.0...AUValue(JJMoonCurveVoices.names.count - 1),
                      defaultValue: AUValue(JJMoonCurveVoices.defaultIndex),
                      valueStrings: JJMoonCurveVoices.names)
    }
    ParameterGroupSpec(identifier: "comp", name: "Comp") {
        ParameterSpec(address: .compAmount, identifier: "compAmount", name: "Comp",
                      units: .percent, valueRange: 0.0...100.0, defaultValue: 48.0, unitName: "%")
        ParameterSpec(address: .compAttack, identifier: "compAttack", name: "Attack",
                      units: .milliseconds, valueRange: 5.0...80.0, defaultValue: 32.0, unitName: "ms")
        ParameterSpec(address: .compRelease, identifier: "compRelease", name: "Release",
                      units: .milliseconds, valueRange: 40.0...400.0, defaultValue: 160.0, unitName: "ms")
        ParameterSpec(address: .compOn, identifier: "compOn", name: "Comp On",
                      units: .boolean, valueRange: 0.0...1.0, defaultValue: 1.0)
    }
    ParameterGroupSpec(identifier: "width", name: "Width") {
        // Macro: maps to micro-pitch ±cents, short L/R delays, and wet mix.
        // Focus keeps the body mono so the image does not wander.
        ParameterSpec(address: .widthAmount, identifier: "widthAmount", name: "Width",
                      units: .percent, valueRange: 0.0...100.0, defaultValue: 35.0, unitName: "%")
        ParameterSpec(address: .widthFocus, identifier: "widthFocus", name: "Focus",
                      units: .hertz, valueRange: 80.0...2000.0, defaultValue: 220.0, unitName: "Hz")
        ParameterSpec(address: .widthOn, identifier: "widthOn", name: "Width On",
                      units: .boolean, valueRange: 0.0...1.0, defaultValue: 1.0)
    }
    ParameterGroupSpec(identifier: "space", name: "Space") {
        ParameterSpec(address: .spaceDouble, identifier: "spaceDouble", name: "Double",
                      units: .percent, valueRange: 0.0...100.0, defaultValue: 18.0, unitName: "%")
        ParameterSpec(address: .spaceSize, identifier: "spaceSize", name: "Size",
                      units: .percent, valueRange: 0.0...100.0, defaultValue: 40.0, unitName: "%")
        ParameterSpec(address: .spaceMix, identifier: "spaceMix", name: "Room",
                      units: .percent, valueRange: 0.0...100.0, defaultValue: 16.0, unitName: "%")
        ParameterSpec(address: .spaceOn, identifier: "spaceOn", name: "Space On",
                      units: .boolean, valueRange: 0.0...1.0, defaultValue: 1.0)
    }
    ParameterGroupSpec(identifier: "master", name: "Master") {
        ParameterSpec(address: .masterInput, identifier: "masterInput", name: "Input",
                      units: .decibels, valueRange: -12.0...24.0, defaultValue: 0.0, unitName: "dB")
        ParameterSpec(address: .masterMix, identifier: "masterMix", name: "Mix",
                      units: .percent, valueRange: 0.0...100.0, defaultValue: 100.0, unitName: "%")
        ParameterSpec(address: .masterOutput, identifier: "masterOutput", name: "Output",
                      units: .decibels, valueRange: -12.0...12.0, defaultValue: 0.0, unitName: "dB")
    }
}

extension ParameterSpec {
    init(
        address: JJMoonParameterAddress,
        identifier: String,
        name: String,
        units: AudioUnitParameterUnit,
        valueRange: ClosedRange<AUValue>,
        defaultValue: AUValue,
        unitName: String? = nil,
        flags: AudioUnitParameterOptions = [.flag_IsWritable, .flag_IsReadable],
        valueStrings: [String]? = nil,
        dependentParameters: [NSNumber]? = nil
    ) {
        var resolvedFlags = flags
        if units != .boolean {
            resolvedFlags.insert(.flag_CanRamp)
        }
        self.init(
            address: address.rawValue,
            identifier: identifier,
            name: name,
            units: units,
            valueRange: valueRange,
            defaultValue: defaultValue,
            unitName: unitName,
            flags: resolvedFlags,
            valueStrings: valueStrings,
            dependentParameters: dependentParameters
        )
    }
}

/// Distinct from jj-breeze (`Jjb3`) and jj-midnight (`Jjm1`) on every axis
/// iOS keys on: subtype, bundle ID, and App Group.
enum AudioUnitIdentity {
    static let type = "aufx"
    static let subtype = "Jjmo"
    static let manufacturer = "Grov"
    static let componentName = "Gerov: jj-moon"
}
