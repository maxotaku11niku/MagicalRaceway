class_name HighScore
extends Resource

@export var name: String
@export var score: int #premultiplied by 10
@export var stage: int
@export var time: int #in units of centiseconds

func SetFromRaw(sc: float, st: int, t: float) -> void:
	score = int(floorf(sc))
	stage = st
	time = int(ceilf(t * 100.0))

func GetFormattedScore() -> String:
	return "%d0" % score

func GetFormattedStage() -> String:
	return "%2d" % stage

func GetFormattedTime() -> String:
	return "%2d'%02d.%02d\"" % [time/6000, (time/100)%60, time%100]
