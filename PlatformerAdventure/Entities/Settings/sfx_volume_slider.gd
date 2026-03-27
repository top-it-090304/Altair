# setting.gd
# Путь: res://Entities/Settings/setting.gd

extends Control

const SLIDER_LEFT_X:  float = 160.0
const SLIDER_RIGHT_X: float = 514.0

@onready var knob: TextureRect = $SFXVolumeSlider/Knob

var _dragging: bool = false
var _drag_offset_x: float = 0.0

func _ready() -> void:
	_update_knob_position(GameData.volume_master)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_try_start_drag(event.global_position)
		else:
			_dragging = false

	elif event is InputEventMouseMotion and _dragging:
		_on_drag(event.global_position)

	elif event is InputEventScreenTouch:
		if event.pressed:
			_try_start_drag(event.position)
		else:
			_dragging = false

	elif event is InputEventScreenDrag and _dragging:
		_on_drag(event.position)

func _try_start_drag(global_pos: Vector2) -> void:
	if knob == null:
		return
	var knob_global := knob.global_position
	var knob_size   := knob.size
	var hit_rect    := Rect2(knob_global - Vector2(10, 10), knob_size + Vector2(20, 20))
	if hit_rect.has_point(global_pos):
		_dragging = true
		_drag_offset_x = global_pos.x - knob_global.x

func _on_drag(global_pos: Vector2) -> void:
	var new_global_x := global_pos.x - _drag_offset_x
	var local_x := new_global_x - global_position.x
	local_x = clamp(local_x, SLIDER_LEFT_X, SLIDER_RIGHT_X)
	knob.position.x = local_x

	var value := (local_x - SLIDER_LEFT_X) / (SLIDER_RIGHT_X - SLIDER_LEFT_X)
	GameData.set_volume_master(value)

func _update_knob_position(value: float) -> void:
	if knob == null:
		return
	knob.position.x = SLIDER_LEFT_X + value * (SLIDER_RIGHT_X - SLIDER_LEFT_X)



func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Entities/Main/MainMenu.tscn")
