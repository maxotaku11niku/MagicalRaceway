class_name PlayerCharacter
extends AnimatedRoadSprite

enum
{
	PASTATE_NORMAL,
	PASTATE_SKID,
	PASTATE_SPIN,
	PASTATE_CRASH
}

@export var flyingSoundPlayer: AudioStreamPlayer
@export var normalFlyingSound: AudioStream
@export var skiddingSound: AudioStream
var prevState: int
var stateTimer: float
var flyUpVel: float
var lyingOnFloor: bool

signal stopped_spinning()
signal landed_after_crash()

func setSkidding(skidState: bool) -> void:
	#Meaningless if spinning or crashing
	if animationType != PASTATE_NORMAL and animationType != PASTATE_SKID:
		return
	animationType = PASTATE_SKID if skidState else PASTATE_NORMAL

func spinOut() -> void:
	animationType = PASTATE_SPIN
	visSprite.play(&"spin")
	visSprite.flip_h = false
	stateTimer = 0.8

func crash() -> void:
	animationType = PASTATE_CRASH
	visSprite.play(&"fly_up")
	visSprite.flip_h = false
	lyingOnFloor = false
	flyUpVel = 80.0

func stopAfterRoll() -> void:
	visSprite.play(&"crashfinal")
	visSprite.flip_h = false

func _ready() -> void:
	prevState = PASTATE_NORMAL
	animationType = PASTATE_NORMAL
	flyingSoundPlayer.stream = normalFlyingSound
	visSprite.play(&"idle_front")
	visSprite.flip_h = false
	lyingOnFloor = false
	logicalPosition.y = 8.0

func _process(delta: float) -> void:
	if animationSpeed <= 0.0:
		flyingSoundPlayer.stop()
	else:
		if !flyingSoundPlayer.playing: flyingSoundPlayer.play()
		flyingSoundPlayer.pitch_scale = animationSpeed
	match animationType:
		PASTATE_NORMAL:
			lyingOnFloor = false
			if prevState != animationType: flyingSoundPlayer.stream = normalFlyingSound
			if animationSpeed > 0.6:
				if animationDir > 0.5:
					visSprite.play(&"fast_turnweak", animationSpeed)
					visSprite.flip_h = true
				elif animationDir >= -0.5:
					visSprite.play(&"fast_front", animationSpeed)
					visSprite.flip_h = false
				else:
					visSprite.play(&"fast_turnweak", animationSpeed)
					visSprite.flip_h = false
			elif animationSpeed > 0.2:
				if animationDir > 0.5:
					visSprite.play(&"slow_turnweak", animationSpeed)
					visSprite.flip_h = true
				elif animationDir >= -0.5:
					visSprite.play(&"slow_front", animationSpeed)
					visSprite.flip_h = false
				else:
					visSprite.play(&"slow_turnweak", animationSpeed)
					visSprite.flip_h = false
			else:
				if animationDir > 0.5:
					visSprite.play(&"idle_turnweak")
					visSprite.flip_h = true
				elif animationDir >= -0.5:
					visSprite.play(&"idle_front")
					visSprite.flip_h = false
				else:
					visSprite.play(&"idle_turnweak")
					visSprite.flip_h = false
		PASTATE_SKID:
			lyingOnFloor = false
			if prevState != animationType: flyingSoundPlayer.stream = skiddingSound
			visSprite.play(&"fast_turnstrong", animationSpeed)
			if animationDir > 0.0:
				visSprite.flip_h = true
			else:
				visSprite.flip_h = false
		PASTATE_SPIN:
			lyingOnFloor = false
			if prevState != animationType: flyingSoundPlayer.stream = skiddingSound
			stateTimer -= delta
			if stateTimer <= 0.0:
				animationType = PASTATE_NORMAL
				flyingSoundPlayer.stream = normalFlyingSound
				stopped_spinning.emit()
		PASTATE_CRASH:
			flyingSoundPlayer.stop()
			if not lyingOnFloor:
				logicalPosition.y += flyUpVel * delta
				flyUpVel -= 80.0 * delta
				if logicalPosition.y <= 0.0:
					visSprite.play(&"crashroll")
					visSprite.flip_h = false
					logicalPosition.y = 0.0
					flyUpVel = 0.0
					landed_after_crash.emit()
					lyingOnFloor = true
				else:
					if flyUpVel >= 10.0:
						visSprite.play(&"fly_up")
						visSprite.flip_h = false
					elif flyUpVel <= -10.0:
						visSprite.play(&"fly_down")
						visSprite.flip_h = false
					else:
						visSprite.play(&"fly_mid")
						visSprite.flip_h = false
	prevState = animationType
	colBox.position.x = logicalPosition.x
	screenPosition.y = 208.0 - logicalPosition.y
	colBox.position.y = logicalPosition.z
	visSprite.position = screenPosition
	visSprite.z_index = layer
