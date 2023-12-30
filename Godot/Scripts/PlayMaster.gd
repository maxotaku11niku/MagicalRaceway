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

enum
{
	CSTATE_NOTCRASHING,
	CSTATE_FLYING,
	CSTATE_ROLLING,
	CSTATE_LYING,
	CSTATE_RESETTING
}

enum
{
	PSFX_HIT = 0,
	PSFX_CHECK = 1,
	PSFX_FLYBY = 2,
	PSFX_SMACK = 3
}

@export var currentTrack: TrackDefinition
@export var splineRenderer: SplineRenderer
@export var playUI: PlayUI
@export var countdownSprite: AnimatedSprite2D
@export var playerSprite: PlayerCharacter
@export var accelPower: float
@export var brakePower: float
@export var turnPower: float
@export var dragFactor: float
@export var offRoadDragFactor: float
@export var centrifugalFactor: float
@export var collisionStrength: float
@export var oneShotSFXPlayers: Array[AudioStreamPlayer]
var state: int
var time: float
var dist: float
var pspriteDepth: float
var lastCheckDist: float
var nextCheckDist: float
var isFinalStage: bool
var stageNum: int
var displayScore: int
var score: float
var edgeGrazeMult: float
var xpos: float
var yspeed: float
var centrifugalBalance: float
var accumulatedXOffset: float

var lastCollisionAngle: float
var lastCollisionSpeedDelta: float
var canCollide: bool
var crashStage: int
var timeToReset: float
var resetXpos: float
var resetFromXpos: float

var runTimer: bool

