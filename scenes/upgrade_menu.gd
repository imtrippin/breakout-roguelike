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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Button actions
	upgrade_1.pressed.connect(_on_upgrade_1_pressed)
	upgrade_2.pressed.connect(_on_upgrade_2_pressed)
	upgrade_3.pressed.connect(_on_upgrade_3_pressed)
	
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
	
func _on_button_hovered() -> void:
	_play_hover()

func _play_hover() -> void:
	hover_sfx.stop() 
	hover_sfx.play()

func _play_click() -> void:
	click_sfx.stop()
	click_sfx.play()
	
func _on_upgrade_1_pressed():
	var paddle = get_tree().root.get_node("Main/Player")
	paddle.upgrade_width(1.2)
	hide()
	get_tree().paused = false
	
	
	
func _on_upgrade_2_pressed():
	var ball = get_tree().root.get_node("Main/Ball")
	ball.scale *= 2
	hide()
	get_tree().paused = false
	
	
	
func _on_upgrade_3_pressed():
	var ball1 = get_tree().root.get_node("Main/Ball")
	var ball2 = ball_scene.instantiate()
	get_tree().root.get_node("Main").add_child(ball2)
	ball2.scale *=3
	ball2.global_position = ball1.global_position
	
	hide()
	get_tree().paused = false
	
func open_menu() -> void:
	show()
	await get_tree().process_frame  # Wait 1 frame so the UI becomes active
	upgrade_1.grab_focus()          # Focus the first upgrade button
	
