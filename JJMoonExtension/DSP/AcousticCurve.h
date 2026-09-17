#pragma once

#include "Biquad.hpp"
#include <cmath>

/**
    The core of jj-moon: a fixed multi-band target curve that aims at the
    spectral shape of a well-mic'd acoustic guitar recording.

    Three voices:
      Steel (0)    — western / steel-string. Reference: TheLastFallenLeaf.mp3
      Nylon (1)    — concert / classical. Warm mid-body, soft attack, early top.
      Flamenco (2) — nylon too, but tight body, mid-bite for rasgueado / golpe,
                     brighter attack than concert, less romantic chest.

    Three macros (shared by all voices):
      Amount  — dry/wet of the whole curve (0 = flat bypass)
      Wood    — body vs air balance
      Presence — string / nail detail (centres differ per voice)
*/
class AcousticCurve
{
public:
    enum Voice : int { Steel = 0, Nylon = 1, Flamenco = 2 };

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
        const int nv = std::clamp(v, (int) Steel, (int) Flamenco);
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

        // Saturation character follows the voice: nylon soft, flamenco a
        // touch more edge for nail attack, steel in between-ish on the high end.
        float driveScale = 1.0f;
        if (voice == Nylon)
            driveScale = 0.72f;
        else if (voice == Flamenco)
            driveScale = 0.88f;
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
        switch (voice)
        {
            case Flamenco: updateFlamenco(); break;
            case Nylon:    updateNylon();    break;
            default:       updateSteel();    break;
        }
    }

    void updateSteel()
    {
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
        const float bodyDb = 2.0f + wood * 3.8f;
        const float airDb = 1.4f * (1.0f - wood * 0.85f);
        const float presenceDb = -1.5f + presence * 7.0f;
        const float topHz = 10000.0f - wood * 4500.0f;
        const float sheenDb = std::max(0.0f, (presence - 0.45f) * 3.0f);

        highPass.setFromArray(Biquad::makeHighPass(sampleRate, 55.0f, 0.707f));
        bodyShelf.setFromArray(Biquad::makeLowShelf(sampleRate, 200.0f, 0.707f, dbToGain(bodyDb)));
        boxCut.setFromArray(Biquad::makePeakFilter(sampleRate, 280.0f, 0.75f,
                                                   dbToGain(-1.0f - wood * 0.8f)));
        midDip.setFromArray(Biquad::makePeakFilter(sampleRate, 1100.0f, 0.65f, dbToGain(-1.8f)));
        presencePeak.setFromArray(Biquad::makePeakFilter(sampleRate, 2200.0f, 0.7f,
                                                         dbToGain(presenceDb)));
        presenceSheen.setFromArray(Biquad::makePeakFilter(sampleRate, 3800.0f, 0.9f,
                                                          dbToGain(sheenDb)));
        airShelf.setFromArray(Biquad::makeHighShelf(sampleRate, 5600.0f, 0.707f, dbToGain(airDb)));
        topShelf.setFromArray(Biquad::makeLowPass(sampleRate, topHz, 0.707f));
    }

    void updateFlamenco()
    {
        // Flamenco nylon: tight low end (less boom than concert), mid-bite
        // for rasgueado / golpe (~1.6–2.5 kHz), nail sheen ~4–5 kHz, air that
        // cuts earlier than steel but brighter than classical.
        // Blind A/B vs Nylon: less chest, more attack, more mid projection.
        const float bodyDb = 0.6f + wood * 2.4f;                 // tighter body
        const float airDb = 2.2f * (1.0f - wood * 0.65f);        // more air than nylon
        const float presenceDb = -1.0f + presence * 8.5f;        // strong mid-bite
        const float topHz = 12000.0f - wood * 4000.0f;
        const float sheenDb = std::max(0.0f, (presence - 0.25f) * 4.5f);

        highPass.setFromArray(Biquad::makeHighPass(sampleRate, 72.0f, 0.707f));
        // Body shelf lower/smaller than nylon — flamenco guitars are often
        // mic'd to avoid the woolly 200 Hz build-up.
        bodyShelf.setFromArray(Biquad::makeLowShelf(sampleRate, 160.0f, 0.707f, dbToGain(bodyDb)));
        // Deeper cut on the hollow boom so rasgueados stay articulate.
        boxCut.setFromArray(Biquad::makePeakFilter(sampleRate, 300.0f, 0.9f,
                                                   dbToGain(-2.4f - wood * 1.4f)));
        // Lift the attack band instead of dipping it — opposite of nylon's
        // romantic mid scoop. A mild dip just below keeps it from getting nasal.
        midDip.setFromArray(Biquad::makePeakFilter(sampleRate, 700.0f, 0.7f, dbToGain(-1.2f)));
        // Mid-bite centre — nail / rasgueado projection.
        presencePeak.setFromArray(Biquad::makePeakFilter(sampleRate, 1900.0f, 0.85f,
                                                         dbToGain(presenceDb)));
        presenceSheen.setFromArray(Biquad::makePeakFilter(sampleRate, 4500.0f, 1.0f,
                                                          dbToGain(sheenDb)));
        airShelf.setFromArray(Biquad::makeHighShelf(sampleRate, 6500.0f, 0.707f, dbToGain(airDb)));
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
