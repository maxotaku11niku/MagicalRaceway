//CRT mask shader (tv version)
//Made for Godot

shader_type canvas_item;

uniform sampler2D screenTex : hint_screen_texture, repeat_disable, filter_nearest;

const vec3 Yvec = vec3(0.299, 0.587, 0.114);
const vec2 halfvec = vec2(0.5);
const vec4 maskMix = vec4(0.3);

void fragment()
{
	vec2 screenDim = vec2(textureSize(screenTex, 0)); 
	vec2 guv = UV;
	vec2 ruv = guv + vec2(0.001, -0.0004);
	vec2 buv = guv + vec2(-0.0004, 0.0008);
	//Blooming, but requires some way of putting the scale factor in
	//float scalefac = 1.1 - 0.1 * dot(textureLod(TEXTURE, guv, -16.0).rgb, Yvec);
	//guv -= halfvec; ruv -= halfvec; buv -= halfvec;
	//guv *= scalefac; ruv *= scalefac; buv *= scalefac;
	//guv += halfvec; ruv += halfvec; buv += halfvec;
	vec4 col = texture(TEXTURE, guv);
	//Clipping, out of range areas are black
	if (guv.x > 1.0 || guv.y > 1.0 || guv.x < 0.0 || guv.y < 0.0)
	{
		col.g = 0.0;
	}
	if (ruv.x > 1.0 || ruv.y > 1.0 || ruv.x < 0.0 || ruv.y < 0.0)
	{
		col.r = 0.0;
	}
	else col.r = texture(TEXTURE, ruv).r;
	if (buv.x > 1.0 || buv.y > 1.0 || buv.x < 0.0 || buv.y < 0.0)
	{
		col.b = 0.0;
	}
	else col.b = texture(TEXTURE, buv).b;
	//If the output surface is big enough, do fine mask detail, else ignore fine detail because it won't look so good
    if (screenDim.y >= 720.0f && screenDim.x >= 960.0f)
    {
		//In reality the dark areas emit no light, but in practice
		//there would be light bloom anyway, so we do this
		//just to make the mask apparent without making the
		//screen way too dark
		vec4 dark = pow(col, vec4(1.8));
		vec4 origcol = col; //Copy for later mix
		vec4 light = pow(col, vec4(0.333333333333333333333333333333333333333333));
		//Mask doesn't scale with resolution, but in real
		//CRTs the phosphor mask isn't the main determinant
		//of resolution anyway, so it doesn't matter too much
		//if the mask becomes a little too fine
		//(though this wouldn't be ideal for very very high resolution screens)
		ivec2 fragcoord = ivec2(FRAGCOORD.xy);
		int maskcomp = fragcoord.x % 4;
		int stepbit = (fragcoord.x % 8)/4;
		int vertcomp = fragcoord.y;
		if (stepbit == 1) vertcomp += 2;
		vertcomp %= 4;
		int maskInd = maskcomp + vertcomp * 4;
		switch (maskInd)
		{
		    //Red phosphor
		    case 0:
		    case 4:
		    case 8:
		        col.r = light.r;
		        col.b = dark.b;
		        break;
		    //Green phosphor
		    case 1:
		    case 5:
		    case 9:
		        col.g = light.g;
		        break;
		    //Blue phosphor
		    case 2:
		    case 6:
		    case 10:
		        col.b = light.b;
		        col.r = dark.r;
		        break;
		    //Non-phospor areas
		    case 3:
		    case 11:
		        col.g = dark.g;
		        break;
		    case 7:
		    case 14:
		        col.r = dark.r;
		        col.g = dark.g;
		        break;
		    case 12:
		    case 15:
		        col.g = dark.g;
		        col.b = dark.b;
		        break;
		    case 13:
		        col.r = dark.r;
		        col.b = dark.b;
		        break;
		}
		col = mix(origcol, col, maskMix);
	}
	COLOR = col;
}
