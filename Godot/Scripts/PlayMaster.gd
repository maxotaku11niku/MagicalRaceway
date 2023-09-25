extends Node

signal sigPlayEnd

@export var currentTrack: TrackDefinition
@export var splineRenderer: SplineRenderer
var dist: float
var xpos: float
var yspeed: float

func _ready() -> void:
	dist = 0.0
	xpos = 0.0
	yspeed = 0.0
	splineRenderer.turnStrList = currentTrack.turnStrList
	splineRenderer.pitchStrList = currentTrack.pitchStrList
	splineRenderer.splitAmtList = currentTrack.splitAmtList
	splineRenderer.colourList = currentTrack.colourList

func _process(delta: float) -> void:
	if (Input.is_action_pressed("accel")):
		yspeed += delta * 64.0
	if (Input.is_action_pressed("brake")):
		yspeed -= delta * 64.0
	if (Input.is_action_pressed("steer_left")):
		xpos -= delta * 64.0
	if (Input.is_action_pressed("steer_right")):
		xpos += delta * 64.0
	dist += delta * yspeed
	splineRenderer.dist = dist
	splineRenderer.xpos = xpos
