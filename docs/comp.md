# Comp

Optical compressor, second in the chain — after Curve has set the tone, before
Width and Space. Soft defaults for acoustic dynamics; the same program-
dependent release idea as jj-midnight.

Optical cells have no sharp threshold and no adjustable ratio — they just
start to lean on the signal — so this block gives you one **Comp** knob that
moves threshold, ratio and make-up together, plus Attack and Release.

## What makes it optical

The release. In a real photocell the recovery is not a fixed time constant: it
snaps back from a light squeeze and crawls back from a heavy one. Here the
release coefficient is recomputed every sample from how much gain reduction is
currently applied. Picked transients get rounded; the tail of a note never
pumps back up at you.

The knee is soft and the ratio is gentle — about 1.8:1 at the bottom of Comp,
about 4:1 at the top.

## Controls

| Control | Range | What it does |
|---|---|---|
| **Comp** | 0–100 % | Threshold, ratio and make-up together. Up is more squash, not more level. |
| **Attack** | 5–80 ms | How fast the cell grabs. Slow keeps the pick; faster tames strums. |
| **Release** | 40–400 ms | The fast end of the release. Deeper reduction recovers slower on its own. |
| **On/Off** | | Bypass for Comp only. |

The detector is stereo-linked (`max(|L|, |R|)`), so a loud left channel does
not pull the image sideways.

## Gain-reduction meter

A bar under Comp's knobs, filling right to left. It is a damped mass on a
spring rather than a smoothed value — it overshoots slightly and settles the
way a moving-coil meter does. The dB figure you want is this meter, not a
threshold readout on the Comp knob.
