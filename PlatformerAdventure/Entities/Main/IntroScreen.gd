extends Control

@onready var video: VideoStreamPlayer = $VideoStreamPlayer

func _ready() -> void:
	video.expand = true
	video.play()
	video.finished.connect(_go_to_menu)

func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://Entities/Main/MainMenu.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_go_to_menu()
