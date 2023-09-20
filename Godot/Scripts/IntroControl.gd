extends Node

@export var logoSprite: Sprite2D
@export var introAnimationPlayer: AnimationPlayer
@export var logoSplit: float
@export var logoCol: Color
@export var logoFade: float
var time: float
var logoMat: ShaderMaterial

signal sigIntroEnd

func _ready() -> void:
	introAnimationPlayer.play("intro")
	logoMat = logoSprite.material
	logoMat.set_shader_parameter("split", logoSplit)
	logoMat.set_shader_parameter("blendCol", logoCol)
	logoMat.set_shader_parameter("colourAdd", -logoFade)
	time = 0.0

func _process(delta: float) -> void:
	logoMat.set_shader_parameter("split", logoSplit)
	logoMat.set_shader_parameter("blendCol", logoCol)
	logoMat.set_shader_parameter("colourAdd", -logoFade)
	time += delta
	if time > 8.0 or Input.is_action_pressed("ui_accept"):
		sigIntroEnd.emit()