func _ready() -> void:
	state = PSTATE_COUNTDOWN
	countdownSprite.visible = true
	countdownSprite.stop()
	countdownSprite.play(&"default")
	dist = 0.0
	xpos = 0.0
	yspeed = 0.0
	accumulatedXOffset = 0.0
	edgeGrazeMult = 1.0
	canCollide = true
	crashStage = CSTATE_NOTCRASHING
	pspriteDepth = (playerSprite.colBox.shape as RectangleShape2D).size.y/2.0
	splineRenderer.turnStrList = currentTrack.turnStrList
	splineRenderer.pitchStrList = currentTrack.pitchStrList
	splineRenderer.splitAmtList = currentTrack.splitAmtList
	splineRenderer.colourList = currentTrack.colourList
	splineRenderer.bgList = currentTrack.bgList
	splineRenderer.spriteList = currentTrack.spriteList
	splineRenderer.Reset()
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
	var steerStrength: float = 0.0
	var accelAmount: float = 0.0
	var brakeAmount: float = 0.0
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
					score += 200000.0
					playUI.displayTimeBonus(currentTrack.timeList[stageNum].val)
					stageNum += 1
					oneShotSFXPlayers[PSFX_CHECK].play()
			if playerSprite.animationType == PlayerCharacter.PASTATE_NORMAL or playerSprite.animationType == PlayerCharacter.PASTATE_SKID:
				accelAmount = Input.get_action_strength("accel")
				brakeAmount = Input.get_action_strength("brake")
				steerStrength = Input.get_action_strength("steer_right") - Input.get_action_strength("steer_left")
			elif playerSprite.animationType == PlayerCharacter.PASTATE_SPIN:
				steerStrength = lastCollisionSpeedDelta * collisionStrength * sin(lastCollisionAngle)/turnPower
			elif playerSprite.animationType == PlayerCharacter.PASTATE_CRASH:
				match crashStage:
					CSTATE_ROLLING:
						brakeAmount = 1.0
						if yspeed <= 0.0:
							oneShotSFXPlayers[PSFX_SMACK].stop()
							timeToReset = 1.0
							crashStage = CSTATE_LYING
							yspeed = 0.0
							playerSprite.stopAfterRoll()
					CSTATE_LYING:
						timeToReset -= delta
						if timeToReset <= 0.0:
							timeToReset = 1.0
							resetFromXpos = xpos
							resetXpos = splineRenderer.curSplit * (1.0 if xpos >= 0.0 else -1.0)
							playerSprite.visSprite.visible = false
							crashStage = CSTATE_RESETTING
					CSTATE_RESETTING:
						timeToReset -= delta
						xpos = lerpf(resetXpos, resetFromXpos, timeToReset)
						if timeToReset <= 0.0:
							canCollide = true
							playerSprite.visSprite.visible = true
							playerSprite.logicalPosition.y = 8.0
							crashStage = CSTATE_NOTCRASHING
							playerSprite.animationType = PlayerCharacter.PASTATE_NORMAL
			yspeed += (accelAmount * accelPower - brakeAmount * brakePower) * delta
			if yspeed <= 0.0: yspeed = 0.0
			var xspeed: float = turnPower * steerStrength
			var centrifugalForce: float = - centrifugalFactor * yspeed * yspeed * splineRenderer.curXcurve
			centrifugalBalance = (xspeed + centrifugalForce) * delta
			xpos += centrifugalBalance
			if xspeed != 0.0: centrifugalBalance *= signf(xspeed)
			else: centrifugalBalance *= signf(splineRenderer.curXcurve)
			playerSprite.setSkidding(centrifugalBalance < 0.0 and absf(steerStrength) > 0.95)
			var onRoad: bool = splineRenderer.IsPlayerOnRoad()
			edgeGrazeMult = splineRenderer.GetEdgeGrazeMultiplier(centrifugalForce) if onRoad else 1.0
			score += pow(yspeed, 1.4) * edgeGrazeMult * delta
			dist += delta * yspeed
			accumulatedXOffset -= splineRenderer.curXcurve * yspeed * delta
			var dfac: float = dragFactor if onRoad else offRoadDragFactor
			yspeed -= delta * dfac * yspeed * yspeed * signf(yspeed)
			if runTimer: time -= delta
			if xpos > splineRenderer.curSplit + 128.0:
				playUI.displayGoBackNotif(true, 1)
			elif xpos < -splineRenderer.curSplit - 128.0:
				playUI.displayGoBackNotif(true, -1)
			else:
				playUI.displayGoBackNotif(false, 0)
	splineRenderer.dist = dist
	splineRenderer.xpos = xpos
	splineRenderer.SetBGOffsets(accumulatedXOffset)
	displayScore = score
	var stageProg: float = (dist - lastCheckDist) / (nextCheckDist - lastCheckDist)
	playerSprite.animationSpeed = yspeed * 0.002
	playerSprite.animationDir = steerStrength
	playerSprite.logicalPosition.x = xpos
	playUI.updateMainUI(displayScore, time, yspeed/3.0, stageNum, stageProg, isFinalStage, edgeGrazeMult)
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
			canCollide = true
			crashStage = CSTATE_NOTCRASHING
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

func _onPlayerCollideWithObject(area: Area2D) -> void:
	if not canCollide: return
	oneShotSFXPlayers[PSFX_HIT].play()
	if area is RoadSprite: #static sprite
		var rsprite := area as RoadSprite
		var backSet: float = ((rsprite.colBox.shape as RectangleShape2D).size.y/2.0) - rsprite.logicalPosition.z + pspriteDepth + 1.0
		if yspeed < 60.0: #low speed -> stop and push back
			dist -= backSet
			accumulatedXOffset += splineRenderer.curXcurve * backSet
			yspeed = 0.0
		elif yspeed < 600.0: #medium speed -> spin out
			lastCollisionSpeedDelta = yspeed
			lastCollisionAngle = atan2(xpos - rsprite.logicalPosition.x, rsprite.logicalPosition.z)
			yspeed -= yspeed * collisionStrength * cos(lastCollisionAngle)
			canCollide = false
			playerSprite.spinOut()
		else: #high speed -> crash
			canCollide = false
			crashStage = CSTATE_FLYING
			playerSprite.crash()
	elif area is AnimatedRoadSprite: #dynamic sprite
		pass

func _onPlayerStoppedSpinning() -> void:
	canCollide = true

func _onPlayerLandedAfterCrash() -> void:
	crashStage = CSTATE_ROLLING
	oneShotSFXPlayers[PSFX_SMACK].play()
