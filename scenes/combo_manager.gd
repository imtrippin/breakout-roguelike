extends Node

@export var combo_window: float = 1   # time in seconds to keep combo alive

@onready var combo_timer: Timer = $Timer
@onready var combo_label: Label = $CanvasLayer/Label

var combo_count: int = 0

func _ready() -> void:
	combo_timer.one_shot = true
	combo_timer.timeout.connect(_on_combo_timer_timeout)
	_hide_combo()

func register_brick_hit() -> void:
	combo_count += 1
	# Restart the combo window each hit
	combo_timer.start(combo_window)

func _on_combo_timer_timeout() -> void:
	if combo_count >= 2:
		_show_combo(combo_count)
		$AudioStreamPlayer2D.play()
	combo_count = 0

func _show_combo(count: int) -> void:
	combo_label.text = "x%d COMBO!" % count
	combo_label.visible = true
	
	combo_label.modulate.a = 1.0
	combo_label.scale = Vector2.ZERO
	
	# ✅ Optional: make big combos hit harder
	var power : float = clamp(float(count) / 10.0, 0.0, 1.0)
	var pop_scale : int = lerp(1.2, 1.8, power)

	var tween := create_tween()
	tween.set_parallel(true)

	# ✅ POP IN (fast overshoot)
	tween.tween_property(combo_label, "scale", Vector2(pop_scale, pop_scale), 0.12)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)

	# ✅ FLOAT UP
	tween.tween_property(combo_label, "position:y", combo_label.position.y - 30, 0.6)\
		.set_ease(Tween.EASE_OUT)

	# ✅ FADE OUT AFTER A SHORT HOLD
	tween.tween_property(combo_label, "modulate:a", 0.0, 0.4).set_delay(0.3)

	# ✅ CLEAN UP
	tween.tween_callback(_hide_combo).set_delay(0.7)


func _hide_combo() -> void:
	combo_label.visible = false
