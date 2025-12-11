extends CharacterBody2D
@onready var player: CharacterBody2D = $"."

var speed:= 800.0
var fixed_y := 0.0

func _ready() -> void:
	fixed_y = global_position.y
	
func _physics_process(_delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed
	velocity.y = 0
	move_and_slide()
	global_position.y = fixed_y
	
	
func hit() -> void:
	$AudioStreamPlayer2D.play()

func upgrade_width(_amount: float) -> void:
	_update_width()
	
func _update_width() -> void:
	player.scale.x = player.scale.x * 2
	get_tree()
