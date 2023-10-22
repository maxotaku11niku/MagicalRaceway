class_name AnimatedRoadSprite
extends Area2D

@export var colBox: CollisionShape2D
@export var visSprite: AnimatedSprite2D
@export var logicalPosition: Vector3
@export var screenPosition: Vector2
@export var layer: int

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	colBox.position.x = logicalPosition.x
	colBox.position.y = logicalPosition.z
	visSprite.position = screenPosition
	visSprite.z_index = layer
