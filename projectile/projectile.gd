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

	GameManager.register_ball(self)  # every ball registers itself


func _physics_process(delta: float) -> void:
	if is_active:
		var collision = move_and_collide(velocity * delta)

		if collision:
			var collider := collision.get_collider()

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


func _play_wall_hit_sound() -> void:
	wall_hit_sound.play()


func _on_area_2d_body_shape_entered(
	_body_rid: RID,
	_body: Node2D,
	_body_shape_index: int,
	_local_shape_index: int
) -> void:
	# THIS ball died
	is_active = false
	GameManager.unregister_ball()
	queue_free()
	


func launch(direction: Vector2) -> void:
	is_active = true
	speed = 300.0 + (20 * GameManager.level)
	velocity = direction.normalized() * speed


func enable_heavy_mode() -> void:
	heavy_mode = true
