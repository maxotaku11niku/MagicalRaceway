shader_type canvas_item;

#define SCALE 10.0

uniform float split = 0.0;
uniform float colourAdd = 0.0;
uniform vec4 blendCol : source_color;

void vertex()
{
	VERTEX.x *= 3.0;
}

void fragment()
{
	vec2 coord = UV;
	coord.x *= 3.0;
	coord.x -= 1.0;
	float normy = coord.y - 0.5;
	normy *= 10.0;
	if (normy >= 0.0)
	{
		normy -= split * SCALE;
		if (normy >= 0.0) coord.x += normy * normy;
	}
	else
	{
		normy += split * SCALE;
		if (normy < 0.0) coord.x += -(normy * normy);
	}
	if (coord.x > 1.0 || coord.x < 0.0 || coord.y > 1.0 || coord.y < 0.0)
	{
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	}
	else
	{
		vec4 basecol = texture(TEXTURE, coord);
		vec3 mixcol = mix(basecol.rgb, blendCol.rgb, blendCol.a) + colourAdd;
		COLOR = vec4(mixcol, basecol.a);
	}
	
}
