class_name TouchSlider
extends Node2D

@export var slider: Node2D
@export var baseRect: Rect2
@export var maxLeft: float
@export var maxRight: float
@export var actionLeft: StringName
@export var actionRight: StringName

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		var pos: Vector2 = event.position
		pos -= position
		pos /= scale
		if baseRect.has_point(pos):
			if pos.x < 0.0:
				pos.x = maxf(pos.x, -maxLeft)
				Input.action_press(actionLeft, -pos.x/maxLeft)
			else:
				Input.action_release(actionLeft)
			if pos.x >= 0.0:
				pos.x = minf(pos.x, maxRight)
				Input.action_press(actionRight, pos.x/maxRight)
			else:
				Input.action_release(actionRight)
			slider.position.x = pos.x

func _ready() -> void:
	slider.position = Vector2(0.0, 0.0)
	Input.action_release(actionLeft)
	Input.action_release(actionRight)
