extends CharacterBody2D

var speed:= 800.0

func _physics_process(_delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed )
	if velocity.y > 0 :
		velocity.y = 0
		
	move_and_slide()
	
func hit() -> void:
	$AudioStreamPlayer2D.play()
