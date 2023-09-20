extends Node

const configID = "MRCF"
const configVersion = "42"
const configPath = "user://init.cfg"

enum
{
	MSTATE_INTRO,
	MSTATE_MENU,
	MSTATE_PLAYTIME
}

var curState: int
var prevState: int
var maxRes: int #Highest allowable resolution multiplier, from the dimensions of the screen
var screenRoot: Node

@export var introScene: PackedScene
@export var menuScene: PackedScene
@export var playScene: PackedScene
@export var virtualScreen: TextureRect
@export var displayRoot: SubViewport

func _onIntroEnd() -> void:
	curState = MSTATE_MENU
	
func _onMenuEnd() -> void:
	curState = MSTATE_PLAYTIME

func _onPlayEnd() -> void:
	curState = MSTATE_MENU

func _ready() -> void:
	curState = MSTATE_INTRO
	prevState = MSTATE_INTRO
	screenRoot = introScene.instantiate()
	displayRoot.add_child(screenRoot)
	screenRoot.sigIntroEnd.connect(_onIntroEnd)

func _process(delta: float) -> void:
	#State change -> need to load a new root scene
	if curState != prevState:
		displayRoot.remove_child(screenRoot)
		screenRoot.free()
		match (curState):
			MSTATE_INTRO: #Included just in case
				screenRoot = introScene.instantiate()
				displayRoot.add_child(screenRoot)
				screenRoot.sigIntroEnd.connect(_onIntroEnd)
			MSTATE_MENU:
				screenRoot = menuScene.instantiate()
				displayRoot.add_child(screenRoot)
				screenRoot.sigMenuEnd.connect(_onMenuEnd)
			MSTATE_PLAYTIME:
				screenRoot = playScene.instantiate()
				displayRoot.add_child(screenRoot)
				screenRoot.sigPlayEnd.connect(_onPlayEnd)
		prevState = curState
	pass
