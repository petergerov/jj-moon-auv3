#pragma once

#include <AudioToolbox/AudioToolbox.h>
#include <algorithm>
#include <cmath>
#include <span>
#include <vector>

#include "JJMoonParameterAddresses.h"
#include "AcousticCurve.h"
#include "CompressorStage.h"
#include "PitchShifter.h"
#include "ModulatedDelay.h"
#include "RoomBloom.h"
#include "Biquad.hpp"

/**
    Acoustic guitar chain, in order:

        Curve → Comp → Width → Space (double + room) → Mix → Output

    Curve is the reason this plug-in exists: a target spectral shape aimed at
    well-mic'd acoustic recordings. Width is the breeze micro-pitch trick
    (high band only via Focus). Space borrows midnight's phase-offset
    slap/double idea and swaps the spring for a soft acoustic room.
*/
class JJMoonDSPKernel
{
public:
    void initialize(int inputChannelCount, int outputChannelCount, double inSampleRate)
    {
        mSampleRate = inSampleRate;
        mInputChannelCount = inputChannelCount;
        mOutputChannelCount = outputChannelCount;

        curveL.prepare(inSampleRate);
        curveR.prepare(inSampleRate);
        compressor.prepare(inSampleRate);

        leftVoice.prepare(inSampleRate);
        rightVoice.prepare(inSampleRate);
        leftVoice.delay.setLfoStartPhase(0.0f);
        rightVoice.delay.setLfoStartPhase(0.5f);

        // Haas / flutter double — short, L/R out of phase like midnight slap.
        doubleL.prepare(inSampleRate);
        doubleR.prepare(inSampleRate);
        doubleL.lfoRateHz = 0.23f;
        doubleR.lfoRateHz = 0.29f;
        doubleL.lfoDepthMs = 0.28f;
        doubleR.lfoDepthMs = 0.28f;
        doubleL.setLfoStartPhase(0.0f);
        doubleR.setLfoStartPhase(0.5f);
        doubleL.setBaseDelayMs(22.0f);
        doubleR.setBaseDelayMs(31.0f);

        roomL.prepare(inSampleRate, 0.0f);
        roomR.prepare(inSampleRate, 0.55f);

        updateFocusCrossover(mWidthFocus);
        mInitialized = true;
    }

    void deInitialize()
    {
        curveL.reset();
        curveR.reset();
        compressor.reset();
        leftVoice.reset();
        rightVoice.reset();
        doubleL.reset();
        doubleR.reset();
        roomL.reset();
        roomR.reset();
        focusLpL.reset();
        focusLpR.reset();
        focusHpL.reset();
        focusHpR.reset();
        mInitialized = false;
    }

    bool isBypassed() const { return mBypassed; }
    void setBypass(bool shouldBypass) { mBypassed = shouldBypass; }

    bool isLicensed() const { return mLicensed; }
    void setLicensed(bool licensed) { mLicensed = licensed; }

    void setParameter(AUParameterAddress address, AUValue value)
    {
        switch (address)
        {
            case JJMoonParameterAddress::curveAmount:   mCurveAmount = value; break;
            case JJMoonParameterAddress::curveWood:     mCurveWood = value; break;
            case JJMoonParameterAddress::curvePresence: mCurvePresence = value; break;
            case JJMoonParameterAddress::curveOn:       mCurveOn = value; break;
            case JJMoonParameterAddress::compAmount:    mCompAmount = value; break;
            case JJMoonParameterAddress::compAttack:    mCompAttack = value; break;
            case JJMoonParameterAddress::compRelease:   mCompRelease = value; break;
            case JJMoonParameterAddress::compOn:        mCompOn = value; break;
            case JJMoonParameterAddress::widthAmount:   mWidthAmount = value; break;
            case JJMoonParameterAddress::widthFocus:
                mWidthFocus = value;
                if (mInitialized)
                    updateFocusCrossover(value);
                break;
            case JJMoonParameterAddress::widthOn:       mWidthOn = value; break;
            case JJMoonParameterAddress::spaceDouble:   mSpaceDouble = value; break;
            case JJMoonParameterAddress::spaceSize:     mSpaceSize = value; break;
            case JJMoonParameterAddress::spaceMix:      mSpaceMix = value; break;
            case JJMoonParameterAddress::spaceOn:       mSpaceOn = value; break;
            case JJMoonParameterAddress::masterMix:     mMasterMix = value; break;
            case JJMoonParameterAddress::masterOutput:  mMasterOutput = value; break;
            case JJMoonParameterAddress::masterInput:   mMasterInput = value; break;
            default: break;
        }
    }

