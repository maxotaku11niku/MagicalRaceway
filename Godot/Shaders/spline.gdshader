//This is the common spline drawing shader
shader_type canvas_item;

#define PARAM_DRAW 0.0625
#define PARAM_SCALE 0.1875
#define PARAM_DIST 0.3125
#define PARAM_CENTER 0.4375
#define PARAM_SPLIT 0.5625

uniform sampler2D palette;
uniform sampler2D positioning;
/*
This 'texture' contains information on how to draw the spline
It must be in RF format (a single channel that is a 32-bit float)
It must be 8 pixels wide
Column 0: Draw line? (yes if >= 0.5)
Column 1: Scale
Column 2: Relative distance
Column 3: Center line position
Column 4: Split amount
Column 5: Unused
Column 6: Unused
Column 7: Unused
*/
uniform int numLines;
uniform int width;
uniform int positLines;
uniform bool palettised;
uniform vec2 texPixSize;
uniform vec2 pPos;

void fragment()
{
	vec2 positLoc;
	positLoc.x = PARAM_DRAW; //Used to select parameters
	positLoc.y = (round(UV.y * float(numLines)) + 0.5)/float(positLines); //Fixed for each fragment
	float isdraw = texture(positioning, positLoc).r;
	if (isdraw < 0.5) //Skip processing if line isn't being drawn anyway
	{
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	}
	else
	{
		//Get a few parameters
		positLoc.x = PARAM_SCALE;
		float scale = texture(positioning, positLoc).r;
		positLoc.x = PARAM_CENTER;
		float center = texture(positioning, positLoc).r;
		positLoc.x = PARAM_SPLIT;
		float split = texture(positioning, positLoc).r;
		//Set actual UV
		vec2 pos;
		pos.x = UV.x;
		float sfac = scale * float(width) * texPixSize.x;
		float cLine = 0.5 + center - pPos.x / (scale * float(width));
		pos.x -= cLine;
		pos.x *= sfac;
		if (UV.x > cLine)
		{
			pos.x -= split * texPixSize.x;
		}
		else
		{
			pos.x += split * texPixSize.x;
		}
		pos.x += 0.5;
		positLoc.x = PARAM_DIST;
		pos.y = texture(positioning, positLoc).r + pPos.y;
		pos.y *= texPixSize.y;
		pos.y = 1.0 - pos.y;
		//Get actual colour
		pos.x = clamp(pos.x, 0.0, 0.9999);
		pos.y = mod(pos.y, 1.0);
		if (palettised)
		{
			float colPoint = texture(TEXTURE, pos).r;
			colPoint = (round(colPoint * 256.0) + 0.5)/256.0;
			COLOR = texture(palette, vec2(colPoint,0.0));
		}
		else
		{
			COLOR = texture(TEXTURE, pos);
		}
	}
}
