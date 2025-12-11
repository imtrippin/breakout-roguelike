extends Node


var score = 0
var level = 1

var first_upgrade_score: int = 5
var second_upgrade_score: int = 20
var third_upgrade_score: int = 30

var first_upgrade_given := false
var second_update_given := false
var third_update_given := false

#@onready var upgrade_menu: Control = $UpgradeMenu


func reset_run() -> void:
	print("reset run")
	score = 0
	level = 1
	first_upgrade_given = false
	second_update_given = false
	third_update_given = false
	first_upgrade_score = 5
	
func add_points(points):
	score += points
	if not first_upgrade_given and score >= first_upgrade_score:
		first_upgrade_given = true
		_show_first_upgrade()
	elif not second_update_given and score >= second_upgrade_score:
		second_update_given = true
		_show_second_upgrade()
	elif not third_update_given and score >= third_upgrade_score:
		third_update_given = true
		_show_second_upgrade()
		 	
func _process(_delta: float) -> void:
	$CanvasLayer/Score.text = str(score)
	$CanvasLayer/Level.text = "Level: "+ str(level)
	
func _show_first_upgrade() -> void:
	get_tree().paused = true
	var menu := get_tree().root.get_node("Main/UpgradeMenu") as Control
	if menu:
		menu.open_menu()
		
func _show_second_upgrade() -> void:
	get_tree().paused = true
	var menu := get_tree().root.get_node("Main/UpgradeMenu") as Control
	if menu:
		menu.open_menu()

func _show_third_upgrade() -> void:
	get_tree().paused = true
	var menu := get_tree().root.get_node("Main/UpgradeMenu") as Control
	if menu:
		menu.open_menu()	
