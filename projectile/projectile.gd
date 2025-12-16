extends CharacterBody2D

@onready var mat: ShaderMaterial = $Sprite2D.material
@onready var wall_hit_sound: AudioStreamPlayer2D = $WallHitSound

var speed := 300.0
var dir = Vector2.DOWN
var is_active = true
var spin_strength = 0.015
var heavy_mode: bool = false

func _ready() -> void:
	add_to_group("ball")
	speed = speed + (20 * GameManager.level)
	velocity = Vector2(speed * -1, speed)
	GameManager.register_ball(self)  
	
func _physics_process(delta: float) -> void:
	if is_active:
		var collision = move_and_collide(velocity * delta)

		if collision:
			var collider := collision.get_collider()
			if collider.is_in_group("paddle"):
				_bounce_off_paddle(collider)
			if heavy_mode and collider.is_in_group("brick"):
				if collider.has_method("hit"):
					collider.hit()
			else:
				velocity = velocity.bounce(collision.get_normal())
				if collider.has_method("hit"):
					collider.hit()
				if collider.has_method("flash_hit"):
					collider.flash_hit(collision.get_position())
				_play_wall_hit_sound()

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
	
func _bounce_off_paddle(paddle: Node2D) -> void:
	var paddle_width := 100.0 # ideally match your paddle sprite width

	# How far from center did we hit?
	var offset := (global_position.x - paddle.global_position.x) / (paddle_width * 0.5)
	offset = clamp(offset, -1.0, 1.0)

	# Convert offset to angle (up-left to up-right)
	var min_angle := deg_to_rad(150.0)
	var max_angle := deg_to_rad(30.0)
	var angle : int = lerp(min_angle, max_angle, (offset + 1.0) * 0.5)

	var speed_now := velocity.length()
	velocity = Vector2(cos(angle), -sin(angle)) * speed_now

	# --- THIS PART GOES HERE ---
	var paddle_vel_x := 0.0
	if paddle.has_method("get_velocity"):
		paddle_vel_x = paddle.get_velocity().x

	velocity.x += paddle_vel_x * 0.25
	velocity = velocity.normalized() * speed_now
