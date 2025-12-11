extends Button

var tween: Tween

func _ready():
	pivot_offset = size * Vector2(0.5, 1.0)

	# Make sure the button can be focused by keyboard / gamepad
	focus_mode = Control.FOCUS_ALL

	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	# keyboard / gamepad focus also triggers tweens
	focus_entered.connect(_on_mouse_entered)
	focus_exited.connect(_on_mouse_exited)
	

func _on_mouse_entered():
	if tween: tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)  # nice overshoot effect
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.12)
	tween.tween_property(self, "modulate", Color(1.2, 1.074, 1.2, 1.0), 0.3)


func _on_mouse_exited():
	if tween: tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.12)
	tween.tween_property(self, "modulate", Color(1.2, 1.2, 1.2), 0.3)

func _on_button_down():
	if tween: tween.kill()
	scale = Vector2(0.9, 0.9)
	
func _on_button_up():
	if tween: tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "scale", Vector2(1, 1), 0.25)
