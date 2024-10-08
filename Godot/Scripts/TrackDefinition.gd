class_name TrackDefinition
extends Resource
## Defines an entire single playable track

@export var trackName: String
@export var scoreFileName: String
@export var defaultHighScores: HighScoreGroup
@export var endDistance: float
@export var spriteSeparation: float
@export var separationFactor: float
@export var endScoreBonusFactor: float
@export var timeList: Array[FloatWithDistance]
@export var turnStrList: Array[FloatWithDistance]
@export var splitAmtList: Array[FloatWithDistance]
@export var pitchStrList: Array[FloatWithDistance]
@export var colourList: Array[ColourListWithDistance]
@export var bgList: Array[BGSpriteDefWithDistance]
@export var spriteList: Array[StaticSpriteDefWithDistance]
@export var stripList: Array[TexturedStripWithDistance]
