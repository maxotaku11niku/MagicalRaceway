class_name TouchControlScreen
extends Node2D

@export var controlNodes: Array[Node2D]
@export var anchorPoints: PackedByteArray
@export var basePositions: PackedVector2Array

enum
{
	TANCHOR_TOPLEFT = 0,
	TANCHOR_TOPRIGHT = 1,
	TANCHOR_BOTTOMLEFT = 2,
	TANCHOR_BOTTOMRIGHT = 3
}

func ChangeScreenSize() -> void:
	var dispSize: Vector2i = DisplayServer.screen_get_size()
	var dispRatios: Vector2 = Vector2(dispSize.x/320.0, dispSize.y/240.0)
	var dispRatio: float = minf(dispRatios.x, dispRatios.y)
	for i in range(len(controlNodes)):
		controlNodes[i].scale = Vector2(dispRatio, dispRatio)
		match anchorPoints[i]:
			TANCHOR_TOPLEFT:
				controlNodes[i].position = basePositions[i] * dispRatio
			TANCHOR_TOPRIGHT:
				controlNodes[i].position = (basePositions[i] - Vector2(320.0, 0.0)) * dispRatio + Vector2(dispSize.x, 0.0)
			TANCHOR_BOTTOMLEFT:
				controlNodes[i].position = (basePositions[i] - Vector2(0.0, 240.0)) * dispRatio + Vector2(0.0, dispSize.y)
			TANCHOR_BOTTOMRIGHT:
				controlNodes[i].position = (basePositions[i] - Vector2(320.0, 240.0)) * dispRatio + Vector2(dispSize.x, dispSize.y)

func _ready() -> void:
	ChangeScreenSize()
