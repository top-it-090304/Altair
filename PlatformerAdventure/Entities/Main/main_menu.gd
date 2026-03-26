extends Control

func _on_texture_button_button_down() -> void:
	get_tree().change_scene_to_file("res://Entities/Main/Levels_Menu.tscn")


func _on_texture_button_2_button_down() -> void:
	get_tree().change_scene_to_file("res://Entities/Shop/Shop.tscn")
