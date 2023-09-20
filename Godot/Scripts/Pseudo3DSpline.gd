#Renders a pseudo-3D spline based on the given parameters
#NOTE: Currently has a lot of testing parameters
class_name Pseudo3DSpline
extends Node2D

@export var texture: Texture2D
@export var bound: Rect2
var posTex: ImageTexture
var posImg := Image.create(8, 256, false, Image.FORMAT_RF)
var posDat := PackedByteArray()
var mat: ShaderMaterial
var dist: float
var xpos: float
var yspeed: float

func _draw() -> void:
	draw_texture_rect(texture, bound, false)

func _ready() -> void:
	posDat.resize(8 * 256 * 4)
	posDat.fill(0)
	dist = 0.0
	xpos = 0.0
	yspeed = 0.0
	for i in range(128, 240):
		var rscale := 1.0/(0.1 + 3.9 * ((i - 128.0)/111.0));
		posDat.encode_float((i * 8) * 4, 1.0)
		posDat.encode_float((i * 8 + 1) * 4, rscale)
		posDat.encode_float((i * 8 + 2) * 4, (239.0 - i) * rscale + dist)
		posDat.encode_float((i * 8 + 3) * 4, 0.0)
		posDat.encode_float((i * 8 + 4) * 4, (239.0 - i) * rscale * 0.1)
	posImg.set_data(8, 256, false, Image.FORMAT_RF, posDat)
	posTex = ImageTexture.create_from_image(posImg)
	mat = material
	mat.set_shader_parameter("positioning", posTex)
	mat.set_shader_parameter("numLines", bound.size.y - 1)
	mat.set_shader_parameter("width", bound.size.x)
	mat.set_shader_parameter("positLines", 256)
	mat.set_shader_parameter("texPixSize", Vector2(1.0/texture.get_width(), 1.0/texture.get_height()))

func _process(delta: float) -> void:
	if (Input.is_action_pressed("accel")):
		yspeed += delta * 64.0
	if (Input.is_action_pressed("brake")):
		yspeed -= delta * 64.0
	if (Input.is_action_pressed("steer_left")):
		xpos -= delta * 64.0
	if (Input.is_action_pressed("steer_right")):
		xpos += delta * 64.0
	dist += delta * yspeed
	if (dist > 64.0): dist -= 64.0
	mat.set_shader_parameter("pPos", Vector2(xpos, dist))
	queue_redraw()
