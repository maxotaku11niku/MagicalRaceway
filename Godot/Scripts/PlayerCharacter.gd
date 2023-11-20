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

func setSkidding(skidState: bool) -> void:
	#Meaningless if spinning or crashing
	if animationType != PASTATE_NORMAL and animationType != PASTATE_SKID:
		return
	animationType = PASTATE_SKID if skidState else PASTATE_NORMAL

func _ready() -> void:
	prevState = PASTATE_NORMAL
	animationType = PASTATE_NORMAL
	flyingSoundPlayer.stream = normalFlyingSound
	visSprite.play(&"idle_front")
	visSprite.flip_h = false

func _process(delta: float) -> void:
	if animationSpeed <= 0.0:
		flyingSoundPlayer.stop()
	else:
		if !flyingSoundPlayer.playing: flyingSoundPlayer.play()
		flyingSoundPlayer.pitch_scale = animationSpeed
	match animationType:
		PASTATE_NORMAL:
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
			if prevState != animationType: flyingSoundPlayer.stream = skiddingSound
			visSprite.play(&"fast_turnstrong", animationSpeed)
			if animationDir > 0.0:
				visSprite.flip_h = true
			else:
				visSprite.flip_h = false
	prevState = animationType
	
