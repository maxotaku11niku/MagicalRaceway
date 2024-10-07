extends MenuScreen

@export var trackLabel: Label
@export var entryScene: PackedScene

var entries: Array[HighScoreEntry]
var currentTrack: int

func _ready():
	entries.resize(20)
	for i in range(len(entries)):
		entries[i] = entryScene.instantiate() as HighScoreEntry
		add_child(entries[i])
		entries[i].position.x = 8
		entries[i].position.y = 40 + i * 8
		entries[i].SetHighScore(PersistentDataHandler.highScores[0].highScores[i])
	trackLabel.text = PersistentDataHandler.highScores[0].name
	currentTrack = 0

func _process(delta):
	sigFocusOnNewControl.emit(trackLabel, false)
	if Input.is_action_just_pressed("ui_left"):
		currentTrack -= 1
		if (currentTrack < 0): currentTrack = 4
	elif Input.is_action_just_pressed("ui_right"):
		currentTrack += 1
		if (currentTrack > 4): currentTrack = 0
	trackLabel.text = PersistentDataHandler.highScores[currentTrack].name
	for i in range(len(entries)):
		entries[i].SetHighScore(PersistentDataHandler.highScores[currentTrack].highScores[i])
