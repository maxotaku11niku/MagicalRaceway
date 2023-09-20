#Renders the sky in the background, whose colours are changed by a palette
class_name Sky2D
extends Node2D

@export var texture: Texture2D
@export var bound: Rect2
@export var bottomY: float
var texHeight: float
var mat: ShaderMaterial

func _draw() -> void:
	draw_texture_rect(texture, bound, true)

func _ready() -> void:
	texHeight = texture.get_height()
	mat = material

func _process(delta: float) -> void:
	var tyoffs := (texHeight - bottomY) / texHeight
	mat.set_shader_parameter("yOffset", tyoffs)
	queue_redraw()
