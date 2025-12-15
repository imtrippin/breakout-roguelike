extends Control

#region /// onready var
@onready var panel: HBoxContainer = $Panel
@onready var upgrade_1: Button = $Panel/Upgrade1
@onready var upgrade_2: Button = $Panel/Upgrade2
@onready var upgrade_3: Button = $Panel/Upgrade3
@onready var hover_sfx: AudioStreamPlayer2D = $HoverSfx
@onready var click_sfx: AudioStreamPlayer2D = $ClickSfx
#endregion

@export var ball_scene: PackedScene

var all_upgrades: Array = []
var current_choices: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_build_upgrade_pool()
	
	# Button actions
	upgrade_1.pressed.connect(func(): _on_upgrade_button_pressed(0))
	upgrade_2.pressed.connect(func(): _on_upgrade_button_pressed(1))
	upgrade_3.pressed.connect(func(): _on_upgrade_button_pressed(2))
	
	# Hover sounds (mouse)
	upgrade_1.mouse_entered.connect(_on_button_hovered)
	upgrade_2.mouse_entered.connect(_on_button_hovered)
	upgrade_3.mouse_entered.connect(_on_button_hovered)
	
	# Optional: keyboard/controller focus hover
	upgrade_1.focus_entered.connect(_on_button_hovered)
	upgrade_2.focus_entered.connect(_on_button_hovered)
	upgrade_3.focus_entered.connect(_on_button_hovered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _build_upgrade_pool() -> void:
	all_upgrades = [
	{
		"name": "Wider Paddle",
		"apply": func() -> void:
			var paddle = get_tree().root.get_node("Main/Player")
			paddle.upgrade_width(1.2)
	},
	{
		"name": "Bigger Ball",
		"apply": func() -> void:
			var ball = get_tree().root.get_node("Main/Ball")
			ball.scale *= 2.0
	},
	{
		"name": "Extra Ball",
		"apply": func() -> void:
			var ball1 = get_tree().root.get_node("Main/Ball")
			var extra_ball = ball_scene.instantiate()
			var main := get_tree().root.get_node("Main")
			main.add_child(extra_ball)
			extra_ball.scale *=3
			extra_ball.global_position = ball1.global_position
	},
	{
		"name": "Iron Balls",
		"apply": func() -> void:
			var ball = get_tree().root.get_node("Main/Ball")
			ball.enable_heavy_mode()
			
	},
	{
		"name": "Upgrade 5",
		"apply": func() -> void:
			pass	
	},
	{
		"name": "Upgrade 6",
		"apply": func() -> void:
			pass	
	}
]	

func _roll_random_upgrades() -> void:
	# ensure at least 3 upgrades in pool
	if all_upgrades.size() < 3:
		push_warning("not enough upgrades in all_upgrades")
		return
	
	# duplicate + shuffle so original order is unchanged
	var pool := all_upgrades.duplicate()
	pool.shuffle()
	
	# take first 3 as current choices
	current_choices.clear()
	for i in 3:
		current_choices.append(pool[i])
	
	# update button labels	
	upgrade_1.text = current_choices[0]["name"]
	upgrade_2.text = current_choices[1]["name"]
	upgrade_3.text = current_choices[2]["name"]
	
func _on_upgrade_button_pressed(index: int) -> void:
	_play_click()	
	
	if index < 0 or index >= current_choices.size():
		return
	var chosen_upgrade = current_choices[index]
	var apply_callable: Callable = chosen_upgrade["apply"]
	apply_callable.call()
	
	hide()
	get_tree().paused = false	
	
func _on_button_hovered() -> void:
	_play_hover()

func _play_hover() -> void:
	hover_sfx.stop() 
	hover_sfx.play()

func _play_click() -> void:
	click_sfx.stop()
	click_sfx.play()

	
func open_menu() -> void:
	_roll_random_upgrades()
	show()
	await get_tree().process_frame  
	upgrade_1.grab_focus()        
	
