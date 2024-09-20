//Rough CRT beam shader
//Made for Godot

shader_type canvas_item;

//Use a sinc-ish filter for horizontal lines
//const float filtpoint1 = 0.8382770402;
const float filtpoint2 = 1.67655408;
//const float filtpoint3 = 2.514831121;
const float filtpoint4 = 3.353108161;
const float filtpoint5 = 4.191385201;
const float filtpoint6 = 5.711714990;
const float filtpoint7 = 7.232044778;
//const float filtval1 =  0.862345766296;
const float filtval2 =  0.530053838817;
//const float filtval3 =  0.181097299300;
const float filtval4 = -0.0399332614833;
const float filtval5 = -0.102480066586;
const float filtval6 = -0.0256799583456;
const float filtval7 =  0.0138710617836;

//const float filtval01 = 1.0/(1.0 + 2.0 * filtval1 + 2.0 * filtval2 + 2.0 * filtval3 + 2.0 * filtval4 + filtval5 + filtval6 + filtval7);
//const float filtval02 = 1.0/(1.0 + 2.0 * filtval1 + 2.0 * filtval2 + 2.0 * filtval3 + 2.0 * filtval4 + filtval5 + filtval6 + filtval7);
//const float filtval03 = 1.0/(1.0 + 2.0 * filtval1 + 2.0 * filtval2 + 2.0 * filtval3 + 2.0 * filtval4 + filtval5 + filtval6 + filtval7);

const float filtval01 = 1.0/(1.0 + 2.0 * filtval2 + 2.0 * filtval4 + filtval5 + filtval6 + filtval7);
const float filtval02 = 1.0/(1.0 + 2.0 * filtval2 + 2.0 * filtval4 + filtval5 + filtval6 + filtval7);
const float filtval03 = 1.0/(1.0 + 2.0 * filtval2 + 2.0 * filtval4 + filtval5 + filtval6 + filtval7);

const vec3 beamShapePower = vec3(0.333333333333333333333333333);

uniform sampler2D iChannel0 : hint_screen_texture, repeat_disable, filter_nearest;

