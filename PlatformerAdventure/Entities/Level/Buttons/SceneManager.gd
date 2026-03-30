extends Node

var previous_scene: String = ""

func go_to(scene_path: String) -> void:
	previous_scene = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(scene_path)

func go_back(fallback: String = "res://Scenes/MainMenu/main_menu.tscn") -> void:
	if previous_scene != "":
		var target = previous_scene
		previous_scene = ""
		get_tree().change_scene_to_file(target)
	else:
		get_tree().change_scene_to_file(fallback)
