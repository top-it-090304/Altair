extends Control

const TEX_ON       := preload("res://Assets/Buttons/on_off/on_normal.png")
const TEX_ON_LIGHT := preload("res://Assets/Buttons/on_off/on_hover.png")
const TEX_ON_DARK  := preload("res://Assets/Buttons/on_off/on_pressed.png")
const TEX_OFF      := preload("res://Assets/Buttons/on_off/off_normal.png")
const TEX_OFF_LIGHT := preload("res://Assets/Buttons/on_off/off_hover.png")
const TEX_OFF_DARK  := preload("res://Assets/Buttons/on_off/off_pressed.png")

@onready var btn: TextureButton = $TextureButton

func _ready() -> void:
	_update_visual()

func _update_visual() -> void:
	if GameData.show_ctrl_hits:
		btn.texture_normal  = TEX_ON
		btn.texture_hover   = TEX_ON_LIGHT
		btn.texture_pressed = TEX_ON_DARK
	else:
		btn.texture_normal  = TEX_OFF
		btn.texture_hover   = TEX_OFF_LIGHT
		btn.texture_pressed = TEX_OFF_DARK

func _on_pressed() -> void:
	GameData.show_ctrl_hits = !GameData.show_ctrl_hits
	GameData.save_data()
	_update_visual()