vec4 lineSample(vec2 fragCoord, vec2 iResolution, float downsamp, float samplewidth, float maxsig, float minsig)
{
	//Sample from the middle of a line to simulate actual scanline behaviour
	vec2 fragCoordNorm1 = vec2(fragCoord.x, floor(fragCoord.y/downsamp) * downsamp + 0.5 * downsamp);
	vec2 fragCoordNorm2 = vec2(fragCoord.x, floor((fragCoord.y/downsamp) + 1.0) * downsamp + 0.5 * downsamp);
	vec2 fragCoordNorm3 = vec2(fragCoord.x, floor((fragCoord.y/downsamp) - 1.0) * downsamp + 0.5 * downsamp);
	//Sample points
	//float adjFiltpoint1 = filtpoint1 * samplewidth;
	float adjFiltpoint2 = filtpoint2 * samplewidth;
	//float adjFiltpoint3 = filtpoint3 * samplewidth;
	float adjFiltpoint4 = filtpoint4 * samplewidth;
	float adjFiltpoint5 = filtpoint5 * samplewidth;
	float adjFiltpoint6 = filtpoint6 * samplewidth;
	float adjFiltpoint7 = filtpoint7 * samplewidth;
	vec2 uv1m7 = vec2(fragCoordNorm1.x - adjFiltpoint7, fragCoordNorm1.y)/iResolution.xy;
    vec2 uv1m6 = vec2(fragCoordNorm1.x - adjFiltpoint6, fragCoordNorm1.y)/iResolution.xy;
    vec2 uv1m5 = vec2(fragCoordNorm1.x - adjFiltpoint5, fragCoordNorm1.y)/iResolution.xy;
    vec2 uv1m4 = vec2(fragCoordNorm1.x - adjFiltpoint4, fragCoordNorm1.y)/iResolution.xy;
    //vec2 uv1m3 = vec2(fragCoordNorm1.x - adjFiltpoint3, fragCoordNorm1.y)/iResolution.xy;
    vec2 uv1m2 = vec2(fragCoordNorm1.x - adjFiltpoint2, fragCoordNorm1.y)/iResolution.xy;
    //vec2 uv1m1 = vec2(fragCoordNorm1.x - adjFiltpoint1, fragCoordNorm1.y)/iResolution.xy;
    vec2 uv1c  = fragCoordNorm1/iResolution.xy;
    //vec2 uv1p1 = vec2(fragCoordNorm1.x + adjFiltpoint1, fragCoordNorm1.y)/iResolution.xy;
    vec2 uv1p2 = vec2(fragCoordNorm1.x + adjFiltpoint2, fragCoordNorm1.y)/iResolution.xy;
    //vec2 uv1p3 = vec2(fragCoordNorm1.x + adjFiltpoint3, fragCoordNorm1.y)/iResolution.xy;
    vec2 uv1p4 = vec2(fragCoordNorm1.x + adjFiltpoint4, fragCoordNorm1.y)/iResolution.xy;
    vec2 uv2m7 = vec2(fragCoordNorm2.x - adjFiltpoint7, fragCoordNorm2.y)/iResolution.xy;
    vec2 uv2m6 = vec2(fragCoordNorm2.x - adjFiltpoint6, fragCoordNorm2.y)/iResolution.xy;
    vec2 uv2m5 = vec2(fragCoordNorm2.x - adjFiltpoint5, fragCoordNorm2.y)/iResolution.xy;
    vec2 uv2m4 = vec2(fragCoordNorm2.x - adjFiltpoint4, fragCoordNorm2.y)/iResolution.xy;
    //vec2 uv2m3 = vec2(fragCoordNorm2.x - adjFiltpoint3, fragCoordNorm2.y)/iResolution.xy;
    vec2 uv2m2 = vec2(fragCoordNorm2.x - adjFiltpoint2, fragCoordNorm2.y)/iResolution.xy;
    //vec2 uv2m1 = vec2(fragCoordNorm2.x - adjFiltpoint1, fragCoordNorm2.y)/iResolution.xy;
    vec2 uv2c  = vec2(fragCoordNorm2.x, fragCoordNorm2.y)/iResolution.xy;
    //vec2 uv2p1 = vec2(fragCoordNorm2.x + adjFiltpoint1, fragCoordNorm2.y)/iResolution.xy;
    vec2 uv2p2 = vec2(fragCoordNorm2.x + adjFiltpoint2, fragCoordNorm2.y)/iResolution.xy;
    //vec2 uv2p3 = vec2(fragCoordNorm2.x + adjFiltpoint3, fragCoordNorm2.y)/iResolution.xy;
    vec2 uv2p4 = vec2(fragCoordNorm2.x + adjFiltpoint4, fragCoordNorm2.y)/iResolution.xy;
    vec2 uv3m7 = vec2(fragCoordNorm3.x - adjFiltpoint7, fragCoordNorm3.y)/iResolution.xy;
    vec2 uv3m6 = vec2(fragCoordNorm3.x - adjFiltpoint6, fragCoordNorm3.y)/iResolution.xy;
    vec2 uv3m5 = vec2(fragCoordNorm3.x - adjFiltpoint5, fragCoordNorm3.y)/iResolution.xy;
    vec2 uv3m4 = vec2(fragCoordNorm3.x - adjFiltpoint4, fragCoordNorm3.y)/iResolution.xy;
    //vec2 uv3m3 = vec2(fragCoordNorm3.x - adjFiltpoint3, fragCoordNorm3.y)/iResolution.xy;
    vec2 uv3m2 = vec2(fragCoordNorm3.x - adjFiltpoint2, fragCoordNorm3.y)/iResolution.xy;
    //vec2 uv3m1 = vec2(fragCoordNorm3.x - adjFiltpoint1, fragCoordNorm3.y)/iResolution.xy;
    vec2 uv3c  = vec2(fragCoordNorm3.x, fragCoordNorm3.y)/iResolution.xy;
    //vec2 uv3p1 = vec2(fragCoordNorm3.x + adjFiltpoint1, fragCoordNorm3.y)/iResolution.xy;
    vec2 uv3p2 = vec2(fragCoordNorm3.x + adjFiltpoint2, fragCoordNorm3.y)/iResolution.xy;
    //vec2 uv3p3 = vec2(fragCoordNorm3.x + adjFiltpoint3, fragCoordNorm3.y)/iResolution.xy;
    vec2 uv3p4 = vec2(fragCoordNorm3.x + adjFiltpoint4, fragCoordNorm3.y)/iResolution.xy;
	//Filter, and sample from the current scanline and the nearest neighbours
	vec4 sample1 = (texture(iChannel0, uv1c)
    + texture(iChannel0, uv1m7) * filtval7
    + texture(iChannel0, uv1m6) * filtval6
    + texture(iChannel0, uv1m5) * filtval5
    + texture(iChannel0, uv1m4) * filtval4
    //+ texture(iChannel0, uv1m3) * filtval3
    + texture(iChannel0, uv1m2) * filtval2
    //+ texture(iChannel0, uv1m1) * filtval1
    //+ texture(iChannel0, uv1p1) * filtval1
    + texture(iChannel0, uv1p2) * filtval2
    //+ texture(iChannel0, uv1p3) * filtval3
    + texture(iChannel0, uv1p4) * filtval4) * filtval01;
    vec4 sample2 = (texture(iChannel0, uv2c)
    + texture(iChannel0, uv2m7) * filtval7
    + texture(iChannel0, uv2m6) * filtval6
    + texture(iChannel0, uv2m5) * filtval5
    + texture(iChannel0, uv2m4) * filtval4
    //+ texture(iChannel0, uv2m3) * filtval3
    + texture(iChannel0, uv2m2) * filtval2
    //+ texture(iChannel0, uv2m1) * filtval1
    //+ texture(iChannel0, uv2p1) * filtval1
    + texture(iChannel0, uv2p2) * filtval2
    //+ texture(iChannel0, uv2p3) * filtval3
    + texture(iChannel0, uv2p4) * filtval4) * filtval02;
    vec4 sample3 = (texture(iChannel0, uv3c)
    + texture(iChannel0, uv3m7) * filtval7
    + texture(iChannel0, uv3m6) * filtval6
    + texture(iChannel0, uv3m5) * filtval5
    + texture(iChannel0, uv3m4) * filtval4
    //+ texture(iChannel0, uv3m3) * filtval3
    + texture(iChannel0, uv3m2) * filtval2
    //+ texture(iChannel0, uv3m1) * filtval1
    //+ texture(iChannel0, uv3p1) * filtval1
    + texture(iChannel0, uv3p2) * filtval2
    //+ texture(iChannel0, uv3p3) * filtval3
    + texture(iChannel0, uv3p4) * filtval4) * filtval03;
	//Simulate beam-phosphor glow characteristics
	vec3 widthFac1 = mix(vec3(maxsig), vec3(minsig), sign(sample1.rgb) * pow(abs(sample1.rgb), beamShapePower));
	vec3 widthFac2 = mix(vec3(maxsig), vec3(minsig), sign(sample2.rgb) * pow(abs(sample2.rgb), beamShapePower));
	vec3 widthFac3 = mix(vec3(maxsig), vec3(minsig), sign(sample3.rgb) * pow(abs(sample3.rgb), beamShapePower));
	vec3 linefac1 = vec3(mod(fragCoord.y, downsamp) - 0.5 * downsamp);
	vec3 linefac2 = linefac1 - downsamp;
	vec3 linefac3 = linefac1 + downsamp;
	linefac1 *= widthFac1; linefac2 *= widthFac2; linefac3 *= widthFac3;
	vec3 line1gauss = pow(vec3(2.0), -linefac1 * linefac1);
	vec3 line2gauss = pow(vec3(2.0), -linefac2 * linefac2);
	vec3 line3gauss = pow(vec3(2.0), -linefac3 * linefac3);
	vec3 finalCol = sample1.rgb * line1gauss + sample2.rgb * line2gauss + sample3.rgb * line3gauss;
	return vec4(finalCol, 1.0);
}

void fragment()
{
	vec2 iResolution = 1.0/SCREEN_PIXEL_SIZE;
	//Some constants that depend on the size of the output screen
	float downsamp = iResolution.y/240.0;
	float minsig = 2.0/downsamp;
	float maxsig = 6.0/downsamp;
	float samplewidth = iResolution.x/800.0;
	vec4 outcol = lineSample(FRAGCOORD.xy, iResolution, downsamp, samplewidth, maxsig, minsig);
	COLOR = outcol;
	COLOR.a = 1.0;
}