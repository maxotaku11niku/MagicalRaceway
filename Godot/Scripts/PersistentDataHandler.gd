extends Node

const configID = "MRCF"
const configVersion = "29"
const configPath = "user://init.cfg"

const scoreFileID = "MRSF"
const scoreFileVersion = "29"
const scoreFilePath = "user://Scorefiles/"
const scoreFileExtension = ".mrs"
const scoreFilePassword = "LifeAndHometown" # If you know you know...

const controlNames = [&"accel", &"brake", &"steer_right", &"steer_left", &"pause"]

enum
{
	CHIP_NONE,
	CHIP_YM2203,
	CHIP_YM2608
}

var highScores: Array[HighScoreGroup]

var gm: GameMaster
var maxRes: int #Highest allowable resolution multiplier, from the dimensions of the screen
var fullscreen: bool
var resmult: int
var bgmvol: int
var sfxvol: int
var emuchip: int
var accelhold: bool
var CRTfilter: bool
var lastHighScoreName: String

func setAsGameMaster(master: GameMaster) -> void:
	gm = master

func tempSetVol(bgm: int, sfx: int) -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(float(bgm)/100.0))
	AudioServer.set_bus_volume_db(1, linear_to_db(float(sfx)/100.0))

func resetSettingsAfterDecline() -> void:
	AudioServer.set_bus_volume_db(2, linear_to_db(float(bgmvol)/100.0))
	AudioServer.set_bus_volume_db(1, linear_to_db(float(sfxvol)/100.0))

func writeConfig() -> void:
	var cfgFile: FileAccess = FileAccess.open(configPath, FileAccess.WRITE)
	cfgFile.store_string(configID)
	cfgFile.store_string(configVersion)
	cfgFile.store_8(0x01 if fullscreen else 0x00)
	cfgFile.store_8(resmult)
	cfgFile.store_8(bgmvol)
	cfgFile.store_8(sfxvol)
	cfgFile.store_8(emuchip)
	cfgFile.store_8(0x01 if accelhold else 0x00)
	cfgFile.store_8(0x01 if CRTfilter else 0x00)
	cfgFile.store_pascal_string(lastHighScoreName)
	for i in range(len(controlNames)):
		var thisEvents := InputMap.action_get_events(controlNames[i])
		cfgFile.store_8(len(thisEvents))
		for j in range(len(thisEvents)):
			var curEvent := thisEvents[j]
			if curEvent is InputEventKey:
				cfgFile.store_8(0x00)
				var physCode := (curEvent as InputEventKey).physical_keycode
				cfgFile.store_32(physCode)
			elif curEvent is InputEventJoypadButton:
				cfgFile.store_8(0x01)
				var buttCode := (curEvent as InputEventJoypadButton).button_index
				cfgFile.store_32(buttCode)
			elif curEvent is InputEventJoypadMotion:
				cfgFile.store_8(0x01)
				var axisCode := (curEvent as InputEventJoypadMotion).axis
				var axisDir := (curEvent as InputEventJoypadMotion).axis_value
				if axisDir > 0.0: axisCode |= 0x0200
				elif axisDir < 0.0: axisCode |= 0x0300
				else: axisCode |= 0x0100
				cfgFile.store_32(axisCode)
	cfgFile.close()

func writeDefaultConfig() -> void:
	fullscreen = false
	resmult = 2
	bgmvol = 100
	sfxvol = 100
	emuchip = CHIP_YM2608
	accelhold = false
	CRTfilter = false
	lastHighScoreName = ""
	InputMap.load_from_project_settings()
	writeConfig()

