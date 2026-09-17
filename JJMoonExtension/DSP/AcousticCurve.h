#pragma once

#include "Biquad.hpp"
#include <cmath>

/**
    The core of jj-moon: a fixed multi-band target curve that aims at the
    spectral shape of a well-mic'd acoustic guitar recording.

    Measured reference (sample/TheLastFallenLeaf.mp3): energy peaks in the
    80–250 Hz body, then a smooth downhill through the mids, soft presence,
    and restrained air — not a scooped rock EQ, not a bright piezo spike.

    This stage does not try to *become* that spectrum (every guitar and mic
    is different). It applies a gentle, musically useful correction toward
    it: rumble out, body in, boxiness out, string presence in, air on top,
    and a soft wood-ish saturation so the result feels like wood and air
    rather than a parametric EQ.

    Three macros:
      Amount  — dry/wet of the whole curve (0 = flat bypass)
      Wood    — body vs air balance (up = warmer/fuller, down = more sparkle)
      Presence — string detail around 3 kHz
*/
class AcousticCurve
{
public:
    void prepare(double newSampleRate)
    {
        sampleRate = newSampleRate;
        updateCoefficients();
        reset();
    }

    void reset()
    {
        highPass.reset();
        bodyShelf.reset();
        boxCut.reset();
        midDip.reset();
        presencePeak.reset();
        airShelf.reset();
        topShelf.reset();
    }

    void setAmount(float amount01) { amount = std::clamp(amount01, 0.0f, 1.0f); }
    void setWood(float wood01)
    {
        const float w = std::clamp(wood01, 0.0f, 1.0f);
        if (std::abs(w - wood) < 1.0e-4f)
            return;
        wood = w;
        updateCoefficients();
    }

    void setPresence(float presence01)
    {
        const float p = std::clamp(presence01, 0.0f, 1.0f);
        if (std::abs(p - presence) < 1.0e-4f)
            return;
        presence = p;
        updateCoefficients();
    }

    float processSample(float x) noexcept
    {
        if (amount < 1.0e-4f)
            return x;

        float y = highPass.processSample(x);
        y = bodyShelf.processSample(y);
        y = boxCut.processSample(y);
        y = midDip.processSample(y);
        y = presencePeak.processSample(y);
        y = airShelf.processSample(y);
        y = topShelf.processSample(y);

        // Soft wood saturation — very gentle, just enough 2nd harmonic to
        // keep a DI from sounding like a pencil drawing of a guitar.
        const float drive = 0.35f + wood * 0.55f;
        const float k = 1.0f + drive * 2.8f;
        y = std::tanh(y * k) / std::tanh(k);

        // Slight make-up so Amount 100% is not quieter than dry on typical
        // material; the curve itself is roughly loudness-neutral.
        y *= 1.02f;

        return x + (y - x) * amount;
    }

private:
    static float dbToGain(float db) noexcept
    {
        return std::pow(10.0f, db / 20.0f);
    }

    void updateCoefficients()
    {
        // Body: +1.2 dB (air side) … +4.5 dB (wood side) at ~140 Hz.
        const float bodyDb = 1.2f + wood * 3.3f;
        // Air shelf: stronger when Wood is down.
        const float airDb = 2.8f * (1.0f - wood * 0.72f);
        // Presence peak scales with the Presence knob.
        const float presenceDb = presence * 3.2f;
        // Soft top roll-off: darker with more Wood.
        const float topHz = 14000.0f - wood * 5500.0f;

        highPass.setFromArray(Biquad::makeHighPass(sampleRate, 68.0f, 0.707f));
        bodyShelf.setFromArray(Biquad::makeLowShelf(sampleRate, 140.0f, 0.707f, dbToGain(bodyDb)));
        // Boxiness / boom around 320–400 Hz — always a little cut when the
        // curve is engaged; Wood deepens it slightly.
        boxCut.setFromArray(Biquad::makePeakFilter(sampleRate, 360.0f, 0.85f,
                                                   dbToGain(-1.6f - wood * 1.2f)));
        // Mild mid dip so the body and presence have room.
        midDip.setFromArray(Biquad::makePeakFilter(sampleRate, 820.0f, 0.7f, dbToGain(-1.4f)));
        presencePeak.setFromArray(Biquad::makePeakFilter(sampleRate, 3200.0f, 1.1f,
                                                         dbToGain(presenceDb)));
        airShelf.setFromArray(Biquad::makeHighShelf(sampleRate, 7800.0f, 0.707f, dbToGain(airDb)));
        topShelf.setFromArray(Biquad::makeLowPass(sampleRate, topHz, 0.707f));
    }

    double sampleRate = 44100.0;
    float amount = 0.65f;
    float wood = 0.55f;
    float presence = 0.45f;

    Biquad highPass;
    Biquad bodyShelf;
    Biquad boxCut;
    Biquad midDip;
    Biquad presencePeak;
    Biquad airShelf;
    Biquad topShelf;
};
