extends Node

const configID = "MRCF"
const configVersion = "29"
const configPath = "user://init.cfg"

enum
{
	CHIP_NONE,
	CHIP_YM2203,
	CHIP_YM2608
}

var maxRes: int #Highest allowable resolution multiplier, from the dimensions of the screen
var fullscreen: bool
var resmult: int
var bgmvol: int
var sfxvol: int
var emuchip: int
var accelhold: bool

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
	cfgFile.close()

func writeDefaultConfig() -> void:
	fullscreen = false
	resmult = 2
	bgmvol = 100
	sfxvol = 100
	emuchip = CHIP_YM2608
	accelhold = false
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
			_: #invalid version -> corrupt file? -> rewrite defaults
				cfgFile.close()
				writeDefaultConfig()
				return
		cfgFile.close()
	else: #no init.cfg -> create default one
		writeDefaultConfig()

func setAccordingToConfigSettings() -> void:
	get_tree().root.mode = Window.MODE_FULLSCREEN if fullscreen else Window.MODE_WINDOWED
	get_tree().root.size = Vector2i(320 * resmult, 240 * resmult)
	AudioServer.set_bus_volume_db(2, linear_to_db(float(bgmvol)/100.0))
	AudioServer.set_bus_volume_db(1, linear_to_db(float(sfxvol)/100.0))

func _ready():
	var screenSize := DisplayServer.screen_get_size()
	var wratio: float = screenSize.x / 320.0
	var hratio: float = screenSize.y / 240.0
	maxRes = minf(wratio, hratio)
	readConfig()
	setAccordingToConfigSettings()

func _process(delta):
	pass
