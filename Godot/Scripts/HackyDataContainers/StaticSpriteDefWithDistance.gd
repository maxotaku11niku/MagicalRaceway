class_name StaticSpriteDefWithDistance
extends Resource

enum
{
	SPAWNSIDE_RIGHT = 1,
	SPAWNSIDE_LEFT = 2,
	SPAWNSIDE_BOTH = 3
}

@export var spriteDef: StaticSpriteDef
@export_flags("Right:1", "Left:2") var spawnSide: int
@export var numSprite: int
@export var separation: float
@export var offset: Vector2
@export var baseScale: float
@export var flip: bool
@export var flipOnOtherSide: bool
@export var canCollide: bool
@export var dist: float