func readConfig() -> void:
	if FileAccess.file_exists(configPath):
		var cfgFile: FileAccess = FileAccess.open(configPath, FileAccess.READ)
		var magicCheck := cfgFile.get_buffer(4).get_string_from_utf8()
		if magicCheck != configID: #magic number is wrong -> corrupt file? -> rewrite defaults
			cfgFile.close()
			writeDefaultConfig()
			return
		var versionCheck := cfgFile.get_buffer(2).get_string_from_utf8()
		match versionCheck: #new versions are created if the format is updated and a new release is created
			"29":
				fullscreen = cfgFile.get_8()
				resmult = cfgFile.get_8()
				bgmvol = cfgFile.get_8()
				sfxvol = cfgFile.get_8()
				emuchip = cfgFile.get_8()
				accelhold = cfgFile.get_8()
				CRTfilter = cfgFile.get_8()
				lastHighScoreName = cfgFile.get_pascal_string()
				for i in range(len(controlNames)):
					InputMap.action_erase_events(controlNames[i])
					var numControls := cfgFile.get_8()
					for j in range(numControls):
						var controlType := cfgFile.get_8()
						var controlNumber := cfgFile.get_32()
						match controlType:
							0x00:
								var curEvent := InputEventKey.new()
								curEvent.device = -1
								curEvent.physical_keycode = controlNumber
								InputMap.action_add_event(controlNames[i], curEvent)
							0x01:
								if controlNumber < 0x100:
									var curEvent := InputEventJoypadButton.new()
									curEvent.device = -1
									curEvent.button_index = controlNumber
									InputMap.action_add_event(controlNames[i], curEvent)
								else:
									var curEvent := InputEventJoypadMotion.new()
									curEvent.device = -1
									curEvent.axis = controlNumber & 0xFF
									match controlNumber & 0xF00:
										0x100:
											curEvent.axis_value = 0.0
										0x200:
											curEvent.axis_value = 1.0
										0x300:
											curEvent.axis_value = -1.0
									InputMap.action_add_event(controlNames[i], curEvent)
			_: #invalid version -> corrupt file? -> rewrite defaults
				cfgFile.close()
				writeDefaultConfig()
				return
		cfgFile.close()
	else: #no init.cfg -> create default one
		writeDefaultConfig()

func setAccordingToConfigSettings() -> void:
	if DisplayServer.has_feature(DisplayServer.FEATURE_SUBWINDOWS):
		get_tree().root.mode = Window.MODE_FULLSCREEN if fullscreen else Window.MODE_WINDOWED
		get_tree().root.size = Vector2i(320 * resmult, 240 * resmult)
	else: # Force fullscreen display if we can't use windows
		get_tree().root.mode = Window.MODE_FULLSCREEN
		get_tree().root.size = DisplayServer.screen_get_size()
	AudioServer.set_bus_volume_db(2, linear_to_db(float(bgmvol)/100.0))
	AudioServer.set_bus_volume_db(1, linear_to_db(float(sfxvol)/100.0))
	if gm != null: gm.configureCRTFilter(CRTfilter)

func findHighScoreGroup(trackName: String) -> HighScoreGroup:
	var outhsGroup: HighScoreGroup = null
	for i in range(len(highScores)):
		if trackName == highScores[i].name:
			outhsGroup = highScores[i]
	return outhsGroup

func loadHighScoreFile(fileName: String, hsgroup: HighScoreGroup) -> void:
	var fullFilename := scoreFilePath + fileName + scoreFileExtension
	if FileAccess.file_exists(fullFilename):
		# Note: Obviously this encryption is not foolproof, but it should protect against casual editing
		# Although I imagine a decryption program is easy enough to write...
		var scoreFile: FileAccess = FileAccess.open_encrypted_with_pass(fullFilename, FileAccess.READ, scoreFilePassword)
		var magicCheck := scoreFile.get_buffer(4).get_string_from_utf8()
		if magicCheck != scoreFileID: #magic number is wrong -> corrupt file? -> don't read
			scoreFile.close()
			return
		var versionCheck := scoreFile.get_buffer(2).get_string_from_utf8()
		match versionCheck: #new versions are created if the format is updated and a new release is created
			"29":
				var numScores: int = scoreFile.get_32()
				hsgroup.highScores.resize(numScores)
				hsgroup.name = scoreFile.get_pascal_string()
				for i in range(numScores):
					hsgroup.highScores[i].score = scoreFile.get_32()
					# stage in upper 8 bits, time in lower 24 bits
					var stgandt: int = scoreFile.get_32()
					hsgroup.highScores[i].stage = (stgandt >> 24) & 0xFF
					hsgroup.highScores[i].time = stgandt & 0x00FFFFFF
					hsgroup.highScores[i].name = scoreFile.get_pascal_string()
			_: #invalid version -> corrupt file? -> don't read
				scoreFile.close()
				writeDefaultConfig()
				return
		scoreFile.close()

