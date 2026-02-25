extends Control

func _ready() -> void:
	self.hide()
	$PauseLayer/Background.hide() 
	get_tree().paused = false

func _process(delta: float) -> void:
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
	get_tree().change_scene_to_file("res://Entities/Main/Levels_Menu.tscn")
