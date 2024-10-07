class_name HighScoreEntry
extends Control

@export var highScore: HighScore
@export var nameLabel: Label
@export var scoreLabel: Label
@export var stageLabel: Label
@export var timeLabel: Label

func SetHighScore(hs: HighScore) -> void:
	highScore = hs
	nameLabel.text = hs.name
	scoreLabel.text = hs.GetFormattedScore()
	stageLabel.text = hs.GetFormattedStage()
	timeLabel.text = hs.GetFormattedTime()
