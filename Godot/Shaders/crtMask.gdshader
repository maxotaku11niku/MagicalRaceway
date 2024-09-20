//CRT mask shader (tv version)
//Made for Godot

shader_type canvas_item;

const vec3 Yvec = vec3(0.299, 0.587, 0.114);
const vec2 halfvec = vec2(0.5);

void fragment() {
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
	//In reality the dark areas emit no light, but in practice
	//there would be light bloom anyway, so we do this
	//just to make the mask apparent without making the
	//screen way too dark
	vec4 dark = vec4(pow(col.rgb, vec3(1.14)), col.a);
	col.rgb = pow(col.rgb, vec3(0.574318));
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
	if (vertcomp == 3) col = dark;
	else
	{
		switch (maskcomp)
		{
			case 0:
				col.gb = dark.gb;
				break;
			case 1:
				col.rb = dark.rb;
				break;
			case 2:
				col.rg = dark.rg;
				break;
			case 3:
				col = dark;
				break;
		}
	}
	COLOR = col;
}
