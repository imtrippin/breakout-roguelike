extends Node2D
@onready var brick_object = preload("res://scenes/brick.tscn")
@onready var paddle: CharacterBody2D = $Player
@onready var ball: CharacterBody2D = $Ball

var columns = 32
var rows = 3
var margin = 50
var changing_level := false

func _ready() -> void:
	setup_level()
	_reset_ball_and_paddle()

func setup_level() -> void:
	rows = 2 + GameManager.level
	if rows > 9:
		rows = 9

	var colors = get_colors()
	colors.shuffle()

	for r in rows:
		for c in columns:
			var random_number = randi_range(0, 2)
			if random_number > 0:
				var new_brick = brick_object.instantiate()
				add_child(new_brick)
				new_brick.position = Vector2(margin + (34 * c), margin + (34 * r))

				var sprite: Sprite2D = new_brick.get_node("Sprite2D")
				if r <= 9:
					sprite.modulate = colors[0]
				if r < 7:
					sprite.modulate = colors[1]
				if r < 4:
					sprite.modulate = colors[2]

func next_level() -> void:
	if changing_level:
		return
	changing_level = true

	GameManager.level += 1
	for brick in get_tree().get_nodes_in_group("brick"):
		brick.queue_free()
	_reset_ball_and_paddle()
	setup_level()
	

	changing_level = false
	
func _reset_ball_and_paddle() -> void:
	var viewport_width := get_viewport_rect().size.x
	paddle.global_position.x = viewport_width / 2.0

	var offset_y := -40.0
	ball.global_position = paddle.global_position + Vector2(0, offset_y)
	
	var speed := 400.0
	ball.velocity = Vector2(0, -speed)
	
	ball.launch(Vector2(0, -1))
	
	
func get_colors():
	return [
		Color(0, 1, 1, 1),
		Color(0.54, .19, .87, 1),
		Color(0.54, 1, 0.15, 1),
		Color(1, 1, 1, 1)
	]
