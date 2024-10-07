#Literally just a stub
extends BambooTrackerPlayer

func _ready():
	module = load("res://Sounds/BGM/MagicalRacewayOST.btm")
	bus = &"BGM"
	PlayNewModule()
