# App Store submission — jj-moon

Everything App Store Connect asks for, written down once so the answers do
not get improvised at the upload screen. Copy the fenced blocks verbatim;
they are already inside Apple's character limits.

Two rules govern every line of copy here:

- **No song titles, artist names, or band names in the listing.** They are
  tolerable on preset names inside the app and are not tolerable on a store
  page. Describe the sound instead.
- **Never claim the plug-in reproduces a particular record or mic setup.**
  The presets are original settings arrived at by ear.

---

## Status

| | |
|---|---|
| Live on the App Store | **1.0.0**, released 2026-09-22 — [id6813232689](https://apps.apple.com/app/id6813232689) |
| Next build | **1.0.1** (`1`) — archive locally, upload via Xcode Organizer. Not uploaded yet. |
| IAP record | Live; shipped with 1.0.0. Nothing to do for updates. |
| Screenshots | Regenerated for 1.0.1 (`screenshots/store/`) — upload to replace the 1.0.0 set. |
| Copy | Entered for 1.0.0. 1.0.1 needs only *What's New* (below). |
| Privacy policy | At `docs/privacy.html` — keep it current. |
| Distribution profiles | In place (1.0.0 shipped with them). |

---

## Identifiers

Set in `project.yml`, which is the source of truth — `xcodegen generate`
rewrites `project.pbxproj` from it.

| Field | Value |
|---|---|
| App bundle ID | `com.gerov.jjmoon` |
| Extension bundle ID | `com.gerov.jjmoon.AUv3` |
| App Group | `group.com.gerov.jjmoon` |
| Team ID | `C9LBGZNZ6P` |
| App Store ID | `6813232689` |
| Version / build | `1.0.1` (`1`) — `MARKETING_VERSION` / `CURRENT_PROJECT_VERSION` in `project.yml`; both Info.plists read them |
| Deployment target | iOS 17.0 |
| Devices | iPhone + iPad (`TARGETED_DEVICE_FAMILY = 1,2`) |
| Mac (Designed for iPad) | Yes |
| Mac Catalyst / visionOS | No |

**AU identity:** type `aufx`, subtype `Jjmo`, manufacturer `Grov`. Hosts list
it as **jj-moon** under manufacturer **Gerov**.

These four-character codes are permanent in practice. A host saves them into
every project file that uses the plug-in, so changing one after release
silently breaks every session a customer has already saved.

Distinct from siblings: jj-breeze is `Jjb3`, jj-midnight is `Jjm1`.

---

## App information

**Name** (30 char limit, currently 20) — as live on the store:

```
J.J.Moon AUv3 Plugin
```

In hosts and in the app itself the product is still **jj-moon**; this is
only the store listing's title.

**Subtitle** (30 char limit, currently 28):

```
Acoustic guitar curve for AUv3
```

**Primary category:** Music
**Secondary category:** Entertainment

**Age rating:** 4+. Nothing in the app triggers a higher band.

**SKU:** `jj-moon-ios`

**Copyright:** `2026 Gerov`

### Content Rights

App Store Connect → **App Information** → **Content Rights**.

| Answer | Value |
|---|---|
| **Does this app use third-party content?** | **No** |

jj-moon is an original Gerov effect (own DSP, demo loops, UI). Preset names
describe a *feel* and are not third-party media.

---

## Description

4000 char limit; this is about 1,700.

```
Body, air, and string detail — the shape of a well-mic'd acoustic, without
a rack of EQ.

jj-moon is an acoustic-guitar curve engine in a single AUv3 insert. Four
blocks in signal order, each with its own on/off, plus a master strip.

SHAPE — A fixed multi-band target aimed at great acoustic recordings: rumble
out, body in, boxiness out, soft mid dip, string presence, air on top. Three
voices — Steel, Nylon, Flamenco — share the same knobs. One Curve amount for
how far you go, Wood for body vs sparkle, Presence for the strings. This is
the block the whole plug-in is built around.

COMP — An optical compressor with program-dependent release. Soft by design
for acoustic dynamics. One Comp knob for threshold, ratio and make-up
together, plus Attack and Release. A gain-reduction meter shows what it is
doing.

WIDTH — Stereo micro-pitch and short delay (the same family of trick as a
classic microshifter), with a Focus crossover so the body stays centred
while the highs open up.

SPACE — A short stereo double with gentle flutter, into a soft acoustic
room bloom. Not a spring tank — just a little air around the instrument.

FIFTEEN FACTORY PRESETS
Default, Fallen Leaf, Fingerstyle, Piezo Soft, Stereo Porch, Close Mic,
Moon Room, Strum, Curve Only, Nylon, Concert Hall, Spanish Soft, Flamenco,
Rasgueado, Soleá. Save your own from the preset window; swipe left to
rename or delete.

WORKS WHERE YOU WORK
An Audio Unit v3 effect: GarageBand, Logic for iPad, AUM, Cubasis,
BeatMaker, and any other AUv3 host. The included app is a working player —
six acoustic demo parts are bundled (steel + nylon), or run your own
playing through the microphone.

The panel is drawn procedurally rather than assembled from bitmaps, so it
stays sharp at whatever size your host gives it, on a phone or a 13-inch
iPad. Moonlight, Slate, Field Green, or Tweed finishes.

FREE TO TRY
Seven days free from first launch. No account, no signup, no subscription.
After that, one purchase unlocks it permanently on all your devices. If you
do not buy it, the editor keeps working and audio passes through dry —
nothing you built disappears.

jj-moon is an original effect. Preset names point at a feel or a place.
It is not affiliated with, endorsed by, or associated with any artist,
label, or other plug-in maker, and does not recreate any particular
recording.
```

**Promotional text** (170 char limit, editable without a new build):

```
Acoustic guitar curve, soft comp, stereo width and room — one AUv3 insert.
Seven days free, then one purchase — no subscription.
```

**Keywords** (100 char limit, comma-separated, no spaces after commas):

```
acoustic,guitar,auv3,audio unit,eq,compressor,stereo,width,reverb,piezo,fingerstyle,plugin
```

Do not repeat words already in the name or subtitle; Apple indexes those
anyway, so "moon" and "curve" would be wasted.

**What's New** — 1.0.1 (4000 char limit):

```
• Shape: the Steel / Nylon / Flame buttons no longer split their names
  onto two lines on iPhone and on large iPads, and on a 13-inch iPad the
  Shape knobs now match the size of the other sections.
• Meters: with more than one jj-moon open in the same host, each copy
  now shows only its own levels.
• Lower memory use when the editor is opened and closed repeatedly.
• Smaller fixes and internal clean-up.
```

Keep it to what a user can notice. Refactors and tooling changes stay out.

---

## URLs

| Field | Value |
|---|---|
| Marketing URL | `https://petergerov.github.io/jj-moon-auv3` |
| Support URL | `https://github.com/petergerov/jj-moon-auv3/issues` |
| Privacy Policy URL | `https://petergerov.github.io/jj-moon-auv3/privacy.html` |

The repository is `petergerov/jj-moon-auv3`, so the Pages site is served
from `/jj-moon-auv3` — the `-auv3` suffix is part of the URL, exactly as
for `jj-breeze-auv3` and `jj-midnight-auv3`. Dropping it gives a 404.

`docs/privacy.html` must keep describing the shipped app (six demo parts,
optional mic, no analytics).

---

## In-app purchase

One non-consumable. It shipped attached to the 1.0.0 build and is live;
later versions need nothing done to it.

| Field | Value |
|---|---|
| Type | Non-Consumable |
| Product ID | `com.gerov.jjmoon.unlock` |
| Reference name | jj-moon Unlock |
| Price tier | $2.99 (USD) |
| Family Sharing | Enabled |

**Display name** (30 char limit):

```
jj-moon Unlock
```

**Description** (45 char limit):

```
Unlock the effect forever. One purchase.
```

These match `Configuration/Products.storekit` and
`JJMoonExtension/Parameters/PurchaseProducts.swift` — all three have to
agree or the paywall shows "Unlock product not available yet."

**Review Screenshot** (required on the IAP record — 640×920, RGB, no alpha):

```sh
screenshots/make-iap-review.sh
```

Upload `screenshots/store/AppReview-IAP-unlock.png` into App Store Connect →
In-App Purchases → jj-moon Unlock → App Store Review Information → Screenshot.
This is only for the reviewer; it is not a Store listing image.

---

## Screenshots

Generated by `screenshots/make-screenshots.sh`. No device frames, no
composited backgrounds, no marketing text over the top.

| Slot | Path | Size | Shots |
|---|---|---|---|
| iPhone 6.9" (required) | `screenshots/store/iphone-6.9/` | 1320 x 2868 | 3 |
| iPad 13" (required) | `screenshots/store/ipad-13/` | 2064 x 2752 | 2 |

Upload order — first shot is the search-results thumbnail:

1. `01-panel` — the panel as it opens (Shape with Steel/Nylon/Flame, Comp,
   Width, Space). Suggested ASC caption: **Acoustic guitar · one insert**.
2. `02-width-space` — Width and Space (iPhone only; iPad already fits).
   Caption: **Width and room around the body**.
3. `03-presets` — the preset window open over the panel.
   Caption: **Steel, nylon, flamenco factory starts**.

Do not bake marketing text into the PNGs — App Review rejects UI the app
does not show. Captions live in App Store Connect.

**There is deliberately no paywall screenshot** — currency differs by
storefront.

```sh
screenshots/make-screenshots.sh
python3 - <<'PY'
import glob, struct
for p in sorted(glob.glob("screenshots/store/*/*.png")):
    d = open(p, "rb").read(3000)
    w, h = struct.unpack(">II", d[16:24])
    print(f"{w}x{h}", "EXIF-TAGGED" if b"eXIf" in d else "ok", p)
PY
```

Expect five lines: three at 1320x2868, two at 2064x2752, all `ok`.

**Look at every image before committing — a passing run is not enough.**
The trial is counted from the first launch on each simulator, and the date
survives between runs; a week later the app opens on the paywall and
`testPanel` still passes while photographing it. The script now uninstalls
the app before each device run to prevent that, but check the images anyway.

---

## App privacy

Answer **Data Not Collected**. No account, no analytics, no advertising SDK,
no crash reporter that phones home. Install date and unlock state live in
`UserDefaults` / App Group on-device only.

Purchases go through StoreKit (Apple's transaction).

**Microphone:** optional in the companion app for live input. Usage string is
in `JJMoon/Info.plist`. Audio is processed on-device, never uploaded. Six
bundled acoustic parts work without mic permission.

---

## Signing and archiving

```sh
xcodebuild -project JJMoon.xcodeproj -scheme jj-moon \
           -configuration Release -destination 'generic/platform=iOS' \
           -archivePath DerivedData/jj-moon.xcarchive archive
```

**Exporting for the store needs App Store provisioning profiles** for both
`com.gerov.jjmoon` and `com.gerov.jjmoon.AUv3`. Xcode creates them on the
first Organizer upload (`-allowProvisioningUpdates`), or create them in the
developer portal by hand.

Confirm the archive embeds the six `loop/*.mp3` demos and the appex
`AudioComponents` entry with subtype `Jjmo`.

---

## Export compliance

`ITSAppUsesNonExemptEncryption` should be `false` in `JJMoon/Info.plist`
(same pattern as siblings), so App Store Connect will not ask at upload.

---

## App Review notes

```
No account or login is required. Nothing is gated behind a signup.

jj-moon is an Audio Unit (AUv3) effect plug-in. The app you have
downloaded contains the plug-in and also works as a standalone player, so
the effect can be reviewed without installing a DAW:

1. Open the app. It opens on demo part 1 (Calm melody) — tap Play.
2. Turn any knob on the panel. Shape, Comp, Width and Space each have an
   on/off switch so their contribution can be heard individually.
3. Tap the preset window at the top to load any of the 15 factory presets.
   Try Steel / Nylon / FLAME on the Shape section, or load Flamenco / Rasgueado.
4. Use the segmented control (1–6 / Mic / USB) to switch demo parts or live input.

To review it as a plug-in inside another app (optional):

1. Open jj-moon once, so iOS registers the Audio Unit.
2. Open GarageBand, create an Audio Recorder track.
3. Plug-ins & EQ -> Edit -> Audio Unit Extensions -> jj-moon.

TRIAL AND PURCHASE
The effect is free for 7 days from first launch, with no signup. After that
it can be unlocked with a single non-consumable purchase
(com.gerov.jjmoon.unlock). There is no subscription. When the trial ends
and the app has not been unlocked, the editor stays fully usable and audio
passes through unprocessed rather than the app locking the user out.

The trial start date is written to the app's App Group container on first
launch, so the app and the plug-in extension agree on how much trial is left
whichever one the user opens first.

MICROPHONE
The microphone / USB input is optional and used only to feed live audio through the
effect in the standalone player. Six acoustic recordings are bundled so
the app can be reviewed without granting it.
```

---

## Shipping an update

- [ ] Bump `MARKETING_VERSION` in `project.yml` (and reset
      `CURRENT_PROJECT_VERSION` to `1`, or raise it for a rebuild of the
      same version), then `xcodegen generate`.
- [ ] Archive with the **jj-moon** scheme, Release config — not the
      extension alone. Check the archive's app *and* appex both carry the
      new version.
- [ ] Confirm the AU registers on a real device, not just the simulator.
- [ ] Regenerate screenshots if the panel changed, and look at every
      image (see *Screenshots*).
- [ ] Upload from Xcode Organizer; in App Store Connect create the new
      version, pick the build, paste *What's New*, replace screenshots if
      regenerated.
- [ ] Re-read `docs/privacy.html` if the feature set changed.

---

## Things that are not settled

**Preset packs, not more DSP.** The curve engine is the product; further
presets are the intended way to grow the listing without boxing it into one
genre.
