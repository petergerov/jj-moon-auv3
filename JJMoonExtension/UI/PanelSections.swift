import AudioToolbox
import SwiftUI

// Each section takes its parameter group as a concretely-typed
// `ObservableAUParameterGroup` and binds its enable parameter to a typed
// local rather than chaining `parameterTree.comp.compOn.boolValue` inline —
// @dynamicMemberLookup here only resolves reliably one hop at a time
// (see ObservableAUParameter.swift).

// MARK: - Layout

/// The four sections at the column count the panel width allows.
struct SectionsLayout: View {
    let parameterTree: ObservableAUParameterGroup
    let audioUnit: JJMoonAudioUnit?
    let width: CGFloat

    var body: some View {
        switch PanelMetrics.sectionColumns(forPanelWidth: width) {
        case 4:
            HStack(alignment: .top, spacing: PanelMetrics.columnSpacing) {
                SectionPlate(stretch: true) { curveSection }
                SectionPlate(stretch: true) { compSection }
                SectionPlate(stretch: true) { widthSection }
                SectionPlate(stretch: true) { spaceSection }
            }
            .fixedSize(horizontal: false, vertical: true)
        case 2:
            VStack(spacing: 14) {
                HStack(alignment: .top, spacing: PanelMetrics.columnSpacing) {
                    SectionPlate(stretch: true) { curveSection }
                    SectionPlate(stretch: true) { compSection }
                }
                .fixedSize(horizontal: false, vertical: true)
                HStack(alignment: .top, spacing: PanelMetrics.columnSpacing) {
                    SectionPlate(stretch: true) { widthSection }
                    SectionPlate(stretch: true) { spaceSection }
                }
                .fixedSize(horizontal: false, vertical: true)
            }
        default:
            VStack(spacing: 14) {
                SectionPlate { curveSection }
                SectionPlate { compSection }
                SectionPlate { widthSection }
                SectionPlate { spaceSection }
            }
        }
    }

    private var curveSection: CurveSection { CurveSection(group: parameterTree.curve) }
    private var compSection: CompSection { CompSection(group: parameterTree.comp, audioUnit: audioUnit) }
    private var widthSection: WidthSection { WidthSection(group: parameterTree.width) }
    private var spaceSection: SpaceSection { SpaceSection(group: parameterTree.space) }
}

/// A section's sub-plate.
struct SectionPlate<Content: View>: View {
    var stretch = false
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.horizontal, PanelMetrics.plateInset)
            .padding(.top, 11)
            .padding(.bottom, 15)
            // The stretch has to happen inside the background, or the plate
            // would draw at its content height and merely sit centred in a
            // taller slot.
            .frame(maxWidth: .infinity, maxHeight: stretch ? .infinity : nil, alignment: .top)
            .background(PanelPlate(theme: GearTheme.current))
    }
}

// MARK: - Sections

struct CurveSection: View {
    let group: ObservableAUParameterGroup

