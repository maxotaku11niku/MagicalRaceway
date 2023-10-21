//Shader for the sky
shader_type canvas_item;

uniform sampler2D palette : filter_nearest;
uniform float yOffset;

void fragment()
{
	vec2 pos = UV;
	pos.y += yOffset;
	pos.y = clamp(pos.y, 0.0, 0.9999);
	pos.x = mod(pos.x, 1.0);
	float colPoint = texture(TEXTURE, pos).r;
	colPoint = (round(colPoint * 256.0) + 0.5)/256.0;
	COLOR = texture(palette, vec2(colPoint,0.0));
}
