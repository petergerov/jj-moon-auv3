#pragma once

#include <AudioToolbox/AUParameters.h>

/// Four macro blocks in signal order, then the master strip.
/// Curve → Comp → Width → Space → Mix/Out
typedef NS_ENUM(AUParameterAddress, JJMoonParameterAddress) {
    // Curve — ideal acoustic target curve (body / wood / presence / air).
    curveAmount = 0,
    curveWood,
    curvePresence,
    curveOn,

    // Comp — optical, second in the chain so the curve sets the tone first.
    compAmount,
    compAttack,
    compRelease,
    compOn,

    // Width — breeze-style micro-pitch + short delay stereo image.
    widthAmount,
    widthFocus,
    widthOn,

    // Space — soft Haas double + acoustic room bloom.
    spaceDouble,
    spaceSize,
    spaceMix,
    spaceOn,

    // Master.
    masterMix,
    masterOutput,

    // Input trim last so saved addresses never renumber mid-list.
    masterInput
};
