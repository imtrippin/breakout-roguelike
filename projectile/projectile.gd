extends CharacterBody2D

@onready var mat: ShaderMaterial = $Sprite2D.material
@onready var wall_hit_sound: AudioStreamPlayer2D = $WallHitSound

var speed := 300.0
var dir = Vector2.DOWN
var is_active = true
var spin_strength = 0.015

func _ready() -> void:
	speed = speed + (20 * GameManager.level )
	velocity = Vector2(speed * -1, speed)
	
func _physics_process(delta: float) -> void:
	var _v : Vector2 = velocity
	if is_active:
		var collision = move_and_collide(velocity * delta)
		
		if collision:
			velocity = velocity.bounce(collision.get_normal())
			if collision.get_collider().has_method("hit"):
				collision.get_collider().hit()
			_play_wall_hit_sound()
		
			
		if velocity.y > 0 and velocity.y < 100:
			velocity.y = -200
			
		if velocity.x == 0:
			velocity.x = -200

		rotation += velocity.length() * spin_strength * delta
		
func game_over():
	GameManager.score = 0
	GameManager.level = 1
	await get_tree().create_timer(1).timeout
	get_tree().reload_current_scene()
	
func _play_wall_hit_sound() -> void:
	wall_hit_sound.play()

func _on_area_2d_body_shape_entered(_body_rid: RID, _body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	game_over()
