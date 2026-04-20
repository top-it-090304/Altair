extends Control

func _ready() -> void:
	self.hide()
	$PauseLayer/Background.hide()
	get_tree().paused = false
	var scene_path = get_tree().current_scene.scene_file_path
	if "change_control_lvl" in scene_path:
		$PauseLayer/Background/CenterContainer/VBoxContainer/HBoxContainer/Back.modulate = Color(1, 0.2, 0.2)

func _process(_delta: float) -> void:
	pass

func open_pause_menu():
	get_tree().paused = true
	$PauseLayer/Background.show() 



func _on_play_pressed() -> void:
	get_tree().paused = false
	$PauseLayer/Background.hide()


func _on_restart_pressed() -> void:
	get_tree().paused = false 
	get_tree().reload_current_scene()


func _on_back_pressed() -> void:
	get_tree().paused = false
	var scene_path = get_tree().current_scene.scene_file_path
	if "change_control_lvl" in scene_path:
		SceneManager.go_to("res://Entities/Settings/setting.tscn")
	elif "MaskDude" in scene_path:
		SceneManager.go_to("res://Entities/Main/Level_Menu_MaskDude.tscn")
	else:
		SceneManager.go_to("res://Entities/Main/Levels_Menu.tscn")


func _on_settings_pressed() -> void:
	get_tree().paused = false
	SceneManager.go_to("res://Entities/Settings/setting.tscn")
