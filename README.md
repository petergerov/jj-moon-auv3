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

- Xcode 16 or later
- iOS 17+
- Apple Developer team (set in Xcode Signing & Capabilities)
- App Group **`group.com.gerov.jjmoon`** on app + extension (for shared
  trial/unlock state)

## Open and build

```sh
xcodegen generate
open JJMoon.xcodeproj
```

**`project.yml` is the source of truth.** `xcodegen generate` rewrites
`project.pbxproj` from it, so anything set only in Xcode's GUI is gone at the
next run.

1. Select the **jj-moon** scheme.
2. Set your Development Team on both **JJMoon** and **JJMoonExtension**.
3. Run on an iPhone, iPad, or simulator.

Open the app once so the Audio Unit registers.

## Factory presets

Twelve, in panel order: Default, Fallen Leaf, Fingerstyle, Piezo Soft,
Stereo Porch, Close Mic, Moon Room, Strum, Curve Only, Nylon, Concert Hall,
Spanish Soft, Flamenco, Rasgueado, Soleá. Nylon presets use the Nylon voice;
Flamenco / Rasgueado / Soleá use the Flamenco voice.

User presets: tap the preset window → **Save As…**; swipe left to rename or delete.

## Demo parts

The container app bundles six acoustic recordings plus Mic. Picker labels
are bare numbers (they fit); VoiceOver gets the full name via `spokenName`.

| Segment | File | Spoken name |
|---|---|---|
| **1** (default) | `loop/acoustic-guitar-melody-calm.mp3` | Calm melody |
| **2** | `loop/chillin-acoustic-guitar.mp3` | Chillin |
| **3** | `loop/acoustic-guitar-chords-loneliness.mp3` | Loneliness |
| **4** | `loop/nylon-1.mp3` | Nylon 1 |
| **5** | `loop/nylon-2.mp3` | Nylon 2 |
| **6** | `loop/nylon-3.mp3` | Nylon 3 |

Decoded on demand rather than at launch. See `SimplePlayEngine.Source`.

## Project layout

```
JJMoon/                    Container app (test host)
JJMoonExtension/
  Parameters/               AUParameterTree, presets, StoreKit unlock
  DSP/                      C++ kernel (real-time; no Swift)
  UI/                       SwiftUI editor + GearTheme finishes
  Common/                   AUAudioUnit / process glue
docs/                       Marketing site + privacy (GitHub Pages)
icon/ loop/ screenshots/    Asset generators
sample/                     Reference recording used to shape the curve
```

`docs/` also carries one Markdown page per block — `curve.md`, `comp.md`,
`width.md`, `space.md`, plus `master.md` for Mix, Output and metering.

Only edit `Parameters`, `DSP`, and `UI` for plug-in behaviour. The render
thread lives entirely in `JJMoonDSPKernel.hpp`.

## Shared code with siblings

`Common/`, the UI kit, and the trial/unlock plumbing are a copy of
jj-midnight / jj-breeze, not a shared dependency. Fixes to shared files
should be carried across by hand until a local `JJKit` package exists.

## Generated assets

```sh
swift icon/make-icon.swift         # -> JJMoon/Assets.xcassets/.../AppIcon.png
screenshots/make-screenshots.sh    # -> screenshots/store/ + docs/images/
```

`make-icon.swift` draws the panel family composition in the Moonlight
colourway from `GearPalette.moonlight`.

## To do before shipping

Every field App Store Connect asks for is drafted in
[APP_STORE_SUBMISSION.md](APP_STORE_SUBMISSION.md). What is left:

- [ ] **App Store Connect** — new app record, new IAP for
      `com.gerov.jjmoon.unlock`, attached to the 1.0.0 build.
- [ ] **Distribution profiles** for `com.gerov.jjmoon` and `.AUv3`.
- [ ] **Store link** — fill `APP_STORE_URL` in `docs/index.html`.
- [ ] **Screenshots** — run `screenshots/make-screenshots.sh` once the panel
      is final, then commit `screenshots/store/` and `docs/images/`.
- [ ] **Privacy policy** — keep `docs/privacy.html` describing the shipped app.
- [ ] **Google Search Console** — `docs/` needs its own verification file.
