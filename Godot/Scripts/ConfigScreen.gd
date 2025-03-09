extends MenuScreen

const optionDescriptions =\
[\
	"Set whether to display in fullscreen (screen-covering borderless window) or in a window.",\
	"Resolution of the window. Can only use whole-number multiples of 320x240; doesn't affect fullscreen.",\
	"Volume of the music, higher is louder of course.",\
	"Volume of sound effects, higher is louder of course.",\
	"Set which soundchip to emulate for the music. Use YM2608 if you want music, or you can turn it off entirely to save processing power. YM2203 is only for curiosity's sake, as it's objectively worse than the YM2608.",\
	"Enable this to allow acceleration to be the default in playtime. This is helpful for eliminating the strain when holding down the accelerate button.",\
	"Enable a simple CRT filter, doesn't emulate CRT geometry though. Nostalgia time!",\
	"Rebind controls to make them more comfortable for you.",\
	"Reset everything to the default, including control bindings.",\
	"Save your settings, press the back button if you don't want to save your settings.",\
	"Hold the confirm button for 5 seconds to reset all your high scores. No going back from this!",\
]

const chipNames = ["Off", "YM2203", "YM2608"]

@export var initSetting: Control
@export var settings: Array[Control]
@export var descriptionLabel: Label
@export var mainScreen: Control
@export var controlsScreen: Control
var selectedSetting: int
var midDmode: bool
var midResMult: int
var midBGMVol: float
var midSFXVol: float
var midEmuChip: int
var midAccelHold: bool
var midCRTFilter: bool
var currentSelectedDevice: int
var connectedControllers: Array[int]
var resetTimer: float
var afterResetTimer: float
var waitForInputTimer: float

enum
{
	SETTING_DMODE = 0,
	SETTING_RESMULT,
	SETTING_BGMVOL,
	SETTING_SFXVOL,
	SETTING_CHIP,
	SETTING_ACCELHOLD,
	SETTING_CRTFILTER,
	SETTING_REBIND,
	SETTING_RESET,
	SETTING_SAVE,
	SETTING_RESETHIGHSCORES,
	SETTING_CONTROL_DEVICE,
	SETTING_CONTROL_ACCEL,
	SETTING_CONTROL_BRAKE,
	SETTING_CONTROL_RIGHT,
	SETTING_CONTROL_LEFT,
	SETTING_CONTROL_PAUSE,
	SETTING_CONTROL_SAVE
}

enum
{
	DEVICE_KEYBOARD,
	DEVICE_CONTROLLER_OFFSET
}

signal sigSFXVolTest

func GetControlName(control: StringName, controller: int) -> String:
	var eventList := InputMap.action_get_events(control)
	for i in range(len(eventList)):
		var curEvent := eventList[i]
		if controller < DEVICE_CONTROLLER_OFFSET:
			if curEvent is InputEventKey:
				var physKeyCode: Key = curEvent.physical_keycode
				var keyCode := DisplayServer.keyboard_get_keycode_from_physical(physKeyCode)
				if (physKeyCode == 0):
					keyCode = curEvent.keycode
				return OS.get_keycode_string(keyCode)
		else:
			if curEvent is InputEventJoypadButton:
				return "uh-oh"
			elif curEvent is InputEventJoypadMotion:
				return "uh-oh"
	return "undefined"

func _onSettingSelected(num: int) -> void:
	if num <= SETTING_RESETHIGHSCORES:
		if num > SETTING_CRTFILTER:
			sigFocusOnNewControl.emit(settings[num], true)
		else:
			sigFocusOnNewControl.emit(settings[num], false)
		descriptionLabel.text = optionDescriptions[num]
	else:
		if num > SETTING_CONTROL_DEVICE:
			sigFocusOnNewControl.emit(settings[num], true)
		else:
			sigFocusOnNewControl.emit(settings[num], false)
	selectedSetting = num

