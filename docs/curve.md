# Curve

The reason jj-moon exists — and the first block in the chain.

A fixed multi-band target shape aimed at well-mic'd acoustic guitar
recordings. It does not try to *become* any one record; it applies a gentle,
musically useful correction toward that neighbourhood: rumble out, body in,
boxiness out, a soft mid dip so presence has room, string detail, and air on
top, with a touch of soft saturation so a DI does not sound like a pencil
drawing of a guitar.

Tuned against reference material such as `sample/TheLastFallenLeaf.mp3`
(strong 80–250 Hz body, smooth downhill through the mids, restrained air).

## Controls

| Control | Range | What it does |
|---|---|---|
| **Curve** | 0–100 % | Dry/wet of the whole target curve. 0 % is flat bypass. |
| **Wood** | 0–100 % | Body vs sparkle. Up = warmer/fuller (~140 Hz shelf, darker top). Down = more air shelf. |
| **Presence** | 0–100 % | String detail around 3 kHz. Useful on fingerstyle; keep it low on harsh piezo. |
| **On/Off** | | Bypass for Curve only. DSP keeps running, so switching back is click-free. |

## What moves under the hood

At full Amount with middle Wood / Presence settings, roughly:

- High-pass ~68 Hz
- Low shelf ~140 Hz (Wood scales the boost)
- Peak cut ~360 Hz (boxiness; deeper with more Wood)
- Mild mid dip ~820 Hz
- Presence peak ~3.2 kHz (Presence scales the boost)
- High shelf ~7.8 kHz (stronger when Wood is down)
- Soft low-pass that darkens as Wood goes up
- Gentle tanh saturation keyed off Wood

## What to reach for

- **Piezo Soft** — high Curve, high Wood, low Presence
- **Fingerstyle** — less Wood, more Presence
- **Curve Only** — hear the shape alone with Comp / Width / Space off
