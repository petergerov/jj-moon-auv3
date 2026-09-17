#pragma once

#include "Biquad.hpp"
#include "DSPCommon.h"
#include <algorithm>
#include <cmath>
#include <vector>

/**
    A short, damped acoustic room — early reflections into a single
    recirculating delay with a low-pass in the feedback path.

    Deliberately not a spring tank and not a big hall. Acoustic guitar wants
    a little air around the body, not splash. Size stretches the taps and the
    tank; Mix is the wet level. Stereo is free: pass a different seedPhase
    per channel so L/R do not clone each other.
*/
class RoomBloom
{
public:
    void prepare(double newSampleRate, float seedPhase = 0.0f)
    {
        sampleRate = newSampleRate;
        phase = seedPhase;
        const int maxMs = 420;
        maxDelaySamples = std::max(64, (int) std::round(sampleRate * maxMs / 1000.0));
        buffer.assign((size_t) maxDelaySamples + 4, 0.0f);
        writePos = 0;
        damping.setFromArray(Biquad::makeLowPass(sampleRate, 4200.0f, 0.707f));
        reset();
    }

    void reset()
    {
        std::fill(buffer.begin(), buffer.end(), 0.0f);
        writePos = 0;
        damping.reset();
        tank = 0.0f;
    }

    void setSize(float size01)
    {
        size = std::clamp(size01, 0.0f, 1.0f);
        // Darker rooms as they get bigger — more air absorption.
        const float dampHz = 5600.0f - size * 2200.0f;
        damping.setFromArray(Biquad::makeLowPass(sampleRate, dampHz, 0.707f));
    }

    void setMix(float mix01) { mix = std::clamp(mix01, 0.0f, 1.0f); }

    float processSample(float x) noexcept
    {
        if (mix < 1.0e-4f)
        {
            // Keep the buffer moving so enabling Mix is click-free.
            writeSample(x * 0.15f);
            return x;
        }

        // Early taps, offset per channel via `phase` so the image breathes.
        const float s = 0.35f + size * 0.65f;
        const float t0 = readMs(12.0f * s + phase * 3.0f);
        const float t1 = readMs(23.0f * s + phase * 5.0f);
        const float t2 = readMs(41.0f * s + (1.0f - phase) * 4.0f);
        const float early = t0 * 0.45f + t1 * 0.32f + t2 * 0.23f;

        // Tank: one recirculating delay, damped, no metallic spring chirp.
        const float tankDelayMs = 55.0f + size * 95.0f + phase * 11.0f;
        const float delayed = readMs(tankDelayMs);
        const float feedback = 0.28f + size * 0.22f;
        tank = damping.processSample(delayed + early * 0.35f);
        writeSample(x * 0.55f + tank * feedback);

        const float wet = early * 0.7f + tank * 0.55f;
        return x * (1.0f - mix * 0.55f) + wet * mix;
    }

private:
    void writeSample(float v) noexcept
    {
        buffer[(size_t) writePos] = v;
        writePos = (writePos + 1) % maxDelaySamples;
    }

    float readMs(float ms) const noexcept
    {
        float delaySamples = ms * 0.001f * (float) sampleRate;
        delaySamples = std::clamp(delaySamples, 1.0f, (float) maxDelaySamples - 2.0f);
        float readPos = (float) writePos - delaySamples;
        while (readPos < 0.0f)
            readPos += (float) maxDelaySamples;
        const int i0 = (int) readPos;
        const int i1 = (i0 + 1) % maxDelaySamples;
        const float frac = readPos - (float) i0;
        return buffer[(size_t) i0] * (1.0f - frac) + buffer[(size_t) i1] * frac;
    }

    double sampleRate = 44100.0;
    int maxDelaySamples = 1;
    int writePos = 0;
    float size = 0.45f;
    float mix = 0.18f;
    float phase = 0.0f;
    float tank = 0.0f;
    std::vector<float> buffer;
    Biquad damping;
};
