class_name MenuScreen
extends Control

@export var initButton: Button
@export var addCode: int

signal sigMoveToNewScreen(buttNum: int) #heehee

func _onButtonSelected(num: int) -> void:
	sigMoveToNewScreen.emit(num + addCode)

func _ready() -> void:
	initButton.grab_focus.call_deferred()

func _process(delta: float) -> void:
	pass
