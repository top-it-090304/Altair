extends Control

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Entities/Main/MainMenu.tscn") # Выход в мейн


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/PinkMan_1-12Levels/Level1.tscn") # Просто пропрыгать


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/PinkMan_1-12Levels/Level2.tscn") # Платформа


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/PinkMan_1-12Levels/Level3.tscn") # Кубы


func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/PinkMan_1-12Levels/Level4.tscn") # Тот который андрей делает с огнем


func _on_button_5_pressed() -> void:
	get_tree().change_scene_to_file("res://NinjaFrog_37-50Levels/LevelN.tscn") #Ниндзяфрог цепи


func _on_button_6_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/VirtualGuy_13-24Levels/LevelV.tscn") # ВиартуалГай шипы 


func _on_button_7_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/PinkMan_1-12Levels/Level7.tscn") # Пинкмен шестерни
