extends Node

const configID = "MRCF"
const configVersion = "42"
const configPath = "user://init.cfg"
const fakeSetupLines =\
[\
	"Init MH4KSYM2608 Arcade System...\n",\
	"Read ROM Header...\n",\
	"Set 1024-colour enable...\n",\
	"Set YM2608 mode...\n",\
	"Read DIP Switches...\n",\
	"Jump to vector 0x80000390\n",\
]
const regViewString =\
"000 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
010 There is nothing here\n\
020 because YM2608 emulation\n\
030 has not been implemented.\n\
040 Please wait warmly\n\
050 until it is done.\n\
060\n\
070\n\
080\n\
090\n\
0A0\n\
0B0\n\
0C0\n\
0D0\n\
0E0\n\
0F0\n\
100\n\
110\n\
120\n\
130\n\
140\n\
150\n\
160\n\
170\n\
180\n\
190\n\
1A0\n\
1B0\n\
1C0\n\
YM2608 Register Viewer - Press Alt-M"

enum
{
	MSTATE_INTRO,
	MSTATE_MENU,
	MSTATE_PLAYTIME,
	MSTATE_MAX
}

@export var introScene: PackedScene
@export var menuScene: PackedScene
@export var playScene: PackedScene
@export var virtualScreen: TextureRect
@export var displayRoot: SubViewport
@export var fakeTextInterface: Label

var framesToNextLine: int
var startupLine: int
var startupDone: bool
var curState: int
var prevState: int
var maxRes: int #Highest allowable resolution multiplier, from the dimensions of the screen
var screenRoot: Node
var ym2608RegViewVisible: bool

func _onIntroEnd() -> void:
	curState = MSTATE_MENU
	
func _onMenuEnd() -> void:
	curState = MSTATE_PLAYTIME

func _onPlayEnd() -> void:
	curState = MSTATE_MENU

func _ready() -> void:
	curState = -1
	prevState = -1
	startupLine = 0
	framesToNextLine = 5
	startupDone = false
	ym2608RegViewVisible = false
	get_tree().root.size = Vector2i(640, 480)

func _process(delta: float) -> void:
	#State change -> need to load a new root scene
	if curState != prevState:
		if screenRoot != null:
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
			_:
				fakeTextInterface.visible = true
		prevState = curState
	if curState <= 0 or curState >= MSTATE_MAX: #invalid state
		if startupDone: #panic
			fakeTextInterface.text = "Whoops, we've entered an illegal state!"
		else: #do startup sequence
			framesToNextLine -= 1
			if framesToNextLine <= 0:
				if startupLine >= len(fakeSetupLines):
					curState = MSTATE_INTRO
					fakeTextInterface.text = ""
					fakeTextInterface.visible = false
				else:
					fakeTextInterface.text += fakeSetupLines[startupLine]
					startupLine += 1
					framesToNextLine = 5
	if Input.is_action_just_pressed("dev_regview"):
		ym2608RegViewVisible = not ym2608RegViewVisible
		fakeTextInterface.visible = ym2608RegViewVisible
	if ym2608RegViewVisible:
		fakeTextInterface.text = regViewString %\
		[45, 69, 189, 34, 0xDE, 0xAD, 0xBE, 0xEF, 0x69, 0x29, 0x04, 0x20, 1, 2, 3, 4]
