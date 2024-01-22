extends Node

@export var menuBG: Node2D
@export var UIRoot: Control
@export var mainMenuScene: PackedScene
@export var difficultyMenuScene: PackedScene
@export var songSelectMenuScene: PackedScene
@export var highScoresScene: PackedScene
@export var musicRoomScene: PackedScene
@export var configMenuScene: PackedScene
@export var keybindsMenuScene: PackedScene
@export var selectSoundPlayer: AudioStreamPlayer
@export var confirmSoundPlayer: AudioStreamPlayer
@export var declineSoundPlayer: AudioStreamPlayer
@export var leftPointer: Sprite2D
@export var rightPointer: Sprite2D

var BGOffset: float
var currentScreen: MenuScreen
var curScreenNum: int
var prevScreenNum: int
var selectedDifficulty: int
var selectedSong: int
var enterPlaytime: bool
var testSoundCooldown: float

enum
{
	MSCREEN_MAIN,
	MSCREEN_DIFFICULTY,
	MSCREEN_SONGSELECT,
	MSCREEN_SCORES,
	MSCREEN_MUSICROOM,
	MSCREEN_CONFIG,
	MSCREEN_KEYBINDS
}

const returnScreens := [\
MSCREEN_MAIN,\
MSCREEN_MAIN,\
MSCREEN_DIFFICULTY,\
MSCREEN_MAIN,\
MSCREEN_MAIN,\
MSCREEN_MAIN,\
MSCREEN_CONFIG]

const bgCols := [\
Color8(0xCE, 0x6B, 0xFF),\
Color8(0xFF, 0xB5, 0x63),\
Color8(0x8C, 0xCE, 0xFF),\
Color8(0xFF, 0x5A, 0x00),\
Color8(0x18, 0x39, 0x84),\
Color8(0x00, 0xCE, 0x73),\
Color8(0x00, 0xCE, 0x73)]

enum
{
	BUTTON_RETURN = -1,
	BUTTON_START = 0,
	BUTTON_SCORES,
	BUTTON_MUSIC,
	BUTTON_CONFIG,
	BUTTON_QUIT,
	BUTTON_EASY = 256,
	BUTTON_MEDIUM,
	BUTTON_HARD,
	BUTTON_INSANE,
	BUTTON_SONG1 = 512,
	BUTTON_SONG2,
	BUTTON_SONG3,
	BUTTON_SONG4
}

enum
{
	DIFFICULTY_EASY,
	DIFFICULTY_MEDIUM,
	DIFFICULTY_HARD,
	DIFFICULTY_INSANE,
	DIFFICULTY_TEST
}

signal sigMenuEnd(songNum: int)

func _onNewControlSelected(control: Control, invertedPointing: bool) -> void:
	if control == null:
		leftPointer.visible = false
		rightPointer.visible = false
	else:
		leftPointer.visible = true
		rightPointer.visible = true
		leftPointer.scale = control.scale
		rightPointer.scale = control.scale
		if invertedPointing:
			rightPointer.position = control.position + control.scale * Vector2(-8.0, control.size.y * 0.5)
			leftPointer.position = control.position + control.scale * Vector2(8.0 + control.size.x, control.size.y * 0.5)
		else:
			leftPointer.position = control.position + control.scale * Vector2(-8.0, control.size.y * 0.5)
			rightPointer.position = control.position + control.scale * Vector2(8.0 + control.size.x, control.size.y * 0.5)

func _onMenuScreenChange(buttNum: int) -> void:
	match buttNum:
		BUTTON_RETURN:
			curScreenNum = returnScreens[curScreenNum]
		BUTTON_START:
			curScreenNum = MSCREEN_DIFFICULTY
		BUTTON_SCORES:
			curScreenNum = MSCREEN_SCORES
		BUTTON_MUSIC:
			curScreenNum = MSCREEN_MUSICROOM
		BUTTON_CONFIG:
			curScreenNum = MSCREEN_CONFIG
		BUTTON_QUIT:
			get_tree().quit()
			return
		BUTTON_EASY:
			curScreenNum = MSCREEN_SONGSELECT
			selectedDifficulty = DIFFICULTY_EASY
		BUTTON_MEDIUM:
			curScreenNum = MSCREEN_SONGSELECT
			selectedDifficulty = DIFFICULTY_MEDIUM
		BUTTON_HARD:
			curScreenNum = MSCREEN_SONGSELECT
			selectedDifficulty = DIFFICULTY_TEST
		BUTTON_INSANE:
			curScreenNum = MSCREEN_SONGSELECT
			selectedDifficulty = DIFFICULTY_TEST
		BUTTON_SONG1:
			selectedSong = 0
			enterPlaytime = true
		BUTTON_SONG2:
			selectedSong = 1
			enterPlaytime = true
		BUTTON_SONG3:
			selectedSong = 2
			enterPlaytime = true
		BUTTON_SONG4:
			selectedSong = 3
			enterPlaytime = true

func _onTestSFXVolume() -> void:
	if testSoundCooldown <= 0.0:
		selectSoundPlayer.play()
		testSoundCooldown = 0.2 # Prevents annoying buzzing sounds

func _ready() -> void:
	BGOffset = 0.0
	currentScreen = mainMenuScene.instantiate()
	UIRoot.add_child(currentScreen)
	currentScreen.sigMoveToNewScreen.connect(_onMenuScreenChange)
	currentScreen.sigFocusOnNewControl.connect(_onNewControlSelected)
	curScreenNum = MSCREEN_MAIN
	prevScreenNum = MSCREEN_MAIN
	menuBG.modulate = bgCols[curScreenNum]
	enterPlaytime = false
	MusicMaster.PlaySong(0)

func _process(delta: float) -> void:
	testSoundCooldown -= delta
	menuBG.position = Vector2(-BGOffset, BGOffset)
	BGOffset += 60.0 * delta
	if BGOffset > 64.0: BGOffset -= 64.0
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down") or Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
		selectSoundPlayer.play()
	if Input.is_action_just_pressed("ui_accept"):
		confirmSoundPlayer.play()
	if Input.is_action_just_pressed("ui_cancel"):
		declineSoundPlayer.play()
		_onMenuScreenChange(BUTTON_RETURN)
	if enterPlaytime:
		sigMenuEnd.emit(selectedSong)
	if curScreenNum != prevScreenNum:
		var nextScene: PackedScene
		match curScreenNum:
			MSCREEN_MAIN:
				nextScene = mainMenuScene
			MSCREEN_DIFFICULTY:
				nextScene = difficultyMenuScene
			MSCREEN_SONGSELECT:
				nextScene = songSelectMenuScene
			MSCREEN_SCORES:
				nextScene = highScoresScene
			MSCREEN_MUSICROOM:
				nextScene = musicRoomScene
			MSCREEN_CONFIG:
				nextScene = configMenuScene
			MSCREEN_KEYBINDS:
				nextScene = keybindsMenuScene
			_:
				return
		leftPointer.visible = false
		rightPointer.visible = false
		UIRoot.remove_child(currentScreen)
		currentScreen.free()
		currentScreen = nextScene.instantiate()
		UIRoot.add_child(currentScreen)
		currentScreen.sigMoveToNewScreen.connect(_onMenuScreenChange)
		currentScreen.sigFocusOnNewControl.connect(_onNewControlSelected)
		if curScreenNum == MSCREEN_CONFIG:
			currentScreen.sigSFXVolTest.connect(_onTestSFXVolume)
		prevScreenNum = curScreenNum
		menuBG.modulate = bgCols[curScreenNum]
