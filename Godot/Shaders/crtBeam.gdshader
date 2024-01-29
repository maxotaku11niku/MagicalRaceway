//Rough CRT beam shader
//Made for Godot

shader_type canvas_item;

const vec3 Yvec = vec3(0.299, 0.587, 0.114);
//Use a sinc-ish filter for horizontal lines
const float filtpoint1 = 2.095692601;
const float filtpoint2 = 4.191385201;
const float filtval1 =  0.346402991874;
const float filtval2 = -0.102480066586;
const float filtval01 = 1.0/(1.0 + 2.0 * filtval1 + filtval2);
const float filtval02 = 1.0/(1.0 + filtval2);
const float filtval11 = filtval1 * filtval01;
const float filtval21 = filtval2 * filtval01;
const float filtval22 = filtval2 * filtval02;

const float beamShapePower = 1.5;

uniform sampler2D iChannel0 : hint_screen_texture, repeat_disable, filter_nearest;

vec4 lineSample(vec2 fragCoord, vec2 iResolution, float downsamp, float samplewidth, float maxsig, float minsig)
{
	//Sample from the middle of a line to simulate actual scanline behaviour
	vec2 fragCoordNorm1 = vec2(fragCoord.x, floor(fragCoord.y/downsamp) * downsamp + 0.5 * downsamp);
	vec2 fragCoordNorm2 = vec2(fragCoord.x, floor((fragCoord.y/downsamp) + 1.0) * downsamp + 0.5 * downsamp);
	vec2 fragCoordNorm3 = vec2(fragCoord.x, floor((fragCoord.y/downsamp) - 1.0) * downsamp + 0.5 * downsamp);
	//Sample points
	float adjFiltpoint1 = filtpoint1 * samplewidth;
	float adjFiltpoint2 = filtpoint2 * samplewidth;
	//Filter, and sample from the current scanline and the nearest neighbours
	vec2 uv13 = fragCoordNorm1/iResolution.xy;
	vec4 sample1 = texture(iChannel0, uv13) * filtval01;
	vec2 uv11 = vec2(fragCoordNorm1.x - adjFiltpoint2, fragCoordNorm1.y)/iResolution.xy;
	sample1 += texture(iChannel0, uv11) * filtval21;
	vec2 uv12 = vec2(fragCoordNorm1.x - adjFiltpoint1, fragCoordNorm1.y)/iResolution.xy;
	sample1 += texture(iChannel0, uv12) * filtval11;
	vec2 uv14 = vec2(fragCoordNorm1.x + adjFiltpoint1, fragCoordNorm1.y)/iResolution.xy;
	sample1 += texture(iChannel0, uv14) * filtval11;
	vec2 uv22 = vec2(fragCoordNorm2.x, fragCoordNorm2.y)/iResolution.xy;
	vec4 sample2 = texture(iChannel0, uv22) * filtval02;
	vec2 uv21 = vec2(fragCoordNorm2.x - adjFiltpoint2, fragCoordNorm2.y)/iResolution.xy;
	sample2 += texture(iChannel0, uv21) * filtval22;
	vec2 uv32 = vec2(fragCoordNorm3.x, fragCoordNorm3.y)/iResolution.xy;
	vec4 sample3 = texture(iChannel0, uv32) * filtval02;
	vec2 uv31 = vec2(fragCoordNorm3.x - adjFiltpoint2, fragCoordNorm3.y)/iResolution.xy;
	sample3 += texture(iChannel0, uv31) * filtval22;
	//Simulate beam-phosphor glow characteristics
	float Y1 = dot(Yvec, sample1.rgb);
	float Y2 = dot(Yvec, sample2.rgb);
	float Y3 = dot(Yvec, sample3.rgb);
	float widthFac1 = mix(maxsig, minsig, sign(Y1) * pow(abs(Y1), beamShapePower));
	float widthFac2 = mix(maxsig, minsig, sign(Y2) * pow(abs(Y2), beamShapePower));
	float widthFac3 = mix(maxsig, minsig, sign(Y3) * pow(abs(Y3), beamShapePower));
	float linefac1 = mod(fragCoord.y, downsamp) - 0.5 * downsamp;
	float linefac2 = linefac1 - downsamp;
	float linefac3 = linefac1 + downsamp;
	linefac1 *= widthFac1; linefac2 *= widthFac2; linefac3 *= widthFac3;
	float line1gauss = pow(2.0, -linefac1 * linefac1);
	float line2gauss = pow(2.0, -linefac2 * linefac2);
	float line3gauss = pow(2.0, -linefac3 * linefac3);
	return sample1 * line1gauss + sample2 * line2gauss + sample3 * line3gauss;
}

void fragment()
{
	vec2 iResolution = 1.0/SCREEN_PIXEL_SIZE;
	//Some constants that depend on the size of the output screen
	float downsamp = iResolution.y/240.0;
	float minsig = 2.0/downsamp;
	float maxsig = 4.0/downsamp;
	float samplewidth = iResolution.x/750.0;
	vec4 outcol = lineSample(FRAGCOORD.xy, iResolution, downsamp, samplewidth, maxsig, minsig);
	COLOR = outcol;
	COLOR.a = 1.0;
}