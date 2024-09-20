//Rough CRT beam shader
//Made for Godot

shader_type canvas_item;

uniform sampler2D screenTex : hint_screen_texture, repeat_disable, filter_nearest;

const float minSigFac = 0.16;
const float maxSigFac = 0.55;
const float brightAdjust = 0.22;
const float gamAdjust = 0.45;

const float fCoordOffsets1[7] = { -1.0, -0.6, -0.3, 0.0, 0.3, 0.6, 1.0 };
const float fCoordOffsets2[3] = { -0.5, 0.0, 0.5 };

const vec3 gaussA = vec3(0.384900179459751);
const vec3 gaussB = vec3(0.813576548617);
const vec3 gaussC = vec3(2.12893402956);
const vec3 v31 = vec3(1.0);
vec3 GaussianApprox(in vec3 x)
{
    vec3 vx = clamp(x, -gaussC, gaussC);
    vx *= gaussB;
    return v31 - vx * vx * (v31 - gaussA * abs(vx));
}

vec3 SampleBeam(vec2 sampCoord, vec2 origCoord, vec4 screenDim, float maxsig, float minsig)
{
    //Sample from the screen
    vec4 sample1 = texture(screenTex, sampCoord * screenDim.zw);

    //Simulate beam-phosphor glow characteristics
    vec3 widthFac = mix(vec3(maxsig), vec3(minsig), sqrt(max(sample1.rgb, vec3(0.0))));
    vec3 linefac = distance(origCoord, sampCoord) * widthFac;
    vec3 linegauss = GaussianApprox(linefac);
    return sample1.rgb * linegauss;
}

void fragment()
{
    vec2 fragCoord = FRAGCOORD.xy;
	vec4 screenDim;
	screenDim.xy = vec2(textureSize(screenTex, 0)); 
	screenDim.zw = vec2(1.0)/screenDim.xy;
    //Some constants that depend on the size of the output screen
    float downsamp = screenDim.y / 240.0;
    float minsig = (1.0/maxSigFac)/downsamp;
    float maxsig = (1.0/minSigFac)/downsamp;
    float samplewidth = screenDim.x / 460.8;
    //Sample from the middle of a line to simulate actual scanline behaviour
    vec2 fragCoordNorm1 = vec2(fragCoord.x, (floor(fragCoord.y/downsamp) + 0.5) * downsamp);
    vec2 fragCoordNorm2;
    if (mod(fragCoord.y, downsamp)/downsamp < 0.5) fragCoordNorm2 = vec2(fragCoord.x, (floor(fragCoord.y/downsamp) - 0.5) * downsamp);
    else fragCoordNorm2 = vec2(fragCoord.x, (floor(fragCoord.y/downsamp) + 1.5) * downsamp);
    vec3 finalColour = vec3(0.0);
    for (int i = 0; i < 7; i++)
    {
        finalColour += SampleBeam(fragCoordNorm1 + vec2(samplewidth * fCoordOffsets1[i], 0.0), fragCoord, screenDim, maxsig, minsig);
    }
    for (int i = 0; i < 3; i++)
    {
        finalColour += SampleBeam(fragCoordNorm2 + vec2(samplewidth * fCoordOffsets2[i], 0.0), fragCoord, screenDim, maxsig, minsig);
    }
    COLOR = vec4(pow(finalColour * brightAdjust, vec3(gamAdjust)), 1.0);
}
