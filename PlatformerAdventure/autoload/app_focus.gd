extends Node

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			Engine.max_fps = 0
			get_tree().paused = true
		NOTIFICATION_APPLICATION_FOCUS_IN:
			Engine.max_fps = 60
			get_tree().paused = false
