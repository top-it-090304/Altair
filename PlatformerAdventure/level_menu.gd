extends Control

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Level1/Level1.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Level2/Level2.tscn")


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Level3/Level3.tscn")


func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Level4/Level4.tscn")
