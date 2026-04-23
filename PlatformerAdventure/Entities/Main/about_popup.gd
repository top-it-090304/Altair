extends CanvasLayer

func _ready() -> void:
	hide()
	var font = preload("res://Assets/Fonts/EpilepsySansBold.ttf")
	var font_bold = preload("res://Assets/Fonts/EpilepsySansBold.ttf")

	for label in _get_all_labels(self):
		label.add_theme_font_override("font", font)
		label.add_theme_font_size_override("font_size", 24)

	var title = find_child("Title", true, false)
	if title:
		title.add_theme_font_override("font", font_bold)
		title.add_theme_font_size_override("font_size", 36)

func show_popup() -> void:
	visible = true

func hide_popup() -> void:
	visible = false

func _on_close_pressed() -> void:
	hide_popup()

func _get_all_labels(node: Node) -> Array:
	var labels := []
	for child in node.get_children():
		if child is Label:
			labels.append(child)
		labels.append_array(_get_all_labels(child))
	return labels
