class_name Pseudo3DSpline
extends Node2D
## Renders a pseudo-3D spline based on the given parameters

@export var texture: Texture2D
@export var bound: Rect2
var palTex: ImageTexture

func _draw() -> void:
	draw_texture_rect(texture, bound, false)

func _ready() -> void:
	material.set_shader_parameter("startLine", bound.position.y)
	material.set_shader_parameter("numLines", bound.size.y - 1)
	material.set_shader_parameter("width", bound.size.x)
	material.set_shader_parameter("texPixSize", Vector2(1.0/texture.get_width(), 1.0/texture.get_height()))

func _process(delta: float) -> void:
	material.set_shader_parameter("startLine", bound.position.y)
	material.set_shader_parameter("numLines", bound.size.y - 1)
	material.set_shader_parameter("width", bound.size.x)
	material.set_shader_parameter("palette", palTex)
	queue_redraw()
