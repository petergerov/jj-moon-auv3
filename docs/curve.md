# Shape (Curve)

The reason jj-moon exists — and the first block in the chain. On the panel
the section is labelled **SHAPE**; the Amount knob is still **CURVE**.

A fixed multi-band target shape aimed at well-mic'd acoustic guitar
recordings. Three voices share the same knobs but different targets:

| Voice | For | Character |
|---|---|---|
| **Steel** | Western / steel-string | Body ~140 Hz, presence ~2.8–5 kHz, open air |
| **Nylon** | Concert / classical / Spanish | Warmer chest ~200 Hz, softer presence ~2.2–3.8 kHz, earlier top |
| **Flamenco** | Rasgueado / golpe / Spanish attack | Tighter body ~160 Hz, mid-bite ~1.9–4.5 kHz, less boom than concert |

Tuned against reference material such as `sample/TheLastFallenLeaf.mp3`
for Steel (strong 80–250 Hz body, smooth downhill through the mids).

## Controls

| Control | Range | What it does |
|---|---|---|
| **STEEL / NYLON / FLAME** | tabs | Selects the acoustic target voice. |
| **Curve** | 0–100 % | Dry/wet of the whole target shape. 0 % is flat bypass. |
| **Wood** | 0–100 % | Body vs sparkle. Centre frequency follows the voice. |
| **Presence** | 0–100 % | String detail. 0 % gently cuts harshness; 100 % lifts attack/sheen. Keep it low on harsh piezo. |
| **On/Off** | | Bypass for Shape only. |

## Steel under the hood

- High-pass ~68 Hz; body shelf ~140 Hz
- Box cut ~360 Hz; mid dip ~820 Hz
- Presence ~2.8 kHz (−2.5…+7 dB) + sheen ~5.2 kHz
- Air shelf ~7.8 kHz; top roll-off follows Wood

## Nylon under the hood

- High-pass ~55 Hz; body shelf ~200 Hz (fuller chest)
- Softer box cut ~280 Hz; mid dip ~1.1 kHz
- Presence ~2.2 kHz (milder) + soft sheen ~3.8 kHz
- Air shelf ~5.6 kHz; earlier top — nylon does not want steel sparkle
- Gentler saturation

## Flamenco under the hood

- High-pass ~72 Hz; body shelf ~160 Hz (tighter than Nylon)
- Deeper box cut ~300 Hz so rasgueados stay articulate
- Mild dip ~700 Hz; presence / mid-bite ~1.9 kHz + nail sheen ~4.5 kHz
- Air shelf ~6.5 kHz; top between Steel and Nylon
- Saturation between Nylon softness and Steel edge

Blind A/B vs Nylon: less chest, more attack, more mid projection.

## What to reach for

- **Piezo Soft** — Steel, high Curve, high Wood, low Presence
- **Nylon** / **Spanish Soft** — Nylon voice, warmer Wood
- **Concert Hall** — Nylon with more Space
- **Flamenco** — Flamenco voice, mid Presence, tight Wood
- **Rasgueado** — Flamenco, high Presence, fast Comp, dry Space
- **Soleá** — Flamenco with more Space for solo lines
- **Curve Only** — hear the shape alone with Comp / Width / Space off
