extends Control

@onready var panel: BoxContainer = $Panel
@onready var start_button: Button = $Panel/StartButton
@onready var quit_button: Button = $Panel/QuitButton

@onready var hover_sfx: AudioStreamPlayer2D = $HoverSfx
@onready var click_sfx: AudioStreamPlayer2D = $ClickSfx

var is_paused: bool = true
var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.grab_focus()
	get_tree().paused = true
	visible = true
	
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Hover sounds (mouse)
	start_button.mouse_entered.connect(_on_button_hovered)
	quit_button.mouse_entered.connect(_on_button_hovered)
	
	# Optional: keyboard/controller focus hover
	start_button.focus_entered.connect(_on_button_hovered)
	quit_button.focus_entered.connect(_on_button_hovered)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _on_start_pressed() -> void:
	get_tree().paused = false
	_play_click()
	is_paused = false
	visible = false

func _on_quit_pressed() -> void:
	_play_click()
	get_tree().quit()
	
func _play_click() -> void:
	click_sfx.stop()
	click_sfx.play()
	
func _on_button_hovered() -> void:
	_play_hover()
	
	
func _play_hover() -> void:
	hover_sfx.stop() 
	hover_sfx.play()
	
func _on_button_up():
	pass
