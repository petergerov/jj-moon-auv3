#pragma once

#include "Biquad.hpp"
#include <cmath>

/**
    The core of jj-moon: a fixed multi-band target curve that aims at the
    spectral shape of a well-mic'd acoustic guitar recording.

    Two voices:
      Steel (0) — western / steel-string. Reference: sample/TheLastFallenLeaf.mp3
                  (strong 80–250 Hz body, smooth mid downhill, restrained air).
      Nylon (1) — concert / classical / Spanish with nylon strings. Warmer mid
                  body, softer attack, earlier top, less 5 kHz sheen.

    Three macros (shared by both voices):
      Amount  — dry/wet of the whole curve (0 = flat bypass)
      Wood    — body vs air balance
      Presence — string detail (centres differ per voice)
*/
class AcousticCurve
{
public:
    enum Voice : int { Steel = 0, Nylon = 1 };

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
        presenceSheen.reset();
        airShelf.reset();
        topShelf.reset();
    }

    void setAmount(float amount01) { amount = std::clamp(amount01, 0.0f, 1.0f); }

    void setVoice(int v)
    {
        const int nv = (v >= Nylon) ? Nylon : Steel;
        if (nv == voice)
            return;
        voice = nv;
        updateCoefficients();
    }

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
        y = presenceSheen.processSample(y);
        y = airShelf.processSample(y);
        y = topShelf.processSample(y);

        // Soft wood saturation — nylon gets a slightly softer drive so the
        // result stays round rather than steel-string crunchy.
        const float driveScale = (voice == Nylon) ? 0.72f : 1.0f;
        const float drive = (0.35f + wood * 0.55f) * driveScale;
        const float k = 1.0f + drive * 2.8f;
        y = std::tanh(y * k) / std::tanh(k);

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
        if (voice == Nylon)
            updateNylon();
        else
            updateSteel();
    }

    void updateSteel()
    {
        // Western / steel-string ideal curve.
        const float bodyDb = 1.2f + wood * 3.3f;
        const float airDb = 2.8f * (1.0f - wood * 0.72f);
        const float presenceDb = -2.5f + presence * 9.5f;
        const float topHz = 14000.0f - wood * 5500.0f;
        const float sheenDb = std::max(0.0f, (presence - 0.35f) * 5.5f);

        highPass.setFromArray(Biquad::makeHighPass(sampleRate, 68.0f, 0.707f));
        bodyShelf.setFromArray(Biquad::makeLowShelf(sampleRate, 140.0f, 0.707f, dbToGain(bodyDb)));
        boxCut.setFromArray(Biquad::makePeakFilter(sampleRate, 360.0f, 0.85f,
                                                   dbToGain(-1.6f - wood * 1.2f)));
        midDip.setFromArray(Biquad::makePeakFilter(sampleRate, 820.0f, 0.7f, dbToGain(-1.4f)));
        presencePeak.setFromArray(Biquad::makePeakFilter(sampleRate, 2800.0f, 0.75f,
                                                         dbToGain(presenceDb)));
        presenceSheen.setFromArray(Biquad::makePeakFilter(sampleRate, 5200.0f, 1.0f,
                                                          dbToGain(sheenDb)));
        airShelf.setFromArray(Biquad::makeHighShelf(sampleRate, 7800.0f, 0.707f, dbToGain(airDb)));
        topShelf.setFromArray(Biquad::makeLowPass(sampleRate, topHz, 0.707f));
    }

    void updateNylon()
    {
        // Concert / classical / Spanish nylon.
        // Warmer mid-body (~200 Hz), less box scoop, softer presence around
        // 2.2 kHz, almost no 5 kHz sheen, earlier air and top — nylon does
        // not want steel-string sparkle.
        const float bodyDb = 2.0f + wood * 3.8f;                 // fuller chest
        const float airDb = 1.4f * (1.0f - wood * 0.85f);        // restrained air
        const float presenceDb = -1.5f + presence * 7.0f;        // milder lift
        const float topHz = 10000.0f - wood * 4500.0f;           // earlier roll-off
        // Sheen sits lower and quieter — finger tone, not pick sparkle.
        const float sheenDb = std::max(0.0f, (presence - 0.45f) * 3.0f);

        highPass.setFromArray(Biquad::makeHighPass(sampleRate, 55.0f, 0.707f));
        bodyShelf.setFromArray(Biquad::makeLowShelf(sampleRate, 200.0f, 0.707f, dbToGain(bodyDb)));
        // Classical "hollow" / boom is a bit lower than steel boxiness.
        boxCut.setFromArray(Biquad::makePeakFilter(sampleRate, 280.0f, 0.75f,
                                                   dbToGain(-1.0f - wood * 0.8f)));
        // Soft mid dip higher — leaves the romantic mid-body alone.
        midDip.setFromArray(Biquad::makePeakFilter(sampleRate, 1100.0f, 0.65f, dbToGain(-1.8f)));
        presencePeak.setFromArray(Biquad::makePeakFilter(sampleRate, 2200.0f, 0.7f,
                                                         dbToGain(presenceDb)));
        presenceSheen.setFromArray(Biquad::makePeakFilter(sampleRate, 3800.0f, 0.9f,
                                                          dbToGain(sheenDb)));
        airShelf.setFromArray(Biquad::makeHighShelf(sampleRate, 5600.0f, 0.707f, dbToGain(airDb)));
        topShelf.setFromArray(Biquad::makeLowPass(sampleRate, topHz, 0.707f));
    }

    double sampleRate = 44100.0;
    float amount = 0.65f;
    float wood = 0.55f;
    float presence = 0.45f;
    int voice = Steel;

    Biquad highPass;
    Biquad bodyShelf;
    Biquad boxCut;
    Biquad midDip;
    Biquad presencePeak;
    Biquad presenceSheen;
    Biquad airShelf;
    Biquad topShelf;
};
