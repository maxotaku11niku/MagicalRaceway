extends MenuScreen

@export var songTitleLabel: Label
@export var songDescLabel: Label
@export var pianoTilemap: TileMap
@export_multiline var songDescriptions: PackedStringArray

var retriggerInvisPeriods: PackedFloat64Array
var currentSelectedSong: int

func _ready():
	currentSelectedSong = MusicMaster.currentSongNumber
	songTitleLabel.text = "%d: %s" % [currentSelectedSong + 1, MusicMaster.module.songNames[currentSelectedSong]]
	songDescLabel.text = songDescriptions[currentSelectedSong]
	retriggerInvisPeriods.resize(9)
	for i in range(0, 9):
		retriggerInvisPeriods[i] = -1.0

func _process(delta):
	sigFocusOnNewControl.emit(songTitleLabel, false)
	if Input.is_action_just_pressed("ui_left"):
		currentSelectedSong -= 1
		if (currentSelectedSong < 0): currentSelectedSong = MusicMaster.module.numberOfSongs - 1
	elif Input.is_action_just_pressed("ui_right"):
		currentSelectedSong += 1
		if (currentSelectedSong >= MusicMaster.module.numberOfSongs): currentSelectedSong = 0
	if Input.is_action_just_pressed("ui_accept"):
		MusicMaster.PlaySong(currentSelectedSong, true)
		songDescLabel.text = songDescriptions[currentSelectedSong]
		for i in range(0, 9):
			retriggerInvisPeriods[i] = -1.0
	songTitleLabel.text = "%d: %s" % [currentSelectedSong + 1, MusicMaster.module.songNames[currentSelectedSong]]
	if (MusicMaster.currentSongNumber == currentSelectedSong): songTitleLabel.modulate = Color8(0x77, 0xFF, 0x77)
	else: songTitleLabel.modulate = Color8(0xFF, 0xFF, 0xFF)
	for i in range(0, 9):
		if (retriggerInvisPeriods[i] > 0.0):
			retriggerInvisPeriods[i] -= delta
			continue
		var note: int = MusicMaster.GetNote(i)
		if (note < 0):
			for j in range(0, 8):
				pianoTilemap.set_cell(0, Vector2i(j, i), 0, Vector2i(0, 0))
		elif (note >= 0x80):
			retriggerInvisPeriods[i] = 0.015
			retriggerInvisPeriods[i] -= delta
			for j in range(0, 8):
				pianoTilemap.set_cell(0, Vector2i(j, i), 0, Vector2i(0, 0))
		else:
			var realNote: int = note & 0x7F
			var oct: int = realNote / 12
			var suboct: int = realNote % 12
			for j in range(0, 8):
				if (j == oct): pianoTilemap.set_cell(0, Vector2i(j, i), 0, Vector2i(suboct % 2, 1 + (suboct/2)))
				else: pianoTilemap.set_cell(0, Vector2i(j, i), 0, Vector2i(0, 0))
		