    AUValue getParameter(AUParameterAddress address)
    {
        switch (address)
        {
            case JJMoonParameterAddress::curveAmount:   return mCurveAmount;
            case JJMoonParameterAddress::curveWood:     return mCurveWood;
            case JJMoonParameterAddress::curvePresence: return mCurvePresence;
            case JJMoonParameterAddress::curveOn:       return mCurveOn;
            case JJMoonParameterAddress::compAmount:    return mCompAmount;
            case JJMoonParameterAddress::compAttack:    return mCompAttack;
            case JJMoonParameterAddress::compRelease:   return mCompRelease;
            case JJMoonParameterAddress::compOn:        return mCompOn;
            case JJMoonParameterAddress::widthAmount:   return mWidthAmount;
            case JJMoonParameterAddress::widthFocus:    return mWidthFocus;
            case JJMoonParameterAddress::widthOn:       return mWidthOn;
            case JJMoonParameterAddress::spaceDouble:   return mSpaceDouble;
            case JJMoonParameterAddress::spaceSize:     return mSpaceSize;
            case JJMoonParameterAddress::spaceMix:      return mSpaceMix;
            case JJMoonParameterAddress::spaceOn:       return mSpaceOn;
            case JJMoonParameterAddress::masterMix:     return mMasterMix;
            case JJMoonParameterAddress::masterOutput:  return mMasterOutput;
            case JJMoonParameterAddress::masterInput:   return mMasterInput;
            default: return 0.f;
        }
    }

    AUAudioFrameCount maximumFramesToRender() const { return mMaxFramesToRender; }
    void setMaximumFramesToRender(const AUAudioFrameCount& maxFrames) { mMaxFramesToRender = maxFrames; }

    void setMusicalContextBlock(AUHostMusicalContextBlock contextBlock)
    {
        mMusicalContextBlock = contextBlock;
    }

