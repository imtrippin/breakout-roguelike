extends Node2D
@onready var brick_object = preload("res://scenes/brick.tscn")


var columns = 32
var rows = 3
var margin = 50
# Called when the node enters the scene tree for the first time.\
func _ready() -> void:
	setup_level()
	
	
func setup_level():
	rows = 2 + GameManager.level
	
	if rows > 9:
		rows = 9
	
	var colors = get_colors()
	colors.shuffle()
	
	for r in rows:
		for c in columns:
			var random_number = randi_range(0,2)
			if random_number > 0:
			
				var new_brick = brick_object.instantiate()
				add_child(new_brick)
				new_brick.position = Vector2(margin + (34 * c), margin + (34 * r))
				
				var sprite = new_brick.get_node("Sprite2D")
				if r <= 9:
					sprite.modulate = colors[0]
				if r < 7:
					sprite.modulate = colors[1]
				if r < 4:
					sprite.modulate = colors[2]
					


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func get_colors():
	var colors = [
		Color( 0, 1, 1, 1),
		Color ( 0.54, .19, .87, 1),
		Color( 0.54, 1, 0.15, 1 ),
		Color (1, 1, 1, 1)
	]
	return colors
