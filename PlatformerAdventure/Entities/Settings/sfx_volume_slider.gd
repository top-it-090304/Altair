extends Control

@onready var knob = %Knob

var volume_level: int:
	get:
		return GameData.sfx_volume
	set(value):
		GameData.sfx_volume = value

		GameData.apply_audio_settings()
		GameData.save_data()

var dragging := false

var min_x := 165.0
var max_x := 530.0
var knob_y := 487.0
var slider_width := 0.0

func _ready():
	slider_width = max_x - min_x
	
	update_knob_visual()

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if dragging:
				update_from_mouse(event.position.x)
	elif event is InputEventMouseMotion and dragging:
		update_from_mouse(event.position.x)

func update_from_mouse(mouse_x: float):
	var local_x = clamp(mouse_x, min_x, max_x)
	var step_size = slider_width / 10.0

	volume_level = round((local_x - min_x) / step_size)
	volume_level = clamp(volume_level, 0, 10)

	update_knob_visual()

func update_knob_visual():
	var step_size = slider_width / 10.0
	var knob_x = min_x + (volume_level * step_size)
	
	if knob:

		knob.position.x = knob_x - knob.size.x / 2.0
		knob.position.y = knob_y


func _on_texture_button_pressed() -> void:

	get_tree().change_scene_to_file("res://Entities/Main/MainMenu.tscn")
