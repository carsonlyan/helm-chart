#include "AnimationUtility.h"
#include <Utilities/ServiceCache.h>

#include <msc/apex/ddm/SCAIDisplay3DDataManager.h>


namespace msc { namespace adams { namespace plugin { namespace AdamsView {

using namespace SCA;
using namespace msc::apex::appfw;
using namespace msc::apex::ddm;

struct ColorHSLFloat
{
    float h;
    float s;
    float l;
};

// Constructor

AnimationUtility::AnimationUtility()
{
}

// Destructor
AnimationUtility::~AnimationUtility()
{
}

void AnimationUtility::getOffsetMagnitudes(const SCAFloat3DPointSequence& offsets, SCAFloatSequence& magnitudes, SCAFloat* maxOffset)
{
    magnitudes.resize(offsets.size());
    SCAReal32* buf = magnitudes.w_address();

    size_t i = 0;
    for (const SCAFloat3DPoint& vec : offsets)
    {
        SCAFloat val = (SCAFloat)sqrt(vec.x * vec.x + vec.y * vec.y + vec.z *vec.z);
        buf[i++] = val;

        if (maxOffset && *maxOffset < val)
        {
            *maxOffset = val;
        }
    }
}

float hslComponentCalc(const float tc, const float p, const float q)
{
    float result = tc;

    // compare float value literally regardless tolerance
    if (tc < 0.0f)
        result = tc + 1.0f;
    else if (tc > 1.0f)
        result = tc - 1.0f;

    const float sixth = 1.0f / 6.0f;
    const float twoThird = 2.0f / 3.0f;

    if (result < sixth)
        result = p + (q - p) * 6.0f * result;
    else if (result >= sixth && result < 0.5f)
        result = q;
    else if (result >= 0.5f && result < twoThird)
        result = p + (q - p) * 6.0f * (twoThird - result);
    else
        result = p;

    return result;
}

ColorRGBFloat hsl2rbg(const ColorHSLFloat& hsl)
{
    if (hsl.h < 0.0f || hsl.h > 1.0f || hsl.s < 0.0f || hsl.s > 1.0f || hsl.l < 0.0f || hsl.l > 1.0f)
        return ColorRGBFloat({ 0, 0, 0 });

    const float oneThird = 1.0f / 3.0f;

    float q = hsl.l < 0.5f ? hsl.l * (1.0f + hsl.s) : hsl.l + hsl.s - hsl.l * hsl.s;
    float p = 2 * hsl.l - q;

    float tr = hsl.h + oneThird;
    float tg = hsl.h;
    float tb = hsl.h - oneThird;

    ColorRGBFloat rgb;
    rgb.red = hslComponentCalc(tr, p, q);
    rgb.green = hslComponentCalc(tg, p, q);
    rgb.blue = hslComponentCalc(tb, p, q);

    return rgb;
}

ColorHSLFloat rgb2hsl(const ColorRGBFloat& rgb)
{
    ColorHSLFloat hsl = { 0, 0, 0 };
    float max = rgb.red > rgb.green ? (rgb.red > rgb.blue ? rgb.red : rgb.blue) : (rgb.green > rgb.blue ? rgb.green : rgb.blue);
    float min = rgb.red < rgb.green ? (rgb.red < rgb.blue ? rgb.red : rgb.blue) : (rgb.green < rgb.blue ? rgb.green : rgb.blue);

    hsl.h = hsl.s = hsl.l = (max + min) * 0.5f;

    // compare float value literally regardless tolerance
    if (max == min)
    {
        hsl.s = hsl.h = 0.0f;
    }
    else
    {
        float delta = max - min;
        hsl.s = hsl.l > 0.5f ? (2.0f - max - min) : delta / (max + min);

        if (max == rgb.red)
        {
            hsl.h = (rgb.green - rgb.blue) / delta + (rgb.green < rgb.blue ? 6.0f : 0.0f);
        }
        else if (max == rgb.green)
        {
            hsl.h = (rgb.blue - rgb.red) / delta + 2.0f;
        }
        else if (max == rgb.blue)
        {
            hsl.h = (rgb.red - rgb.green) / delta + 4.0f;
        }

        hsl.h /= 6.0f;
    }

    return hsl;
}

ColorRGBFloat AnimationUtility::getInterpolatedColor(const ColorRGBFloat& start, const ColorRGBFloat& end, const float interpPos)
{
    if (interpPos < 0.0f)
    {
        return start;
    }
    else if (interpPos > 1.0f)
    {
        return end;
    }

    ColorHSLFloat startHSL = rgb2hsl(start);
    ColorHSLFloat endHSL = rgb2hsl(end);
    ColorHSLFloat interHSL;
    interHSL.h = startHSL.h + (endHSL.h - startHSL.h) * interpPos;
    interHSL.s = startHSL.s + (endHSL.s - startHSL.s) * interpPos;
    interHSL.l = startHSL.l + (endHSL.l - startHSL.l) * interpPos;

    return hsl2rbg(interHSL);
}

void AnimationUtility::createColorMapping(const float min, const float max, const int ranges, ColorMappingSequence &colorMapSeq)
{
    if ((max - min) < 0.001 || ranges <= 0)
        return;

    const ColorRGBFloat red { 1.0f, 0.0f, 0.0f };
    const ColorRGBFloat blue{ 0.0f, 0.0f, 1.0f };

    float delta = (max - min) / (float)ranges;

    colorMapSeq.clear();
    colorMapSeq.reserve(ranges);
    for (size_t i = 0; i < ranges; i++)
    {
        float rangeStart = min + delta * i;
        float rangeEnd = min + delta * (i + 1);

        ColorMappingItem colorItem;
        DisplayDataRangeFloat valRange{ rangeStart, rangeEnd };
        colorItem.valRange = valRange;

        ColorRGBFloat start = getInterpolatedColor(blue, red, rangeStart);
        ColorRGBFloat end = getInterpolatedColor(blue, red, rangeEnd);

        DisplayColorRGBRangeFloat clrRange{ start, end };
        colorItem.clrRange = clrRange;

        colorMapSeq.push_back(colorItem);
    }
}

SCA::SCAResult AnimationUtility::createColorDataMapAdapter(const ColorMappingSequence &colorMaps, SCAIColorDataMapAdapter& spDataColorMapAdapter)
{
    msc::apex::ddm::SCAIDisplay3DDataManager spDDM = ServiceCache::instance().getDisplayDataManager();
    if (spDDM == NULLSP)
        return SCAError;

    ColorRGBFloat belowColor{ 0.0f, 0.0f, 1.0f };
    ColorRGBFloat aboveColor{ 1.0f, 0.0f, 0.0f };
    ColorRGBFloat outofColor{ 1.0f, 1.0f, 1.0f };

    return spDDM->createColorDataMapAdapter(
            colorMaps, 
            belowColor, aboveColor, outofColor,
            DISPLAY_COLOR_INTERPOLATION_LINEAR,
            spDataColorMapAdapter);
}

} } } }
