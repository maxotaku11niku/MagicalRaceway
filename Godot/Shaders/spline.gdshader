//This is the common spline drawing shader
shader_type canvas_item;

#define PARAM_SCALE 0.125
#define PARAM_DIST 0.375
#define PARAM_CENTER 0.625
#define PARAM_SPLIT 0.875

uniform sampler2D palette : filter_nearest;
/*
This 'texture' contains information on how to draw the spline
It must be in RF format (a single channel that is a 32-bit float)
It must be 4 pixels wide
Column 0: Scale
Column 1: Relative distance
Column 2: Center line position
Column 3: Split amount
*/
uniform sampler2D positioning : filter_nearest;
//(start line, number of lines, width, height of the postioning texture)
uniform vec4 positioningFactors;
//bit 0: is palettised?
//bit 1: clamp in x?
//bit 2: display on right side?
//bit 3: display on left side?
//bit 4: ignore bounds?
//bit 5: flip UVs on left side?
//bit 6-31: reserved
uniform int flags;
uniform vec2 texPixSize;
//(left, right)
uniform vec2 xBounds;
//(lower position, x-position in center line, x-gradient with respect to y)
uniform vec4 pPos;

void fragment()
{
	vec2 positLoc;
	//Get a few parameters
	positLoc.x = PARAM_SCALE; //Used to select parameters
	positLoc.y = (round(UV.y * positioningFactors.y + positioningFactors.x) + 0.5)/positioningFactors.w; //Fixed for each fragment
	float scale = texture(positioning, positLoc).r;
	positLoc.x = PARAM_DIST;
	float dist = texture(positioning, positLoc).r;
	positLoc.x = PARAM_CENTER;
	float center = texture(positioning, positLoc).r;
	positLoc.x = PARAM_SPLIT;
	float split = texture(positioning, positLoc).r;
	//Set actual UV
	vec2 pos;
	pos.x = UV.x;
	float width = positioningFactors.z;
	float sfac = scale * width * texPixSize.x;
	float cLine = 0.5 + (center / scale) - pPos.x / (scale * width);
	pos.x -= cLine;
	pos.x *= sfac;
	if (UV.x > cLine)
	{
		if ((flags & 0x4) != 0) pos.x -= (split + pPos.z + dist * pPos.w) * texPixSize.x;
		else discard;
	}
	else
	{
		if ((flags & 0x8) != 0) pos.x += (split + pPos.z + dist * pPos.w) * texPixSize.x;
		else discard;
		if ((flags & 0x20) != 0) pos.x = -pos.x;
	}
	if ((flags & 0x10) == 0)
	{
		if (pos.x < xBounds.x || pos.x > xBounds.y) discard;
	}
	//Assumes that if bounds are ignored, then this is the main road
	else pos.x += 0.5;
	pos.y = dist + pPos.y;
	pos.y *= texPixSize.y;
	pos.y = 1.0 - pos.y;
	//Get actual colour
	if ((flags & 0x2) != 0) pos.x = clamp(pos.x, 0.0, 0.9999);
	else pos.x = mod(pos.x, 1.0);
	pos.y = mod(pos.y, 1.0);
	if ((flags & 0x1) != 0)
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
