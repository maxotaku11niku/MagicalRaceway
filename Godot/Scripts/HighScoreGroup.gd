class_name HighScoreGroup
extends Resource

@export var name: String
@export var highScores: Array[HighScore]

func CanAddNewHighScore(hs: HighScore) -> bool:
	if hs.score > highScores[len(highScores) - 1].score:
		return true
	elif hs.score == highScores[len(highScores) - 1].score:
		return hs.time <= highScores[len(highScores) - 1].time
	else: return false

func TryAddNewHighScore(hs: HighScore) -> bool:
	if CanAddNewHighScore(hs):
		var pos: int = len(highScores) - 1
		for i in range(pos - 1, -1, -1):
			if hs.score < highScores[i].score:
				break
			elif hs.score == highScores[i].score:
				if hs.time > highScores[i].time:
					break
			pos = i
		for i in range(len(highScores) - 1, pos, -1):
			highScores[i] = highScores[i-1]
		highScores[pos] = hs
		return true
	else: return false