    void process(std::span<float const*> inputBuffers,
                 std::span<float*> outputBuffers,
                 AUEventSampleTime,
                 AUAudioFrameCount frameCount)
    {
        if (! mInitialized || inputBuffers.empty() || outputBuffers.empty())
            return;

        if (mBypassed || ! mLicensed)
        {
            float peak = 0.f;
            float channelPeak[2] = { 0.f, 0.f };
            for (size_t channel = 0; channel < outputBuffers.size(); ++channel)
            {
                const float* src = inputBuffers[std::min(channel, inputBuffers.size() - 1)];
                std::copy_n(src, frameCount, outputBuffers[channel]);
                float thisChannel = 0.f;
                for (AUAudioFrameCount n = 0; n < frameCount; ++n)
                    thisChannel = std::max(thisChannel, std::abs(src[n]));
                peak = std::max(peak, thisChannel);
                if (channel < 2)
                    channelPeak[channel] = thisChannel;
            }
            if (outputBuffers.size() == 1)
                channelPeak[1] = channelPeak[0];
            capturePeaks(peak, channelPeak[0], channelPeak[1]);
            mGainReductionDb = 0.f;
            return;
        }

        FlushDenormals denormals;

        const bool curveIsOn = mCurveOn > 0.5f;
        const bool compIsOn  = mCompOn > 0.5f;
        const bool widthIsOn = mWidthOn > 0.5f;
        const bool spaceIsOn = mSpaceOn > 0.5f;

        const float compNorm = std::clamp(mCompAmount, 0.0f, 100.0f) * 0.01f;
        const float threshDb = -2.0f - compNorm * 26.0f;
        const float ratio    = 1.8f + compNorm * 2.2f;
        const float makeupDb = std::max(0.0f, (-12.0f - threshDb)) * (1.0f - 1.0f / ratio) * 0.8f;
        compressor.setThresholdDb(threshDb);
        compressor.setRatio(ratio);
        compressor.setMakeupDb(makeupDb);
        compressor.setAttackMs(mCompAttack);
        compressor.setReleaseMs(mCompRelease);

        curveL.setAmount(curveIsOn ? mCurveAmount * 0.01f : 0.0f);
        curveR.setAmount(curveIsOn ? mCurveAmount * 0.01f : 0.0f);
        curveL.setWood(mCurveWood * 0.01f);
        curveR.setWood(mCurveWood * 0.01f);
        curveL.setPresence(mCurvePresence * 0.01f);
        curveR.setPresence(mCurvePresence * 0.01f);

        const float w = std::clamp(mWidthAmount, 0.0f, 100.0f) * 0.01f;
        const float cents = w * 10.0f;
        const float delayLMs = 9.0f + w * 10.0f;
        const float delayRMs = 15.0f + w * 14.0f;
        const float widthMix = widthIsOn ? w * 0.32f : 0.0f;
        leftVoice.pitch.setShiftCents(-cents);
        rightVoice.pitch.setShiftCents(+cents);
        leftVoice.delay.setBaseDelayMs(delayLMs);
        rightVoice.delay.setBaseDelayMs(delayRMs);

        roomL.setSize(mSpaceSize * 0.01f);
        roomR.setSize(mSpaceSize * 0.01f);
        roomL.setMix(spaceIsOn ? mSpaceMix * 0.01f : 0.0f);
        roomR.setMix(spaceIsOn ? mSpaceMix * 0.01f : 0.0f);

        const float doubleMix = spaceIsOn ? mSpaceDouble * 0.01f : 0.0f;
        const float inputGain  = std::pow(10.0f, mMasterInput / 20.0f);
        const float outputGain = std::pow(10.0f, mMasterOutput / 20.0f);
        const float masterMix  = std::clamp(mMasterMix, 0.0f, 100.0f) * 0.01f;

        float* outL = outputBuffers[0];
        float* outR = outputBuffers.size() > 1 ? outputBuffers[1] : outputBuffers[0];
        const float* inL = inputBuffers[0];
        const float* inR = inputBuffers.size() > 1 ? inputBuffers[1] : inputBuffers[0];

        float peakIn = 0.f;
        float peakOutL = 0.f;
        float peakOutR = 0.f;

        for (AUAudioFrameCount n = 0; n < frameCount; ++n)
        {
            const float dryL = inL[n] * inputGain;
            const float dryR = inR[n] * inputGain;
            peakIn = std::max(peakIn, std::max(std::abs(dryL), std::abs(dryR)));

            float wetL = dryL;
            float wetR = dryR;

            wetL = curveL.processSample(wetL);
            wetR = curveR.processSample(wetR);

            if (compIsOn)
            {
                const float detect = std::max(std::abs(wetL), std::abs(wetR));
                const float g = compressor.nextGain(detect);
                wetL *= g;
                wetR *= g;
            }

            if (widthMix > 1.0e-4f)
            {
                const float lowL = focusLpL.processSample(wetL);
                const float lowR = focusLpR.processSample(wetR);
                float highL = focusHpL.processSample(wetL);
                float highR = focusHpR.processSample(wetR);

                highL = leftVoice.pitch.processSample(highL);
                highR = rightVoice.pitch.processSample(highR);
                highL = leftVoice.delay.processSample(highL);
                highR = rightVoice.delay.processSample(highR);

                const float wideL = lowL + highL;
                const float wideR = lowR + highR;
                wetL = wetL * (1.0f - widthMix) + wideL * widthMix;
                wetR = wetR * (1.0f - widthMix) + wideR * widthMix;
            }

            if (spaceIsOn)
            {
                if (doubleMix > 1.0e-4f)
                {
                    const float dL = doubleL.processSample(wetL);
                    const float dR = doubleR.processSample(wetR);
                    wetL = wetL + doubleMix * (dL * 0.65f + dR * 0.35f);
                    wetR = wetR + doubleMix * (dR * 0.65f + dL * 0.35f);
                }
                wetL = roomL.processSample(wetL);
                wetR = roomR.processSample(wetR);
            }

            const float outSampleL = (dryL + masterMix * (wetL - dryL)) * outputGain;
            const float outSampleR = (dryR + masterMix * (wetR - dryR)) * outputGain;
            outL[n] = outSampleL;
            outR[n] = outSampleR;
            peakOutL = std::max(peakOutL, std::abs(outSampleL));
            peakOutR = std::max(peakOutR, std::abs(outSampleR));
        }

        mGainReductionDb = compIsOn ? compressor.currentGainReductionDb() : 0.f;
        capturePeaks(peakIn, peakOutL, peakOutR);
    }

