extends Control

@export var letters: Array[Node2D]
@export var wavelength: float
@export var period: float
@export var amplitude: float
@export var colourWavelength: float
@export var colourPeriod: float
var t: float
var k: float
var w: float
var ck: float
var cf: float


func _ready() -> void:
	k = (2.0*PI)/wavelength
	w = (2.0*PI)/period
	ck = 1.0/colourWavelength
	cf = 1.0/colourPeriod
	t = 0.0

func _process(delta: float) -> void:
	for i in range(len(letters)):
		letters[i].position.y = -amplitude*sin(k*i*16.0 - w*t) #Just your normal everyday wave
		var rainbowcol := cf*t - ck*i
		if (rainbowcol >= 1.0): rainbowcol -= 1.0
		elif (rainbowcol < 0.0): rainbowcol += 1.0
		letters[i].modulate = Color.from_hsv(rainbowcol, 1.0, 1.0)
	t += delta
