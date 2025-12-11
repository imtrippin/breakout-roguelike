extends Control

@onready var panel: BoxContainer = $Panel
@onready var resume_button: Button = $Panel/ResumeButton
@onready var quit_button: Button = $Panel/QuitButton

@onready var hover_sfx = $HoverSfx
@onready var click_sfx = $ClickSfx

var is_paused: bool = false

func _ready() -> void:
	visible = false
	# Button actions
	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Hover sounds (mouse)
	resume_button.mouse_entered.connect(_on_button_hovered)
	quit_button.mouse_entered.connect(_on_button_hovered)
	
	# Optional: keyboard/controller focus hover
	resume_button.focus_entered.connect(_on_button_hovered)
	quit_button.focus_entered.connect(_on_button_hovered)

func _unhandled_input(event: InputEvent) -> void:
	if !visible and get_tree().paused:
		return
	if event.is_action_pressed("pause"):
		if is_paused:
			_resume_game()
		else:
			_pause_game()
		get_viewport().set_input_as_handled()

func _pause_game() -> void:
	get_tree().paused = true
	is_paused = true
	visible = true
	resume_button.grab_focus()

func _resume_game() -> void:
	get_tree().paused = false
	is_paused = false
	visible = false

func _on_resume_pressed() -> void:
	_play_click()
	_resume_game()

func _on_quit_pressed() -> void:
	_play_click()
	get_tree().quit()

func _on_button_hovered() -> void:
	_play_hover()

func _play_hover() -> void:
	hover_sfx.stop()  # restart if already playing
	hover_sfx.play()

func _play_click() -> void:
	click_sfx.stop()
	click_sfx.play()
