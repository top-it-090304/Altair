extends Control

func _ready() -> void:
	MusicManager.play_music(preload("res://Assets/audio/For_Levels/MainMenu.mp3"))

func _on_texture_button_pressed() -> void:
	SceneManager.go_to("res://Entities/Main/MainMenu.tscn")

func _on_texture_button_2_pressed() -> void:
	SceneManager.go_to("res://Entities/Main/Level_Menu_MaskDude.tscn")

func _on_texture_button_3_pressed() -> void:
	SceneManager.go_to("res://Entities/Main/Level_Menu_MaskDude.tscn")
