/// Long-press help for each knob on the panel, kept out of the layout code
/// so the section views read as structure rather than copy.
enum KnobHelp {
    static let curveAmount = "How far toward the mic'd acoustic target for the selected voice (Steel, Nylon, or Flamenco)."
    static let curveWood = "Body vs sparkle. Steel ~140 Hz, Nylon warmer ~200 Hz chest, Flamenco tighter ~160 Hz with less boom."
    static let curvePresence = "String / nail detail. Steel ~2.8–5 kHz, Nylon ~2.2–3.8 kHz, Flamenco mid-bite ~1.9–4.5 kHz for rasgueado."

    static let compAmount = "Optical-style squeeze. One control for threshold, ratio and make-up. Soft by design for acoustic dynamics."
    static let compAttack = "How fast the cell grabs. Slow keeps the pick attack; faster tames strums."
    static let compRelease = "The fast end of the release. Deeper reduction recovers slower on its own."

    static let widthAmount = "Micro-pitch + short delay stereo image (the breeze trick). Subtle at low settings; body stays mono via Focus."
    static let widthFocus = "Crossover: everything below stays dry. Raise it to keep the body centred; lower for full-band width."

    static let spaceDouble = "Short stereo Haas/flutter double — midnight's slap trick, shortened for acoustic."
    static let spaceSize = "Room size. Stretches early reflections and the tank; bigger also gets darker."
    static let spaceMix = "Soft acoustic room bloom. Not a spring — just a little air around the body."

    static let masterInput = "Input trim, −12 to +24 dB, before the whole chain. A guitar straight into an interface lands well below the Comp threshold. Turn this up until the INPUT meter sits in the marked band on your loudest playing, and the GR meter will start to move."
    static let masterMix = "Dry/wet for the entire chain. Leave it at 100% on a guitar track; pull it back to use this as a parallel colour."
    static let masterOutput = "Output trim, ±12 dB."
}
