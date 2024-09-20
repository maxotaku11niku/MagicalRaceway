class_name GameMaster
extends Node

const fakeSetupLines =\
[\
	"Init MH1KSYM2608 Arcade System...\n",\
	"Read ROM Header...\n",\
	"Set 1024-colour enable...\n",\
	"Set YM2608 mode...\n",\
	"Read DIP Switches...\n",\
	"Jump to vector 0x80000390\n",\
]
const regViewString =\
"000 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
010 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
020 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
030 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
040 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
050 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
060 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
070 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
080 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
090 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
0A0 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
0B0 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
0C0 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
0D0 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
0E0 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
0F0 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
100 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
110 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
120 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
130 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
140 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
150 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
160 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
170 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
180 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
190 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
1A0 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
1B0 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
1C0 %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X %02X%02X%02X%02X\n\
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
@export var trackCorr: Array[TrackDefinition]
@export var virtualScreen: TextureRect
@export var displayRoot: SubViewport
@export var mainContainer: SubViewportContainer
@export var viewportCover: ColorRect
@export var fakeTextInterface: Label
@export var scanlinedContainer: SubViewport
@export var postContainer: SubViewportContainer
@export var postScreen: TextureRect
@export var crtScanlines: ColorRect

var YM2608Regs: Array[int]
var currTrack: TrackDefinition
var framesToNextLine: int
var startupLine: int
var startupDone: bool
var curState: int
var prevState: int
var screenRoot: Node
var ym2608RegViewVisible: bool
var CRTfilteron: bool

func configureCRTFilter(enabled: bool) -> void:
	if enabled == CRTfilteron: return
	if enabled:
		mainContainer.reparent(scanlinedContainer)
		viewportCover.reparent(scanlinedContainer)
		virtualScreen.reparent(scanlinedContainer)
		virtualScreen.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		postContainer.visible = true
		postScreen.visible = true
		scanlinedContainer.move_child(crtScanlines, -1)
	else:
		mainContainer.reparent(self)
		move_child(mainContainer, -1)
		viewportCover.reparent(self)
		move_child(viewportCover, -1)
		virtualScreen.reparent(self)
		move_child(virtualScreen, -1)
		virtualScreen.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	CRTfilteron = enabled
	

func _onIntroEnd() -> void:
	curState = MSTATE_MENU
	
func _onMenuEnd(selectedTrack: int, songNum: int) -> void:
	curState = MSTATE_PLAYTIME
	MusicMaster.PlaySong(songNum + 1)
	currTrack = trackCorr[selectedTrack]

func _onPlayEnd() -> void:
	curState = MSTATE_MENU

func _ready() -> void:
	curState = -1
	prevState = -1
	startupLine = 0
	framesToNextLine = 5
	startupDone = false
	ym2608RegViewVisible = false
	CRTfilteron = false
	PersistentDataHandler.setAsGameMaster(self)
	YM2608Regs.resize(0x1D0)

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
				screenRoot.ResetWithNewTrack(currTrack)
			_:
				fakeTextInterface.visible = true
		prevState = curState
	if curState <= 0 or curState >= MSTATE_MAX: #invalid state
		if startupDone: #panic
			fakeTextInterface.text = "Whoops, we've entered an illegal state!"
		else: #do startup sequence
			framesToNextLine -= 1
			if framesToNextLine <= 0:
				configureCRTFilter(PersistentDataHandler.CRTfilter) #hack
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
		for i in range(0, 0x1D0):
			YM2608Regs[i] = MusicMaster.GetRegister(i)
		fakeTextInterface.text = regViewString % YM2608Regs
