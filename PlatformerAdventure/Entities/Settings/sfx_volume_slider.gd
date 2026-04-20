# setting.gd
# Путь: res://Entities/Settings/setting.gd

extends Control

const _RESET_CONFIRM   = preload("res://Entities/Settings/reset_confirm.tscn")
const _CTRL_LAYOUT     = preload("res://Entities/Settings/ctrl_layout_editor.tscn")
const SLIDER_LEFT_X:  float = 160.0
const SLIDER_RIGHT_X: float = 514.0

@onready var sfx_knob:   TextureRect = $SFXVolumeSlider/Knob
@onready var music_knob: TextureRect = $MusicVolumeSlider/Knob

var _active_knob: TextureRect = null
var _drag_offset_x: float = 0.0

func _ready() -> void:
	MusicManager.play_music(preload("res://Assets/audio/For_Levels/MainMenu.mp3"))
	_update_knob_position(sfx_knob,   GameData.volume_sfx)
	_update_knob_position(music_knob, GameData.volume_music)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_try_start_drag(event.global_position)
		else:
			_active_knob = null

	elif event is InputEventMouseMotion and _active_knob != null:
		_on_drag(event.global_position)

	elif event is InputEventScreenTouch:
		if event.pressed:
			_try_start_drag(event.position)
		else:
			_active_knob = null

	elif event is InputEventScreenDrag and _active_knob != null:
		_on_drag(event.position)

func _try_start_drag(global_pos: Vector2) -> void:
	for knob in [sfx_knob, music_knob]:
		if knob == null:
			continue
		var hit_rect := Rect2(knob.global_position - Vector2(10, 10), knob.size + Vector2(20, 20))
		if hit_rect.has_point(global_pos):
			_active_knob = knob
			_drag_offset_x = global_pos.x - knob.global_position.x
			return

func _on_drag(global_pos: Vector2) -> void:
	var new_global_x := global_pos.x - _drag_offset_x
	var local_x := new_global_x - global_position.x
	local_x = clamp(local_x, SLIDER_LEFT_X, SLIDER_RIGHT_X)
	_active_knob.position.x = local_x

	var value := (local_x - SLIDER_LEFT_X) / (SLIDER_RIGHT_X - SLIDER_LEFT_X)
	if _active_knob == sfx_knob:
		GameData.set_volume_sfx(value)
	else:
		GameData.set_volume_music(value)

func _update_knob_position(knob: TextureRect, value: float) -> void:
	if knob == null:
		return
	knob.position.x = SLIDER_LEFT_X + value * (SLIDER_RIGHT_X - SLIDER_LEFT_X)


func _on_texture_button_pressed() -> void:
	SceneManager.go_back()

func _on_reset_button_pressed() -> void:
	add_child(_RESET_CONFIRM.instantiate())

func _on_ctrl_layout_pressed() -> void:
	add_child(_CTRL_LAYOUT.instantiate())
