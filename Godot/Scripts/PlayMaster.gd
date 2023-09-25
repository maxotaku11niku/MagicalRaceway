extends Node

signal sigPlayEnd

enum
{
	PSTATE_COUNTDOWN,
	PSTATE_PLAY,
	PSTATE_PAUSED,
	PSTATE_TRANSITION_TO_SCORES,
	PSTATE_WIN,
	PSTATE_RETURN_TO_MENU,
	PSTATE_LEADERBOARD
}

@export var currentTrack: TrackDefinition
@export var splineRenderer: SplineRenderer
@export var playUI: PlayUI
@export var countdownSprite: AnimatedSprite2D
@export var accelPower: float
@export var brakePower: float
@export var turnPower: float
@export var dragFactor: float
@export var offRoadDragFactor: float
@export var centrifugalFactor: float
var state: int
var time: float
var dist: float
var lastCheckDist: float
var nextCheckDist: float
var isFinalStage: bool
var stageNum: int
var displayScore: int
var score: float
var xpos: float
var yspeed: float
var centrifugalBalance: float

var runTimer: bool

func _ready() -> void:
	state = PSTATE_COUNTDOWN
	countdownSprite.visible = true
	countdownSprite.stop()
	countdownSprite.play(&"default")
	dist = 0.0
	xpos = 0.0
	yspeed = 0.0
	splineRenderer.turnStrList = currentTrack.turnStrList
	splineRenderer.pitchStrList = currentTrack.pitchStrList
	splineRenderer.splitAmtList = currentTrack.splitAmtList
	splineRenderer.colourList = currentTrack.colourList
	score = 0.0
	stageNum = 1
	time = currentTrack.timeList[0].val
	runTimer = true
	lastCheckDist = currentTrack.timeList[0].dist
	if len(currentTrack.timeList) == 1:
		nextCheckDist = currentTrack.endDistance
		isFinalStage = true
	else:
		nextCheckDist = currentTrack.timeList[1].dist
		isFinalStage = false

func _process(delta: float) -> void:
	match state:
		PSTATE_COUNTDOWN:
			pass
		PSTATE_PLAY:
			if dist > nextCheckDist:
				if stageNum >= len(currentTrack.timeList):
					isFinalStage = true
				else:
					lastCheckDist = nextCheckDist
					if stageNum >= len(currentTrack.timeList) - 1:
						nextCheckDist = currentTrack.endDistance
						isFinalStage = true
					else:
						nextCheckDist = currentTrack.timeList[stageNum + 1].dist
						isFinalStage = false
					time += currentTrack.timeList[stageNum].val
					playUI.displayTimeBonus(currentTrack.timeList[stageNum].val)
					stageNum += 1
			var accelAmount: float = Input.get_action_strength("accel")
			var brakeAmount: float = Input.get_action_strength("brake")
			yspeed += (accelAmount * accelPower - brakeAmount * brakePower) * delta
			if yspeed <= 0.0: yspeed = 0.0
			var xspeed: float = turnPower * (Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left"))
			centrifugalBalance = (xspeed - centrifugalFactor * yspeed * yspeed * splineRenderer.curXcurve) * delta
			xpos += centrifugalBalance
			if xspeed != 0.0: centrifugalBalance *= signf(xspeed)
			else: centrifugalBalance *= signf(splineRenderer.curXcurve)
			score += pow(yspeed, 1.4) * delta
			dist += delta * yspeed
			yspeed -= delta * dragFactor * yspeed * yspeed * signf(yspeed)
			if runTimer: time -= delta
	splineRenderer.dist = dist
	splineRenderer.xpos = xpos
	displayScore = score
	var stageProg: float = (dist - lastCheckDist) / (nextCheckDist - lastCheckDist)
	playUI.updateMainUI(displayScore, time, yspeed/3.0, stageNum, stageProg, isFinalStage, 1.0)
	playUI.updateDevScreen(dist, 0.0, xpos, time, splineRenderer.curXcurve, splineRenderer.curSplit, splineRenderer.curYcurve, centrifugalBalance)
	if playUI.DevScreen.visible:
		if Input.is_action_just_pressed("dev_toggletimer"):
			runTimer = false if runTimer else true
		if Input.is_action_just_pressed("dev_skipcheck"):
			dist = nextCheckDist - 200.0
			yspeed = 600.0
		if Input.is_action_just_pressed("dev_resetplay"):
			state = PSTATE_COUNTDOWN
			countdownSprite.visible = true
			countdownSprite.stop()
			countdownSprite.play(&"default")
			dist = 0.0
			xpos = 0.0
			splineRenderer.dist = 0.0
			splineRenderer.xpos = 0.0
			yspeed = 0.0
			score = 0.0
			stageNum = 1
			time = currentTrack.timeList[0].val
			lastCheckDist = currentTrack.timeList[0].dist
			if len(currentTrack.timeList) == 1:
				nextCheckDist = currentTrack.endDistance
				isFinalStage = true
			else:
				nextCheckDist = currentTrack.timeList[1].dist
				isFinalStage = false
			splineRenderer.Reset()

func _onCountdownAnimationLooped() -> void:
	state = PSTATE_PLAY
	countdownSprite.visible = false
	countdownSprite.stop()
