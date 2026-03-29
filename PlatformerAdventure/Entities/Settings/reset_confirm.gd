extends Control

func _on_yes_pressed() -> void:
	GameData.reset_progress()
	queue_free()

func _on_no_pressed() -> void:
	queue_free()
