extends Control

@onready var play_button: Button = $TextureRect/PlayButton
@onready var quit_button: Button = $TextureRect/QuitButton
@export var sound_played: bool = false

func _ready() -> void:
	for btn in [play_button, quit_button]:
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.add_theme_color_override("font_hover_color", Color.WHITE)
		btn.add_theme_color_override("font_pressed_color", Color.BLACK)
		btn.add_theme_color_override("font_focus_color", Color.BLACK)
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	if sound_played == false:
			var sfx = AudioStreamPlayer.new()
			sfx.stream = load("res://Assets/Audio/menu.mp3")
			add_child(sfx)
			sfx.play()
	get_tree().change_scene_to_file("res://level_1.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_video_stream_player_finished() -> void:
	$VideoStreamPlayer.queue_free()
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("skip") and has_node("VideoStreamPlayer"):
		$VideoStreamPlayer.queue_free()
