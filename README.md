# jj-moon (AUv3)

An acoustic-guitar curve engine — ideal mic'd-recording shape, soft optical
comp, breeze-style stereo width, and a quiet room — as an Audio Unit (AUv3)
for iPhone and iPad. Sibling to [jj-midnight](https://github.com/petergerov/jj-midnight-auv3)
and [jj-breeze](https://github.com/petergerov/jj-breeze-auv3); same rack-panel
UI family, different job.

**Website:** [petergerov.github.io/jj-moon-auv3](https://petergerov.github.io/jj-moon-auv3)
**Support:** [GitHub Issues](https://github.com/petergerov/jj-moon-auv3/issues)

## What it is

Four macro blocks in signal order, each with its own on/off, plus a master strip:

```
In → trim → [SHAPE] → [COMP] → [WIDTH] → [SPACE: double + room] → Mix → Out
```

- **SHAPE** — the reason this plug-in exists. A fixed multi-band target
  curve aimed at well-mic'd acoustic recordings, with a **Steel / Nylon /
  Flamenco** voice switch. One Amount (Curve knob),
  plus Wood and Presence.
- **COMP** — optical compressor with program-dependent release. Soft defaults
  for acoustic dynamics.
- **WIDTH** — breeze micro-pitch + short delay stereo image, with a Focus
  crossover so the body stays mono.
- **SPACE** — short Haas/flutter double (midnight's slap trick, shortened)
  into a soft acoustic room bloom — not a spring tank.

The master strip sits above the four blocks: Input trim first, then Mix and
Output. Acoustic DIs and pickup feeds often sit well below the compressor's
absolute thresholds — set Input before judging anything downstream.

**AU identity:** type `aufx`, subtype `Jjmo`, manufacturer `Grov` — listed in
hosts as **jj-moon** (Gerov).

## Naming

The name is **jj-moon**, baked into the bundle IDs, the AU subtype, the repo
and the site. Preset names describe a *feel* or a place, never a person or a
record; the plug-in is not affiliated with any artist or third-party vendor.

## Pricing

Same model as jj-breeze / jj-midnight: free download, 7-day trial from first
launch, then a one-time unlock (`com.gerov.jjmoon.unlock`).

## Requirements

- iPhone or iPad on iOS 17+
- An AUv3 host (GarageBand, AUM, Logic Pro for iPad, Cubasis, …)

## Factory presets

Fifteen, in panel order: Default, Fallen Leaf, Fingerstyle, Piezo Soft,
Stereo Porch, Close Mic, Moon Room, Strum, Curve Only, Nylon, Concert Hall,
Spanish Soft, Flamenco, Rasgueado, Soleá. Nylon presets use the Nylon voice;
Flamenco / Rasgueado / Soleá use the Flamenco voice.

User presets: tap the preset window → **Save As…**; swipe left to rename or delete.

## Documentation

One page per block: [SHAPE](docs/curve.md), [COMP](docs/comp.md),
[WIDTH](docs/width.md), [SPACE](docs/space.md), and [Master](docs/master.md)
for Mix, Output and metering. Privacy policy: [docs/privacy.html](docs/privacy.html).

## Releases

**1.0.0** is live on the [App Store](https://apps.apple.com/app/id6813232689)
(2026-09-22). **1.0.1** is the next update.