func saveHighScoreFile(fileName: String, hsgroup: HighScoreGroup) -> void:
	var fullFilename := scoreFilePath + fileName + scoreFileExtension
	# Note: Obviously this encryption is not foolproof, but it should protect against casual editing
	# Although I imagine a decryption program is easy enough to write...
	var scoreFile: FileAccess = FileAccess.open_encrypted_with_pass(fullFilename, FileAccess.WRITE, scoreFilePassword)
	scoreFile.store_string(scoreFileID)
	scoreFile.store_string(scoreFileVersion)
	scoreFile.store_32(len(hsgroup.highScores))
	scoreFile.store_pascal_string(hsgroup.name)
	for i in range(len(hsgroup.highScores)):
		scoreFile.store_32(hsgroup.highScores[i].score)
		# stage in upper 8 bits, time in lower 24 bits
		var stgandt: int = (hsgroup.highScores[i].time & 0x00FFFFFF) | (hsgroup.highScores[i].stage << 24)
		scoreFile.store_32(stgandt)
		scoreFile.store_pascal_string(hsgroup.highScores[i].name)
	scoreFile.close()

func resetHighScores() -> void:
	var easyTrack: TrackDefinition = load("res://Data/Tracks/easy.tres")
	var mediumTrack: TrackDefinition = load("res://Data/Tracks/medium.tres")
	var testTrack: TrackDefinition = load("res://Data/Tracks/test.tres")
	var defaultHS: HighScoreGroup = load("res://Data/defaultHighScoreGroup.tres")
	highScores[0] = easyTrack.defaultHighScores.duplicate(true)
	highScores[1] = mediumTrack.defaultHighScores.duplicate(true)
	highScores[2] = defaultHS.duplicate(true)
	highScores[3] = defaultHS.duplicate(true)
	highScores[4] = testTrack.defaultHighScores.duplicate(true)
	highScores[2].name = "HARD"
	highScores[3].name = "INSANE"
	saveHighScoreFile(easyTrack.scoreFileName, highScores[0])
	saveHighScoreFile(mediumTrack.scoreFileName, highScores[1])
	saveHighScoreFile(testTrack.scoreFileName, highScores[4])

func _ready():
	var screenSize := DisplayServer.screen_get_size()
	var wratio: float = screenSize.x / 320.0
	var hratio: float = screenSize.y / 240.0
	maxRes = minf(wratio, hratio)
	lastHighScoreName = ""
	readConfig()
	setAccordingToConfigSettings()
	if not DirAccess.dir_exists_absolute(scoreFilePath):
		DirAccess.make_dir_absolute(scoreFilePath)	
	highScores.resize(5)
	var easyTrack: TrackDefinition = load("res://Data/Tracks/easy.tres")
	var mediumTrack: TrackDefinition = load("res://Data/Tracks/medium.tres")
	var testTrack: TrackDefinition = load("res://Data/Tracks/test.tres")
	var defaultHS: HighScoreGroup = load("res://Data/defaultHighScoreGroup.tres")
	highScores[0] = easyTrack.defaultHighScores.duplicate(true)
	highScores[0].highScores = easyTrack.defaultHighScores.highScores.duplicate(true)
	for i in range(len(highScores[0].highScores)):
		highScores[0].highScores[i]= easyTrack.defaultHighScores.highScores[i].duplicate(true)
	highScores[1] = mediumTrack.defaultHighScores.duplicate(true)
	highScores[1].highScores = mediumTrack.defaultHighScores.highScores.duplicate(true)
	for i in range(len(highScores[1].highScores)):
		highScores[1].highScores[i]= mediumTrack.defaultHighScores.highScores[i].duplicate(true)
	highScores[2] = defaultHS.duplicate(true)
	highScores[2].highScores = defaultHS.highScores.duplicate(true)
	for i in range(len(highScores[2].highScores)):
		highScores[2].highScores[i]= defaultHS.highScores[i].duplicate(true)
	highScores[3] = defaultHS.duplicate(true)
	highScores[3].highScores = defaultHS.highScores.duplicate(true)
	for i in range(len(highScores[3].highScores)):
		highScores[3].highScores[i]= defaultHS.highScores[i].duplicate(true)
	highScores[4] = testTrack.defaultHighScores.duplicate(true)
	highScores[4].highScores = testTrack.defaultHighScores.highScores.duplicate(true)
	for i in range(len(highScores[4].highScores)):
		highScores[4].highScores[i]= testTrack.defaultHighScores.highScores[i].duplicate(true)
	highScores[2].name = "HARD"
	highScores[3].name = "INSANE"
	loadHighScoreFile(easyTrack.scoreFileName, highScores[0])
	loadHighScoreFile(mediumTrack.scoreFileName, highScores[1])
	loadHighScoreFile(testTrack.scoreFileName, highScores[4])
