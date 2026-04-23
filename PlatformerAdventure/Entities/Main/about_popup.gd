extends CanvasLayer

func show_popup() -> void:
	visible = true

func hide_popup() -> void:
	visible = false

func _on_close_pressed() -> void:
	hide_popup()
