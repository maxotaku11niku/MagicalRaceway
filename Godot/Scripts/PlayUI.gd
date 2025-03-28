class_name PlayUI
extends Control

@export var MainUI: Control
@export var DevScreen: Control
@export var CheckPointNotification: Control
@export var GoBackNotification: Control
@export var PauseUI: Control
@export var GameoverNotification: Control
@export var WinNotification: Control
@export var ScoreEntryUI: Control
@export var DidntMakeLeaderboardNotification: Control
@export var PlayerHasBeenAFilthyCheaterNotification: Control
# Main UI elements
var scoreNum: Label
var timeNum: Label
var speedNum: Label
var stageNum: Label
var stageProgBar: TextureProgressBar
var barSteps: float
var curStageNum: Label
var nextStageNum: Label
var girlFigure: TextureRect
var figureInitPos: Vector2
var grazeNum: Label
# Time bonus after passing a checkpoint
var timeBonusNum: Label
var timeLeftToDisplayTimeBonus: float
# Direction to the track
var goBackDir: Sprite2D
# Win notification
var bonusTimeLeft: Label
var perSecondBonus: Label
# Score entry UI elements
var newEntry: HighScoreEntry
var textPointer: Sprite2D
var entryExplanation: Label
# Pause buttons
var backToGameButton: Button
var quitToMenuButton: Button
# Dev debug panel elements
var distNum: Label
var nextCheckNum: Label
var xoffNum: Label
var timeNumD: Label
var turnNum: Label
var splitNum: Label
var pitchNum: Label
var balanceNum: Label

func updateMainUI(dScore: int, timeLeft: int, dSpeed: int, stage: int, stageProg: float, isFinalStage: bool, grazeMult: float) -> void:
	if dScore <= 0: scoreNum.text = "0"
	else: scoreNum.text = "%d0" % dScore
	if timeLeft <= 0.0: timeNum.text = "0"
	else: timeNum.text = "%d" % timeLeft
	speedNum.text = "%d" % dSpeed
	stageNum.text = "%d" % stage
	grazeNum.text = "x%.3f" % grazeMult
	curStageNum.text = "%d" % stage
	if isFinalStage: nextStageNum.text = "G"
	else: nextStageNum.text = "%d" % (stage + 1)
	stageProg = clampf(stageProg, 0.0, 1.0)
	var barfill: float = barSteps * stageProg
	stageProgBar.value = 6.0 + barfill
	girlFigure.position = figureInitPos + Vector2(barfill, 0.0)

func updateWinNotif(timeLeft: int) -> void:
	if timeLeft <= 0.0: bonusTimeLeft.text = "0"
	else: bonusTimeLeft.text = "%d" % timeLeft

func updateScoreEntryScreen(newHighScore: HighScore, cursorPos: int) -> void:
	newEntry.SetHighScore(newHighScore)
	textPointer.position.x = 8.0 + 8.0 * cursorPos

func updateScoreEntryDone() -> void:
	entryExplanation.text = "Score saved successfully!"

func updateDevScreen(dist: float, nextCheck: float, xoff: float, time: float, turnStr: float, split: float, pitchStr: float, cfugb: float) -> void:
	if not DevScreen.visible: return
	distNum.text = "%d" % dist
	nextCheckNum.text = "%d" % nextCheck
	xoffNum.text = "%+.2f" % xoff
	timeNumD.text = "%.2f" % time
	turnNum.text = "%+.5f" % turnStr
	splitNum.text = "%.2f" % split
	pitchNum.text = "%+.5f" % pitchStr
	balanceNum.text = "%+.4f" % cfugb

func displayTimeBonus(bonus: int) -> void:
	timeLeftToDisplayTimeBonus = 2.0
	timeBonusNum.text = "%d" % bonus
	CheckPointNotification.visible = true

func displayGoBackNotif(display: bool, dir: int) -> void:
	GoBackNotification.visible = display
	if display:
		goBackDir.region_rect.position.x = 0 if dir > 0 else 8

func displayGameoverNotif(display: bool) -> void:
	GameoverNotification.visible = display

func displayWinNotif(display: bool, bonusPerSecond: int = 0) -> void:
	WinNotification.visible = display
	if display:
		perSecondBonus.text = "x%d0" % bonusPerSecond

func displayDidntMakeLeaderboardNotif(display: bool) -> void:
	DidntMakeLeaderboardNotification.visible = display
	MainUI.visible = not display

func ThePlayerHasBeenACheaterSoWeMustLetThemKnowThatTheyveBeenACheater(display: bool) -> void:
	PlayerHasBeenAFilthyCheaterNotification.visible = display
	MainUI.visible = not display

func displayScoreEntryScreen(display: bool, newHighScore: HighScore) -> void:
	ScoreEntryUI.visible = display
	newEntry.SetHighScore(newHighScore)
	MainUI.visible = not display

func displayPauseScreen(display: bool) -> void:
	PauseUI.visible = display
	if display:
		backToGameButton.grab_focus.call_deferred()

func _ready() -> void:
	DevScreen.visible = false
	CheckPointNotification.visible = false
	GoBackNotification.visible = false
	timeLeftToDisplayTimeBonus = 0.0
	
	scoreNum = MainUI.find_child("ScoreNum")
	timeNum = MainUI.find_child("TimeNum")
	speedNum = MainUI.find_child("SpeedNum")
	stageNum = MainUI.find_child("StageNum")
	grazeNum = MainUI.find_child("GrazeNum")
	stageProgBar = MainUI.find_child("StageProgressBar")
	curStageNum = stageProgBar.find_child("CurrentStageNum")
	nextStageNum = stageProgBar.find_child("NextStageNum")
	girlFigure = stageProgBar.find_child("GirlFigure")
	barSteps = stageProgBar.max_value - 6.0
	figureInitPos = girlFigure.position
	
	timeBonusNum = CheckPointNotification.find_child("TimeBonusNum")
	goBackDir = GoBackNotification.find_child("GoBackDir")
	
	bonusTimeLeft = WinNotification.find_child("TimeLeftCounter")
	perSecondBonus = WinNotification.find_child("PerSecondBonus")
	
	newEntry = ScoreEntryUI.find_child("HighScoreEntry")
	textPointer = ScoreEntryUI.find_child("Pointer")
	entryExplanation = ScoreEntryUI.find_child("Explanation")
	
	backToGameButton = PauseUI.find_child("BackButton")
	quitToMenuButton = PauseUI.find_child("QuitButton")
	
	distNum = DevScreen.find_child("DistanceNum")
	nextCheckNum = DevScreen.find_child("NextCheckNum")
	xoffNum = DevScreen.find_child("XOffNum")
	timeNumD = DevScreen.find_child("TimeNum")
	turnNum = DevScreen.find_child("TurnNum")
	splitNum = DevScreen.find_child("SplitNum")
	pitchNum = DevScreen.find_child("PitchNum")
	balanceNum = DevScreen.find_child("BalanceNum")

func _process(delta: float) -> void:
	if CheckPointNotification.visible:
		timeLeftToDisplayTimeBonus -= delta
		if timeLeftToDisplayTimeBonus <= 0.0:
			CheckPointNotification.visible = false
	if Input.is_action_just_pressed("dev_special"):
		DevScreen.visible = false if DevScreen.visible else true
