extends RigidBody2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var mat: ShaderMaterial = sprite.material
@onready var combo_manager: Node = get_tree().get_root().get_node("/root/ComboManager")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func hit(): 

	GameManager.add_points(1)
	combo_manager.register_brick_hit()
	$AudioStreamPlayer2D.pitch_scale = randf_range(0.9, 1.1)
	$AudioStreamPlayer2D.play()
	$CPUParticles2D.emitting = true
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = true

	var bricks_left = get_tree().get_nodes_in_group("brick")
	
	if bricks_left.size() == 1:
		get_parent().get_node("Ball").is_active = false
		await get_tree().create_timer(1).timeout
		GameManager.level = GameManager.level + 1
		get_tree().reload_current_scene()
	else:
		
		await get_tree().create_timer(1).timeout
		queue_free()
