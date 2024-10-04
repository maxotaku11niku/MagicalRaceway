class_name TexturedStripWithDistance
extends Resource

enum
{
	SPAWNSIDE_RIGHT = 1,
	SPAWNSIDE_LEFT = 2,
	SPAWNSIDE_BOTH = 3
}

@export var texture: Texture2D
@export_flags("Right:1", "Left:2") var side: int
@export var size: Vector2
@export var xClamp: bool
@export var xOffsetList: Array[FloatWithDistance]
@export var distance: float
