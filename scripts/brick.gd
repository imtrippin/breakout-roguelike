extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var mat: ShaderMaterial = sprite.material
@onready var combo_manager: Node = get_tree().get_root().get_node("/root/ComboManager")

var is_dead : bool = false

func hit(): 
	if is_dead:
		return
	is_dead = true
	GameManager.add_points(1)
	combo_manager.register_brick_hit()
	$AudioStreamPlayer2D.pitch_scale = randf_range(.5, 1.5)
	$AudioStreamPlayer2D.play()
	$CPUParticles2D.emitting = true
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = true
	
	var live_bricks := 0
	
	for b in get_tree().get_nodes_in_group("brick"):
		if !is_instance_valid(b):
			continue
		if !(b is RigidBody2D):
			continue
		var col := (b as RigidBody2D).get_node_or_null("CollisionShape2D")
		if col and !col.disabled:
			live_bricks += 1

	if live_bricks <= 0:
		for ball in get_tree().get_nodes_in_group("ball"):
			ball.is_active = false
		await get_tree().create_timer(1.0).timeout
		get_tree().root.get_node("Main").next_level()
	else:
		await get_tree().create_timer(1.0).timeout
		queue_free()
