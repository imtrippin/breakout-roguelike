extends Node

var score = 0
var level = 1

func add_points(points):
	score += points
	
func _process(_delta: float) -> void:
	$CanvasLayer/Score.text = str(score)
	$CanvasLayer/Level.text = "Level: "+ str(level)
