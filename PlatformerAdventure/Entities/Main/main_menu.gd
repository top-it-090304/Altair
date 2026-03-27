extends Control


func _on_btn_settings_pressed() -> void:
	SceneManager.go_to("res://Entities/Settings/setting.tscn")
	
func _ready() -> void:
	MusicManager.play_music(preload("res://Assets/audio/For_Levels/MainMenu.mp3"))
	get_tree().get_root().size_changed.connect(_on_viewport_resize)
	_on_viewport_resize()

func _on_viewport_resize() -> void:
	size = get_viewport().get_visible_rect().size
	position = Vector2.ZERO
	

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Entities/Main/Levels_Menu.tscn")


func _on_texture_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Entities/Shop/shop.tscn")


func _on_texture_button_3_pressed() -> void:
	get_tree().quit()
