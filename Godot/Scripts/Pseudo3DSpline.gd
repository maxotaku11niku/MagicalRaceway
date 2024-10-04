class_name Pseudo3DSpline
extends Node2D
## Renders a pseudo-3D spline based on the given parameters

@export var texture: Texture2D
@export var bound: Rect2
@export var positTexHeight: int
@export var isMainRoad: bool
@export var isXClamped: bool
@export var sideFlags: int
#(start line, number of lines, width, height of the postioning texture)
var palTex: ImageTexture

func SetPositioningTexture(posTex: Texture2D) -> void:
	material.set_shader_parameter("positioning", posTex)

func SetPositioningParameters(mainPos: Vector2, xOffset: float, xGrad:float) -> void:
	material.set_shader_parameter("pPos", Vector4(mainPos.x, mainPos.y, xOffset, xGrad))

func SetXBounds(left: float, right: float) -> void:
	material.set_shader_parameter("xBounds", Vector2(left, right))

func _draw() -> void:
	draw_texture_rect(texture, bound, false)

func _ready() -> void:
	var posFac: Vector4
	posFac.x = bound.position.y
	posFac.y = bound.size.y - 1
	posFac.z = bound.size.x
	posFac.w = positTexHeight
	var flags := 0
	if (isMainRoad): flags = 0x1F
	else: flags = 0x20
	if (isXClamped): flags |= 0x02
	flags |= sideFlags << 2
	material.set_shader_parameter("positioningFactors", posFac)
	material.set_shader_parameter("flags", flags)

func _process(delta: float) -> void:
	var posFac: Vector4
	posFac.x = bound.position.y
	posFac.y = bound.size.y - 1
	posFac.z = bound.size.x
	posFac.w = positTexHeight
	var flags := 0
	if (isMainRoad): flags = 0x1F
	else: flags = 0x20
	if (isXClamped): flags |= 0x02
	flags |= sideFlags << 2
	material.set_shader_parameter("positioningFactors", posFac)
	material.set_shader_parameter("flags", flags)
	if (texture != null): material.set_shader_parameter("texPixSize", Vector2(1.0/texture.get_width(), 1.0/texture.get_height()))
	if (palTex != null): material.set_shader_parameter("palette", palTex)
	queue_redraw()
