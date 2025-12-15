extends CharacterBody2D
@onready var player: CharacterBody2D = $"."
@onready var sprite: Sprite2D = $Sprite2D2
@onready var paddle_mat: ShaderMaterial = sprite.material

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
	
func flash_hit(global_hit_pos: Vector2) -> void:
	if paddle_mat == null or sprite.texture == null:
		return

	# Convert global hit position to local space of the paddle
	var local: Vector2 = sprite.to_local(global_hit_pos)

	# Convert local position to UV (0–1) assuming Sprite2D is centered
	var tex_size: Vector2 = sprite.texture.get_size() * sprite.scale

	# local.x is roughly -tex_width/2 .. +tex_width/2
	var u: float = clamp(local.x / tex_size.x + 0.5, 0.0, 1.0)
	# same for y (usually not super important for a flat paddle, but nice to have)
	var v: float = clamp(-local.y / tex_size.y + 0.5, 0.0, 1.0)

	var impact_uv := Vector2(u, v)

	# Set impact center in shader
	paddle_mat.set_shader_parameter("impact_uv", impact_uv)

	# Start with small radius & full flash
	paddle_mat.set_shader_parameter("impact_radius", 0.05)
	paddle_mat.set_shader_parameter("flash_amount", 1.0)

	# Animate: radius grows, flash fades
	var tween := get_tree().create_tween()
	tween.tween_property(
		paddle_mat,
		"shader_parameter/impact_radius",
		0.5,           # how far the flash spreads
		0.18
	)
	tween.parallel().tween_property(
		paddle_mat,
		"shader_parameter/flash_amount",
		0.0,
		0.18
	).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func upgrade_width(_amount: float) -> void:
	_update_width()
	
func _update_width() -> void:
	player.scale.x = player.scale.x * 2
	get_tree()
