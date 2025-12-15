extends Node

signal level_up(level: int)

var level: int = 1
var xp: float = 0
var xp_to_level: float = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func add_xp(amount: float) -> void:
	xp += amount
	
	while xp >= xp_to_level:
		xp -= xp_to_level
		level += 1
		emit_signal("level_up", level)
		_increase_difficulty()

func _increase_difficulty() -> void:
	xp_to_level = round (xp_to_level * 1.35)
		
		
