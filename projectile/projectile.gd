extends CharacterBody2D

@onready var mat: ShaderMaterial = $Sprite2D.material
@onready var wall_hit_sound: AudioStreamPlayer2D = $WallHitSound

var speed := 300.0
var dir = Vector2.DOWN
var is_active = true
var spin_strength = 0.015
var heavy_mode: bool = false
var chain_lightning: bool = false

static var chain_lightning_unlocked: bool = false

func _ready() -> void:
	add_to_group("ball")
	speed = speed + (20 * GameManager.level)
	velocity = Vector2(speed * -1, speed)
	GameManager.register_ball(self)
	if chain_lightning_unlocked:
		chain_lightning = true

func _physics_process(delta: float) -> void:
	if is_active:
		var collision := move_and_collide(velocity * delta)

		if collision:
			var collider := collision.get_collider()

			if collider.is_in_group("paddle"):
				_bounce_off_paddle(collider)
				_play_wall_hit_sound()
			else:
				if collider.is_in_group("brick"):
					if heavy_mode:
						if collider.has_method("hit"):
							collider.hit()
					else:
						velocity = velocity.bounce(collision.get_normal())
						if collider.has_method("hit"):
							collider.hit()
						if collider.has_method("flash_hit"):
							collider.flash_hit(collision.get_position())
					_play_wall_hit_sound()
					if chain_lightning and collider is Node2D:
						_trigger_chain_lightning(collider)
				else:
					velocity = velocity.bounce(collision.get_normal())
					_play_wall_hit_sound()

		# Prevent boring near-vertical drifts
		if velocity.y > 0 and velocity.y < 100:
			velocity.y = -200
		if velocity.x == 0:
			velocity.x = -200

		rotation += velocity.length() * spin_strength * delta

	mat.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)


func _play_wall_hit_sound() -> void:
	wall_hit_sound.play()

func die_in_void() -> void:
	if not is_active:
		return
	is_active = false
	GameManager.unregister_ball()
	queue_free()


func launch(direction: Vector2) -> void:
	is_active = true
	speed = 300.0 + (20 * GameManager.level)
	velocity = direction.normalized() * speed


func enable_heavy_mode() -> void:
	heavy_mode = true

func enable_chain_lightning() -> void:
	chain_lightning = true
	chain_lightning_unlocked = true
	
func _bounce_off_paddle(paddle: Node2D) -> void:
	var paddle_width := 100.0 # ideally match your paddle sprite width

	# How far from center did we hit?
	var offset := (global_position.x - paddle.global_position.x) / (paddle_width * 0.5)
	offset = clamp(offset, -1.0, 1.0)

	# Convert offset to angle (up-left to up-right)
	var min_angle := deg_to_rad(150.0)
	var max_angle := deg_to_rad(30.0)
	var angle: float = lerp(min_angle, max_angle, (offset + 1.0) * 0.5)

	var speed_now := velocity.length()
	velocity = Vector2(cos(angle), -sin(angle)) * speed_now

	# Add paddle horizontal velocity influence
	var paddle_vel_x := 0.0
	if paddle.has_method("get_velocity"):
		paddle_vel_x = paddle.get_velocity().x

	velocity.x += paddle_vel_x * 0.25
	velocity = velocity.normalized() * speed_now
	

func _trigger_chain_lightning(start_brick: Node2D, jumps: int = 3, range: float = 150.0) -> void:
	if !is_instance_valid(start_brick):
		return

	var current_pos: Vector2 = start_brick.global_position
	var remaining := jumps

	while remaining > 0:
		var next := _get_closest_brick(current_pos, range)
		if next == null:
			break

		var next_pos: Vector2 = next.global_position

		_show_lightning(current_pos, next_pos)

		if next.has_method("hit"):
			next.hit()

		# From now on we only remember the **position**, not the node
		current_pos = next_pos
		remaining -= 1

		# tiny delay so the chain "steps" visually
		await get_tree().create_timer(0.05).timeout


func _get_closest_brick(from_pos: Vector2, range: float) -> Node2D:
	var closest: Node2D = null
	var closest_dist := range

	for b in get_tree().get_nodes_in_group("brick"):
		if !is_instance_valid(b):
			continue
		if !(b is Node2D):
			continue

		var brick := b as Node2D
		var col := brick.get_node_or_null("CollisionShape2D")
		if col and col.disabled:
			continue

		var d := from_pos.distance_to(brick.global_position)
		if d < closest_dist:
			closest = brick
			closest_dist = d

	return closest
	
func _show_lightning(a: Vector2, b: Vector2) -> void:
	var line := Line2D.new()
	line.width = 3.0
	line.default_color = Color(0.7, 0.9, 1.0)
	line.points = PackedVector2Array([a, b])
	get_tree().current_scene.add_child(line)
	await get_tree().create_timer(0.08).timeout
	if is_instance_valid(line):
		line.queue_free()
