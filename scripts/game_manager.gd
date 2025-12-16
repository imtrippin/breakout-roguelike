extends Node
@onready var xp_bar: ColorRect = $CanvasLayer/XPBar
@onready var xp_mat : ShaderMaterial = xp_bar.material

var score: int = 0
var level: int = 1
var _displayed_fill: float = 0.0
var ball_count: int = 0   # how many balls are currently alive

func _ready() -> void:
	ProgressionManager.level_up.connect(_on_level_up)
	xp_mat.set_shader_parameter("segments", 10)
	_update_xp_bar()


func reset_run() -> void:
	print("reset run")
	score = 0
	level = 1
	ball_count = 0

	ProgressionManager.level = 1
	ProgressionManager.xp = 0
	ProgressionManager.xp_to_level = 10

	_update_xp_bar(true)
	
func add_points(points: int) -> void:
	score += points
	ProgressionManager.add_xp(points)


func _process(_delta: float) -> void:
	$CanvasLayer/Score.text = str(score)
	$CanvasLayer/Level.text = "Stage: " + str(level)
	$CanvasLayer/PlayerLevel.text = "Level: " + str(ProgressionManager.level)
	_update_xp_bar()


func _on_level_up(_level: int) -> void:
	_update_xp_bar()
	get_tree().paused = true
	var menu := get_tree().root.get_node("Main/UpgradeMenu") as Control
	if menu:
		menu.open_menu()


# ---- BALL TRACKING ----

func register_ball(ball: Node) -> void:
	ball_count += 1
	print("balls in play:", ball_count, "added:", ball, "id:", ball.get_instance_id())


func unregister_ball() -> void:
	ball_count -= 1
	if ball_count < 0:
		ball_count = 0
	print("balls in play:", ball_count)
	print("ball@ ", self)
	await get_tree().process_frame
	if ball_count == 0:
		game_over()


func game_over() -> void:
	print("GAME OVER")
	reset_run()
	get_tree().reload_current_scene()
	
func _update_xp_bar(force := false) -> void:
	var target_fill := 0.0
	if ProgressionManager.xp_to_level > 0:
		target_fill = float(ProgressionManager.xp) / ProgressionManager.xp_to_level

	if force:
		_displayed_fill = target_fill
	else:
		_displayed_fill = lerp(_displayed_fill, target_fill, 0.15)

	xp_mat.set_shader_parameter("fill", _displayed_fill)