    void readInputPeak(float* peak)
    {
        if (peak)
        {
            *peak = mPeakInTrim;
            mPeakInTrim = 0.f;
        }
    }

    void readOutputPeaks(float* leftPeak, float* rightPeak)
    {
        if (leftPeak)
        {
            *leftPeak = mPeakOutL;
            mPeakOutL = 0.f;
        }
        if (rightPeak)
        {
            *rightPeak = mPeakOutR;
            mPeakOutR = 0.f;
        }
    }

    void readPeaks(float* inPeak, float* outPeak)
    {
        if (inPeak)
        {
            *inPeak = mPeakIn;
            mPeakIn = 0.f;
        }
        if (outPeak)
        {
            *outPeak = mPeakOut;
            mPeakOut = 0.f;
        }
    }

    float gainReductionDb() const { return mGainReductionDb; }

    void handleOneEvent(AUEventSampleTime now, AURenderEvent const* event)
    {
        switch (event->head.eventType)
        {
            case AURenderEventParameter:
                handleParameterEvent(now, event->parameter);
                break;
            default:
                break;
        }
    }

    void handleParameterEvent(AUEventSampleTime, AUParameterEvent const& parameterEvent)
    {
        setParameter(parameterEvent.parameterAddress, parameterEvent.value);
    }

private:
    struct Voice
    {
        PitchShifter pitch;
        ModulatedDelay delay;

        void prepare(double sr)
        {
            pitch.prepare(sr, 40.0f);
            delay.prepare(sr);
            delay.lfoRateHz = 0.22f;
            delay.lfoDepthMs = 0.4f;
        }

        void reset()
        {
            pitch.reset();
            delay.reset();
        }
    };

    void updateFocusCrossover(float hz)
    {
        const float f = std::clamp(hz, 80.0f, 2000.0f);
        focusLpL.setFromArray(Biquad::makeLowPass(mSampleRate, f, 0.707f));
        focusLpR.setFromArray(Biquad::makeLowPass(mSampleRate, f, 0.707f));
        focusHpL.setFromArray(Biquad::makeHighPass(mSampleRate, f, 0.707f));
        focusHpR.setFromArray(Biquad::makeHighPass(mSampleRate, f, 0.707f));
    }

    void capturePeaks(float inPeak, float outPeakL, float outPeakR)
    {
        if (inPeak > mPeakIn)
            mPeakIn = inPeak;
        if (inPeak > mPeakInTrim)
            mPeakInTrim = inPeak;
        const float outPeak = std::max(outPeakL, outPeakR);
        if (outPeak > mPeakOut)
            mPeakOut = outPeak;
        if (outPeakL > mPeakOutL)
            mPeakOutL = outPeakL;
        if (outPeakR > mPeakOutR)
            mPeakOutR = outPeakR;
    }

    AcousticCurve curveL, curveR;
    CompressorStage compressor;
    Voice leftVoice, rightVoice;
    ModulatedDelay doubleL, doubleR;
    RoomBloom roomL, roomR;
    Biquad focusLpL, focusLpR, focusHpL, focusHpR;

    AUHostMusicalContextBlock mMusicalContextBlock;

    double mSampleRate = 44100.0;
    int mInputChannelCount = 2;
    int mOutputChannelCount = 2;
    bool mBypassed = false;
    bool mLicensed = false;
    bool mInitialized = false;
    AUAudioFrameCount mMaxFramesToRender = 1024;

    float mCurveAmount = 68.0f;
    float mCurveWood = 55.0f;
    float mCurvePresence = 42.0f;
    float mCurveOn = 1.0f;

    float mCompAmount = 48.0f;
    float mCompAttack = 32.0f;
    float mCompRelease = 160.0f;
    float mCompOn = 1.0f;

    float mWidthAmount = 35.0f;
    float mWidthFocus = 220.0f;
    float mWidthOn = 1.0f;

    float mSpaceDouble = 18.0f;
    float mSpaceSize = 40.0f;
    float mSpaceMix = 16.0f;
    float mSpaceOn = 1.0f;

    float mMasterMix = 100.0f;
    float mMasterOutput = 0.0f;
    float mMasterInput = 0.0f;

    float mPeakIn = 0.f;
    float mPeakInTrim = 0.f;
    float mPeakOut = 0.f;
    float mPeakOutL = 0.f;
    float mPeakOutR = 0.f;
    float mGainReductionDb = 0.f;
};
