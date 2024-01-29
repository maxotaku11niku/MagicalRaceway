//CRT mask shader (tv version)
//Made for Godot

shader_type canvas_item;

const vec3 Yvec = vec3(0.299, 0.587, 0.114);
const vec2 halfvec = vec2(0.5);

void fragment() {
	vec2 guv = UV;
	vec2 ruv = guv + vec2(0.001, -0.0004);
	vec2 buv = guv + vec2(-0.0004, 0.0008);
	//float scalefac = 1.1 - 0.1 * dot(textureLod(TEXTURE, guv, -16.0).rgb, Yvec);
	//guv -= halfvec; ruv -= halfvec; buv -= halfvec;
	//guv *= scalefac; ruv *= scalefac; buv *= scalefac;
	//guv += halfvec; ruv += halfvec; buv += halfvec;
	vec4 col = texture(TEXTURE, guv);
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
	vec4 dark = vec4(col.rgb * 1.15 - 0.15, col.a);
	ivec2 fragcoord = ivec2(FRAGCOORD.xy);
	int maskcomp = fragcoord.x % 4;
	int stepbit = (fragcoord.x % 8)/4;
	int vertcomp = fragcoord.y;
	if (stepbit == 1) vertcomp += 2;
	vertcomp %= 4;
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
	if (vertcomp == 3) col = dark;
	COLOR = col;
}
