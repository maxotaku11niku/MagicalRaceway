shader_type canvas_item;

uniform vec4 col : source_color;

void fragment()
{
	vec4 texcol = texture(TEXTURE, UV);
	vec3 outcol = mix(texcol.rgb, col.rgb, col.a);
	COLOR = vec4(outcol, texcol.a);
}