func _onEnterControlConfig() -> void:
	mainScreen.visible = false
	controlsScreen.visible = true
	waitForInputTimer = 0.0
	settings[SETTING_CONTROL_DEVICE].grab_focus.call_deferred()
	currentSelectedDevice = DEVICE_KEYBOARD
	connectedControllers = Input.get_connected_joypads()
	(settings[SETTING_CONTROL_DEVICE] as Label).text = "Keyboard"
	(settings[SETTING_CONTROL_ACCEL] as Label).text = GetControlName(&"accel", currentSelectedDevice)
	(settings[SETTING_CONTROL_BRAKE] as Label).text = GetControlName(&"brake", currentSelectedDevice)
	(settings[SETTING_CONTROL_RIGHT] as Label).text = GetControlName(&"steer_right", currentSelectedDevice)
	(settings[SETTING_CONTROL_LEFT] as Label).text = GetControlName(&"steer_left", currentSelectedDevice)
	(settings[SETTING_CONTROL_PAUSE] as Label).text = GetControlName(&"pause", currentSelectedDevice)

func _onLeaveControlConfig(save: bool) -> void:
	mainScreen.visible = true
	controlsScreen.visible = false
	settings[SETTING_REBIND].grab_focus.call_deferred()

func _onResetSettings() -> void:
	PersistentDataHandler.writeDefaultConfig()
	PersistentDataHandler.setAccordingToConfigSettings()
	midDmode = PersistentDataHandler.fullscreen
	midResMult = PersistentDataHandler.resmult
	midBGMVol = PersistentDataHandler.bgmvol
	midSFXVol = PersistentDataHandler.sfxvol
	midEmuChip = PersistentDataHandler.emuchip
	midAccelHold = PersistentDataHandler.accelhold
	midCRTFilter = PersistentDataHandler.CRTfilter
	(settings[SETTING_DMODE] as Label).text = "Fullscreen" if midDmode else "Windowed"
	(settings[SETTING_RESMULT] as Label).text = "%dx%d" % [320 * midResMult, 240 * midResMult]
	(settings[SETTING_BGMVOL] as Label).text = "%d%%" % midBGMVol
	(settings[SETTING_SFXVOL] as Label).text = "%d%%" % midSFXVol
	(settings[SETTING_CHIP] as Label).text = chipNames[midEmuChip]
	(settings[SETTING_ACCELHOLD] as Label).text = "On" if midAccelHold else "Off"
	(settings[SETTING_CRTFILTER] as Label).text = "On" if midCRTFilter else "Off"

func _onSaveSettings() -> void:
	PersistentDataHandler.fullscreen = midDmode
	PersistentDataHandler.resmult = midResMult
	PersistentDataHandler.bgmvol = midBGMVol
	PersistentDataHandler.sfxvol = midSFXVol
	PersistentDataHandler.emuchip = midEmuChip
	PersistentDataHandler.accelhold = midAccelHold
	PersistentDataHandler.CRTfilter = midCRTFilter
	PersistentDataHandler.writeConfig()
	PersistentDataHandler.setAccordingToConfigSettings()
	sigMoveToNewScreen.emit(-1)

func _input(event: InputEvent) -> void:
	if waitForInputTimer > 0.0:
		var actionName: StringName = PersistentDataHandler.controlNames[selectedSetting - SETTING_CONTROL_ACCEL]
		var eventList := InputMap.action_get_events(actionName)
		if currentSelectedDevice < DEVICE_CONTROLLER_OFFSET:
			if event is InputEventKey:
				if (event as InputEventKey).pressed:
					for i in range(len(eventList)):
						var oldEvent := eventList[i]
						if oldEvent is InputEventKey:
							event.device = -1
							InputMap.action_erase_event(actionName, oldEvent)
							InputMap.action_add_event(actionName, event)
							waitForInputTimer = 0.0
							return
		else:
			if event.device == connectedControllers[currentSelectedDevice - DEVICE_CONTROLLER_OFFSET]:
				if event is InputEventJoypadButton:
					if (event as InputEventJoypadButton).pressed:
						for i in range(len(eventList)):
							var oldEvent := eventList[i]
							if oldEvent is InputEventJoypadButton:
								event.device = -1
								InputMap.action_erase_event(actionName, oldEvent)
								InputMap.action_add_event(actionName, event)
								waitForInputTimer = 0.0
								return
				elif event is InputEventJoypadMotion:
					for i in range(len(eventList)):
						var oldEvent := eventList[i]
						if oldEvent is InputEventJoypadMotion:
							event.device = -1
							InputMap.action_erase_event(actionName, oldEvent)
							InputMap.action_add_event(actionName, event)
							waitForInputTimer = 0.0
							return

