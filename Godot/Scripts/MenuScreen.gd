class_name MenuScreen
extends Control

@export var initButton: Button
@export var addCode: int

signal sigMoveToNewScreen(buttNum: int) #heehee
signal sigFocusOnNewControl(control: Control)

func _onButtonSelected(num: int) -> void:
	sigMoveToNewScreen.emit(num + addCode)

func _onFocusOnNewControl(controlName: String, invertedPointing: bool) -> void:
	sigFocusOnNewControl.emit(find_child(controlName), invertedPointing)

func _ready() -> void:
	if initButton != null: initButton.grab_focus.call_deferred()

func _process(delta: float) -> void:
	pass

