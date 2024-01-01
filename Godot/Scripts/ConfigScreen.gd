extends MenuScreen

const optionDescriptions =\
[\
	"Set whether to display in fullscreen (screen-covering borderless window) or in a window.",\
	"Resolution of the window. Can only use whole-number multiples of 320x240; doesn't affect fullscreen.",\
	"Volume of the music, higher is louder of course.",\
	"Volume of sound effects, higher is louder of course.",\
	"Set which soundchip to emulate for the music. Use YM2608 if you want music, or you can turn it off entirely to save processing power. YM2203 is only for curiosity's sake, as it's objectively worse than the YM2608.",\
	"Enable this to allow acceleration to be the default in playtime. This is helpful for eliminating the strain when holding down the accelerate button.",\
	"Rebind controls to make them more comfortable for you.",\
	"Reset everything to the default, including control bindings.",\
	"Save your settings, press the back button if you don't want to save your settings.",\
]

const chipNames = ["Off", "YM2203", "YM2608"]

@export var initSetting: Control
@export var settings: Array[Control]
@export var descriptionLabel: Label
var selectedSetting: int
var midDmode: bool
var midResMult: int
var midBGMVol: float
var midSFXVol: float
var midEmuChip: int
var midAccelHold: bool

enum
{
	SETTING_DMODE = 0,
	SETTING_RESMULT,
	SETTING_BGMVOL,
	SETTING_SFXVOL,
	SETTING_CHIP,
	SETTING_ACCELHOLD,
	SETTING_REBIND,
	SETTING_RESET,
	SETTING_SAVE
}

signal sigSFXVolTest

func _onSettingSelected(num: int) -> void:
	if num > SETTING_ACCELHOLD:
		sigFocusOnNewControl.emit(settings[num], true)
	else:
		sigFocusOnNewControl.emit(settings[num], false)
	descriptionLabel.text = optionDescriptions[num]
	selectedSetting = num

func _onResetSettings() -> void:
	PersistentDataHandler.writeDefaultConfig()
	PersistentDataHandler.setAccordingToConfigSettings()
	midDmode = PersistentDataHandler.fullscreen
	midResMult = PersistentDataHandler.resmult
	midBGMVol = PersistentDataHandler.bgmvol
	midSFXVol = PersistentDataHandler.sfxvol
	midEmuChip = PersistentDataHandler.emuchip
	midAccelHold = PersistentDataHandler.accelhold
	(settings[SETTING_DMODE] as Label).text = "Fullscreen" if midDmode else "Windowed"
	(settings[SETTING_RESMULT] as Label).text = "%dx%d" % [320 * midResMult, 240 * midResMult]
	(settings[SETTING_BGMVOL] as Label).text = "%d%%" % midBGMVol
	(settings[SETTING_SFXVOL] as Label).text = "%d%%" % midSFXVol
	(settings[SETTING_CHIP] as Label).text = chipNames[midEmuChip]
	(settings[SETTING_ACCELHOLD] as Label).text = "On" if midAccelHold else "Off"

func _onSaveSettings() -> void:
	PersistentDataHandler.fullscreen = midDmode
	PersistentDataHandler.resmult = midResMult
	PersistentDataHandler.bgmvol = midBGMVol
	PersistentDataHandler.sfxvol = midSFXVol
	PersistentDataHandler.emuchip = midEmuChip
	PersistentDataHandler.accelhold = midAccelHold
	PersistentDataHandler.writeConfig()
	PersistentDataHandler.setAccordingToConfigSettings()
	sigMoveToNewScreen.emit(-1)

func _ready():
	if initSetting != null: initSetting.grab_focus.call_deferred()
	midDmode = PersistentDataHandler.fullscreen
	midResMult = PersistentDataHandler.resmult
	midBGMVol = PersistentDataHandler.bgmvol
	midSFXVol = PersistentDataHandler.sfxvol
	midEmuChip = PersistentDataHandler.emuchip
	midAccelHold = PersistentDataHandler.accelhold
	(settings[SETTING_DMODE] as Label).text = "Fullscreen" if midDmode else "Windowed"
	(settings[SETTING_RESMULT] as Label).text = "%dx%d" % [320 * midResMult, 240 * midResMult]
	(settings[SETTING_BGMVOL] as Label).text = "%d%%" % midBGMVol
	(settings[SETTING_SFXVOL] as Label).text = "%d%%" % midSFXVol
	(settings[SETTING_CHIP] as Label).text = chipNames[midEmuChip]
	(settings[SETTING_ACCELHOLD] as Label).text = "On" if midAccelHold else "Off"

func _process(delta):
	match selectedSetting:
		SETTING_DMODE:
			if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
				midDmode = not midDmode
				(settings[SETTING_DMODE] as Label).text = "Fullscreen" if midDmode else "Windowed"
		SETTING_RESMULT:
			if Input.is_action_just_pressed("ui_left"):
				midResMult -= 1
				if midResMult < 1: midResMult = PersistentDataHandler.maxRes
			elif Input.is_action_just_pressed("ui_right"):
				midResMult += 1
				if midResMult > PersistentDataHandler.maxRes: midResMult = 1
			(settings[SETTING_RESMULT] as Label).text = "%dx%d" % [320 * midResMult, 240 * midResMult]
		SETTING_BGMVOL:
			if Input.is_action_pressed("ui_left"):
				midBGMVol -= 20.0 * delta
				if midBGMVol < 0.0: midBGMVol = 0.0
				PersistentDataHandler.tempSetVol(midBGMVol, midSFXVol)
			if Input.is_action_pressed("ui_right"):
				midBGMVol += 20.0 * delta
				if midBGMVol > 100.0: midBGMVol = 100.0
				PersistentDataHandler.tempSetVol(midBGMVol, midSFXVol)
			(settings[SETTING_BGMVOL] as Label).text = "%d%%" % midBGMVol
		SETTING_SFXVOL:
			if Input.is_action_pressed("ui_left"):
				midSFXVol -= 20.0 * delta
				if midSFXVol < 0.0: midSFXVol = 0.0
				PersistentDataHandler.tempSetVol(midBGMVol, midSFXVol)
				sigSFXVolTest.emit()
			if Input.is_action_pressed("ui_right"):
				midSFXVol += 20.0 * delta
				if midSFXVol > 100.0: midSFXVol = 100.0
				PersistentDataHandler.tempSetVol(midBGMVol, midSFXVol)
				sigSFXVolTest.emit()
			(settings[SETTING_SFXVOL] as Label).text = "%d%%" % midSFXVol
		SETTING_CHIP:
			if Input.is_action_just_pressed("ui_left"):
				midEmuChip -= 1
				if midEmuChip < PersistentDataHandler.CHIP_NONE: midEmuChip = PersistentDataHandler.CHIP_YM2608
			if Input.is_action_just_pressed("ui_right"):
				midEmuChip += 1
				if midEmuChip > PersistentDataHandler.CHIP_YM2608: midEmuChip = PersistentDataHandler.CHIP_NONE
			(settings[SETTING_CHIP] as Label).text = chipNames[midEmuChip]
		SETTING_ACCELHOLD:
			if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
				midAccelHold = not midAccelHold
				(settings[SETTING_ACCELHOLD] as Label).text = "On" if midAccelHold else "Off"

func _exit_tree():
	PersistentDataHandler.resetSettingsAfterDecline()