func _ready():
	mainScreen.visible = true
	controlsScreen.visible = false
	if initSetting != null: initSetting.grab_focus.call_deferred()
	midDmode = PersistentDataHandler.fullscreen
	midResMult = PersistentDataHandler.resmult
	midBGMVol = PersistentDataHandler.bgmvol
	midSFXVol = PersistentDataHandler.sfxvol
	midEmuChip = PersistentDataHandler.emuchip
	midAccelHold = PersistentDataHandler.accelhold
	midCRTFilter = PersistentDataHandler.CRTfilter
	(settings[SETTING_DMODE] as Label).text = "Fullscreen" if midDmode else "Windowed"
	(settings[SETTING_RESMULT] as Label).text = "%dx%d" % [320 * midResMult, 240 * midResMult]
	(settings[SETTING_BGMVOL] as Label).text = "%d%%" % midBGMVol
	(settings[SETTING_SFXVOL] as Label).text = "%d%%" % midSFXVol
	(settings[SETTING_CHIP] as Label).text = chipNames[midEmuChip]
	(settings[SETTING_ACCELHOLD] as Label).text = "On" if midAccelHold else "Off"
	(settings[SETTING_CRTFILTER] as Label).text = "On" if midCRTFilter else "Off"
	resetTimer = 0.0
	afterResetTimer = -1.0
	waitForInputTimer = 0.0

func _process(delta):
	afterResetTimer -= delta
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
		SETTING_CRTFILTER:
			if Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
				midCRTFilter = not midCRTFilter
				(settings[SETTING_CRTFILTER] as Label).text = "On" if midCRTFilter else "Off"
		SETTING_RESETHIGHSCORES:
			if Input.is_action_pressed("ui_accept"):
				resetTimer += delta
				if (afterResetTimer < 0.0): descriptionLabel.text = "%.1f seconds to reset, are you sure?" % (5.0 - resetTimer)
				if resetTimer > 5.0:
					PersistentDataHandler.resetHighScores()
					resetTimer = 0.0
					afterResetTimer = 5.0
			else:
				resetTimer = 0.0
				descriptionLabel.text = optionDescriptions[SETTING_RESETHIGHSCORES]
			if (afterResetTimer >= 0.0): descriptionLabel.text = "High scores reset! Hope you didn't regret it."
		SETTING_CONTROL_DEVICE:
			if Input.is_action_just_pressed("ui_left"):
				currentSelectedDevice -= 1
				if currentSelectedDevice < DEVICE_KEYBOARD: currentSelectedDevice = DEVICE_CONTROLLER_OFFSET + len(connectedControllers) - 1
			if Input.is_action_just_pressed("ui_right"):
				currentSelectedDevice += 1
				if currentSelectedDevice > DEVICE_CONTROLLER_OFFSET + len(connectedControllers) - 1: currentSelectedDevice = DEVICE_KEYBOARD
			if currentSelectedDevice == 0: (settings[SETTING_CONTROL_DEVICE] as Label).text = "Keyboard"
			else: (settings[SETTING_CONTROL_DEVICE] as Label).text = Input.get_joy_name(connectedControllers[currentSelectedDevice - DEVICE_CONTROLLER_OFFSET])
			for i in range(len(PersistentDataHandler.controlNames)):
				(settings[SETTING_CONTROL_ACCEL + i] as Label).text = GetControlName(PersistentDataHandler.controlNames[i], currentSelectedDevice)
		SETTING_CONTROL_ACCEL, SETTING_CONTROL_BRAKE, SETTING_CONTROL_RIGHT, SETTING_CONTROL_LEFT, SETTING_CONTROL_PAUSE:
			waitForInputTimer -= delta
			if Input.is_action_just_pressed("ui_accept"):
				waitForInputTimer = 10.0
			else:
				if waitForInputTimer > 0.0:
					(settings[selectedSetting] as Label).text = "Waiting for input..."
				else:
					(settings[selectedSetting] as Label).text = GetControlName(PersistentDataHandler.controlNames[selectedSetting - SETTING_CONTROL_ACCEL], currentSelectedDevice)

func _exit_tree():
	PersistentDataHandler.resetSettingsAfterDecline()
