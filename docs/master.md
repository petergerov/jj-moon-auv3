# Master

Input, Mix and Output act on the whole chain, and the two meters report what
enters and leaves it. Not a fifth stage in the signal path — a strip carrying
the four blocks, which is why it has no on/off switch of its own.

It sits **above** the blocks rather than below them. Every threshold
downstream is absolute, so nothing under it is worth judging until Input is
right; at the bottom of a scrolling panel it was off screen at the moment it
mattered most.

## Controls

| Control | Range | What it does |
|---|---|---|
| **Input** | −12 … +24 dB | Trim before the whole chain, dry path included. The first thing to set on a live / DI rig. |
| **Mix** | 0 … 100 % | Dry/wet for the **entire** chain. Leave at 100 % on an acoustic track; pull back for parallel colour. |
| **Output** | −12 … +12 dB | Trim after the mix. |

## Input, and why it is asymmetric

The compressor threshold is an absolute dBFS number. A mixed file peaks near
0 dBFS and reaches it easily; a guitar DI or pickup into an interface often
arrives 15–20 dB lower. Without trim, Comp's make-up can add level while the
GR meter correctly reports almost nothing.

It sits **ahead of the dry split**, not inside the wet path, so Mix blends
two signals that agree about how loud the input was.

## Meters

- **Input** — post-trim, so you set the trim by it.
- **Output** — stereo bars with peak hold; watch for clip after Curve / Comp
  make-up.
- **Gain reduction** — lives in Comp, next to the knobs that cause it, not on
  this strip.
