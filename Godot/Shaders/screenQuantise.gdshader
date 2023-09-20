//Simple shader to quantise screen colours to some specified depth
shader_type canvas_item;
//5 bits per channel
#define LEVELS 31.0

void fragment()
{
	vec4 incol = texture(TEXTURE, UV);
	incol.rgb *= LEVELS;
	incol.rgb = round(incol.rgb);
	incol.rgb /= LEVELS;
	COLOR = incol;
}
