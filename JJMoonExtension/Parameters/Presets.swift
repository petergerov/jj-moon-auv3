import Foundation
import AudioToolbox

struct FactoryPreset: Sendable {
    let number: Int
    let name: String
    let curveAmount: AUValue
    let curveWood: AUValue
    let curvePresence: AUValue
    let curveVoice: AUValue
    let compAmount: AUValue
    let compAttack: AUValue
    let compRelease: AUValue
    let widthAmount: AUValue
    let widthFocus: AUValue
    let spaceDouble: AUValue
    let spaceSize: AUValue
    let spaceMix: AUValue
    let masterMix: AUValue
    let masterOutput: AUValue
    let curveOn: Bool
    let compOn: Bool
    let widthOn: Bool
    let spaceOn: Bool

    var auPreset: AUAudioUnitPreset {
        let preset = AUAudioUnitPreset()
        preset.number = number
        preset.name = name
        return preset
    }
}

/// Destinations for the acoustic curve engine. Names describe a feel or a
/// place — never an artist, and never a claim to reproduce a particular
/// recording. `curveVoice` is 0 = Steel, 1 = Nylon, 2 = Flamenco.
enum FactoryPresets {
    static let all: [FactoryPreset] = [
        FactoryPreset(number: 0, name: "Default",
                      curveAmount: 68, curveWood: 55, curvePresence: 42, curveVoice: 0,
                      compAmount: 48, compAttack: 32, compRelease: 160,
                      widthAmount: 35, widthFocus: 220,
                      spaceDouble: 18, spaceSize: 40, spaceMix: 16,
                      masterMix: 100, masterOutput: 0,
                      curveOn: true, compOn: true, widthOn: true, spaceOn: true),

        FactoryPreset(number: 1, name: "Fallen Leaf",
                      curveAmount: 78, curveWood: 72, curvePresence: 35, curveVoice: 0,
                      compAmount: 42, compAttack: 36, compRelease: 180,
                      widthAmount: 28, widthFocus: 260,
                      spaceDouble: 12, spaceSize: 48, spaceMix: 22,
                      masterMix: 100, masterOutput: 0,
                      curveOn: true, compOn: true, widthOn: true, spaceOn: true),

        FactoryPreset(number: 2, name: "Fingerstyle",
                      curveAmount: 70, curveWood: 32, curvePresence: 68, curveVoice: 0,
                      compAmount: 38, compAttack: 28, compRelease: 140,
                      widthAmount: 40, widthFocus: 180,
                      spaceDouble: 22, spaceSize: 32, spaceMix: 12,
                      masterMix: 100, masterOutput: 0,
                      curveOn: true, compOn: true, widthOn: true, spaceOn: true),

        FactoryPreset(number: 3, name: "Piezo Soft",
                      curveAmount: 82, curveWood: 78, curvePresence: 22, curveVoice: 0,
                      compAmount: 55, compAttack: 40, compRelease: 200,
                      widthAmount: 22, widthFocus: 320,
                      spaceDouble: 8, spaceSize: 36, spaceMix: 14,
                      masterMix: 100, masterOutput: 0,
                      curveOn: true, compOn: true, widthOn: true, spaceOn: true),

        FactoryPreset(number: 4, name: "Stereo Porch",
                      curveAmount: 62, curveWood: 48, curvePresence: 50, curveVoice: 0,
                      compAmount: 40, compAttack: 30, compRelease: 150,
                      widthAmount: 72, widthFocus: 160,
                      spaceDouble: 30, spaceSize: 44, spaceMix: 18,
                      masterMix: 100, masterOutput: 0,
                      curveOn: true, compOn: true, widthOn: true, spaceOn: true),

        FactoryPreset(number: 5, name: "Close Mic",
                      curveAmount: 74, curveWood: 60, curvePresence: 48, curveVoice: 0,
                      compAmount: 52, compAttack: 26, compRelease: 130,
                      widthAmount: 12, widthFocus: 400,
                      spaceDouble: 4, spaceSize: 20, spaceMix: 4,
                      masterMix: 100, masterOutput: 0,
                      curveOn: true, compOn: true, widthOn: true, spaceOn: true),

        FactoryPreset(number: 6, name: "Moon Room",
                      curveAmount: 58, curveWood: 50, curvePresence: 40, curveVoice: 0,
                      compAmount: 35, compAttack: 38, compRelease: 190,
                      widthAmount: 45, widthFocus: 200,
                      spaceDouble: 16, spaceSize: 70, spaceMix: 38,
                      masterMix: 100, masterOutput: 0,
                      curveOn: true, compOn: true, widthOn: true, spaceOn: true),

        FactoryPreset(number: 7, name: "Strum",
                      curveAmount: 65, curveWood: 45, curvePresence: 58, curveVoice: 0,
                      compAmount: 62, compAttack: 22, compRelease: 120,
                      widthAmount: 38, widthFocus: 240,
                      spaceDouble: 14, spaceSize: 35, spaceMix: 12,
                      masterMix: 100, masterOutput: 0,
                      curveOn: true, compOn: true, widthOn: true, spaceOn: true),

        FactoryPreset(number: 8, name: "Curve Only",
                      curveAmount: 80, curveWood: 55, curvePresence: 45, curveVoice: 0,
                      compAmount: 40, compAttack: 32, compRelease: 160,
                      widthAmount: 30, widthFocus: 220,
                      spaceDouble: 15, spaceSize: 40, spaceMix: 15,
                      masterMix: 100, masterOutput: 0,
                      curveOn: true, compOn: false, widthOn: false, spaceOn: false),

        // Nylon / concert / Spanish — warmer mid-body, soft top.
        FactoryPreset(number: 9, name: "Nylon",
                      curveAmount: 72, curveWood: 68, curvePresence: 40, curveVoice: 1,
                      compAmount: 45, compAttack: 36, compRelease: 170,
                      widthAmount: 28, widthFocus: 240,
                      spaceDouble: 14, spaceSize: 42, spaceMix: 18,
                      masterMix: 100, masterOutput: 0,
                      curveOn: true, compOn: true, widthOn: true, spaceOn: true),

        FactoryPreset(number: 10, name: "Concert Hall",
                      curveAmount: 65, curveWood: 60, curvePresence: 35, curveVoice: 1,
                      compAmount: 38, compAttack: 40, compRelease: 200,
                      widthAmount: 40, widthFocus: 200,
                      spaceDouble: 12, spaceSize: 68, spaceMix: 32,
                      masterMix: 100, masterOutput: 0,
                      curveOn: true, compOn: true, widthOn: true, spaceOn: true),

        FactoryPreset(number: 11, name: "Spanish Soft",
                      curveAmount: 78, curveWood: 75, curvePresence: 28, curveVoice: 1,
                      compAmount: 50, compAttack: 34, compRelease: 180,
                      widthAmount: 22, widthFocus: 280,
                      spaceDouble: 8, spaceSize: 36, spaceMix: 14,
                      masterMix: 100, masterOutput: 0,
                      curveOn: true, compOn: true, widthOn: true, spaceOn: true),

        // Flamenco voice — tight body, mid-bite, nail sheen.
        FactoryPreset(number: 12, name: "Flamenco",
                      curveAmount: 74, curveWood: 42, curvePresence: 62, curveVoice: 2,
                      compAmount: 52, compAttack: 22, compRelease: 130,
                      widthAmount: 32, widthFocus: 220,
                      spaceDouble: 10, spaceSize: 28, spaceMix: 10,
                      masterMix: 100, masterOutput: 0,
                      curveOn: true, compOn: true, widthOn: true, spaceOn: true),

        FactoryPreset(number: 13, name: "Rasgueado",
                      curveAmount: 80, curveWood: 35, curvePresence: 72, curveVoice: 2,
                      compAmount: 58, compAttack: 16, compRelease: 110,
                      widthAmount: 38, widthFocus: 200,
                      spaceDouble: 8, spaceSize: 22, spaceMix: 8,
                      masterMix: 100, masterOutput: 0,
                      curveOn: true, compOn: true, widthOn: true, spaceOn: true),

        FactoryPreset(number: 14, name: "Soleá",
                      curveAmount: 70, curveWood: 55, curvePresence: 48, curveVoice: 2,
                      compAmount: 44, compAttack: 30, compRelease: 170,
                      widthAmount: 30, widthFocus: 240,
                      spaceDouble: 16, spaceSize: 50, spaceMix: 22,
                      masterMix: 100, masterOutput: 0,
                      curveOn: true, compOn: true, widthOn: true, spaceOn: true),
    ]
}

enum JJMoonPresetError: LocalizedError {
    case emptyName
    case persistFailed
    case notFound

    var errorDescription: String? {
        switch self {
        case .emptyName:
            return "Enter a preset name."
        case .persistFailed:
            return "Could not save the preset on this device."
        case .notFound:
            return "That preset is no longer on this device."
        }
    }
}