    var body: some View {
        let curveOn: ObservableAUParameter = group.curveOn
        let curveVoice: ObservableAUParameter = group.curveVoice
        VStack(alignment: .leading, spacing: 10) {
            // Inline beside the title where the column allows. In the
            // four-across layout it does not: squeezed into the header row
            // the tabs lost their labels and the row's minimum width shrank
            // this section's knobs below the other three's.
            ViewThatFits(in: .horizontal) {
                SectionHeader(title: "SHAPE", enabled: curveOn) {
                    voiceTabs(curveVoice)
                }
                VStack(alignment: .leading, spacing: 6) {
                    SectionHeader(title: "SHAPE", enabled: curveOn)
                    voiceTabs(curveVoice)
                }
            }

            SectionBody(enabled: curveOn) {
                HStack(spacing: PanelMetrics.knobRowSpacing) {
                    SectionKnob(param: group.curveAmount, caption: "CURVE", help: KnobHelp.curveAmount)
                    SectionKnob(param: group.curveWood, caption: "WOOD", help: KnobHelp.curveWood)
                    SectionKnob(param: group.curvePresence, caption: "PRES", help: KnobHelp.curvePresence)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func voiceTabs(_ curveVoice: ObservableAUParameter) -> some View {
        HStack(spacing: 4) {
            VoiceTab(title: "STEEL", index: JJMoonCurveVoices.steel, param: curveVoice)
            VoiceTab(title: "NYLON", index: JJMoonCurveVoices.nylon, param: curveVoice)
            VoiceTab(title: "FLAME", index: JJMoonCurveVoices.flamenco, param: curveVoice)
        }
    }
}

struct CompSection: View {
    let group: ObservableAUParameterGroup
    let audioUnit: JJMoonAudioUnit?

    var body: some View {
        let compOn: ObservableAUParameter = group.compOn
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "COMP", enabled: compOn)

            SectionBody(enabled: compOn) {
                VStack(spacing: 10) {
                    HStack(spacing: PanelMetrics.knobRowSpacing) {
                        SectionKnob(param: group.compAmount, caption: "COMP", help: KnobHelp.compAmount)
                        SectionKnob(param: group.compAttack, caption: "ATTACK", skew: 0.5, help: KnobHelp.compAttack)
                        SectionKnob(param: group.compRelease, caption: "RELEASE", skew: 0.5, help: KnobHelp.compRelease)
                    }
                    GainReductionMeter(audioUnit: audioUnit)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct WidthSection: View {
    let group: ObservableAUParameterGroup

    var body: some View {
        let widthOn: ObservableAUParameter = group.widthOn
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "WIDTH", enabled: widthOn)

            SectionBody(enabled: widthOn) {
                HStack(spacing: PanelMetrics.knobRowSpacing) {
                    SectionKnob(param: group.widthAmount, caption: "WIDTH", help: KnobHelp.widthAmount)
                    SectionKnob(param: group.widthFocus, caption: "FOCUS", skew: 0.35, help: KnobHelp.widthFocus)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SpaceSection: View {
    let group: ObservableAUParameterGroup

    var body: some View {
        let spaceOn: ObservableAUParameter = group.spaceOn
        VStack(alignment: .leading, spacing: 10) {
            SectionHeader(title: "SPACE", enabled: spaceOn)

            SectionBody(enabled: spaceOn) {
                HStack(spacing: PanelMetrics.knobRowSpacing) {
                    SectionKnob(param: group.spaceDouble, caption: "DOUBLE", help: KnobHelp.spaceDouble)
                    SectionKnob(param: group.spaceSize, caption: "SIZE", help: KnobHelp.spaceSize)
                    SectionKnob(param: group.spaceMix, caption: "ROOM", help: KnobHelp.spaceMix)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Building blocks

struct SectionHeader<Accessory: View>: View {
    let title: String
    let enabled: ObservableAUParameter
    @ViewBuilder var accessory: Accessory

    var body: some View {
        HStack(spacing: 7) {
            JewelLamp(isOn: enabled.boolValue, color: GearTheme.accent, theme: GearTheme.current)
                .frame(width: 9, height: 9)
            Text(title)
                .font(.system(size: 12, weight: .heavy))
                .tracking(2.0)
                .foregroundStyle(enabled.boolValue ? GearTheme.textLight : GearTheme.textMuted)
                .shadow(color: .black.opacity(0.7), radius: 0, x: 0, y: 1)
                .lineLimit(1)
            accessory
            Spacer(minLength: 4)
            LedToggle(param: enabled)
                .frame(width: 26, height: 40)
        }
    }
}

extension SectionHeader where Accessory == EmptyView {
    init(title: String, enabled: ObservableAUParameter) {
        self.init(title: title, enabled: enabled) { EmptyView() }
    }
}

/// Wraps a section's knob row in the shared enable/disable treatment.
/// `.allowsHitTesting` blocks all touch input — drag, tap, and
/// long-press-for-help — not just the Button-based controls; `.disabled()`
/// alone would not stop KnobView's raw `.gesture()`-based recognisers.
struct SectionBody<Content: View>: View {
    let enabled: ObservableAUParameter
    @ViewBuilder let content: Content

    var body: some View {
        content
            .opacity(enabled.boolValue ? 1 : 0.42)
            .allowsHitTesting(enabled.boolValue)
    }
}

/// A knob that shares its row's width equally with its neighbours.
struct SectionKnob: View {
    let param: ObservableAUParameter
    let caption: String
    var skew: Float = 1
    var symmetric = false
    var help: String?

    var body: some View {
        KnobView(param: param, caption: caption, skew: skew, symmetric: symmetric, helpText: help)
            .frame(maxWidth: .infinity)
    }
}

/// Indexed voice selector — Steel / Nylon / Flamenco. Guitar-native labels
/// are the clearest in-panel cue that this block is an acoustic target.
/// Sets an absolute index rather than toggling.
struct VoiceTab: View {
    let title: String
    let index: Int
    let param: ObservableAUParameter

    var body: some View {
        let selected = Int(param.value.rounded()) == index
        LampTab(title: title, isOn: selected) {
            param.value = AUValue(index)
        }
        .accessibilityLabel("\(title) curve")
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// A small labelled lamp for a secondary switch inside a section header —
/// the same lamp-and-silkscreen idiom as `SectionHeader`, at the size a
/// second switch can have without crowding the bat switch beside it.
struct LampTab: View {
    let title: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
            Haptics.impact(.light)
        } label: {
            HStack(spacing: 5) {
                JewelLamp(isOn: isOn, color: GearTheme.accent, theme: GearTheme.current)
                    .frame(width: 7, height: 7)
                Text(title)
                    .font(.system(size: 9, weight: .heavy))
                    .tracking(1.2)
                    .foregroundStyle(isOn ? GearTheme.textLight : GearTheme.textMuted)
                    // A few points short on a four-across iPad: shrink the
                    // lettering a touch rather than break "NYLON" in two.
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(GearTheme.chassisBottom.opacity(0.55))
                    .overlay(Capsule().stroke(.black.opacity(0.5), lineWidth: 1))
            )
            // The pill is the target, not the lamp and lettering inside it.
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
