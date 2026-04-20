extends Node

const CTRL_EDITOR = preload("res://Entities/Settings/ctrl_layout_editor.tscn")

var _touch_controls: Node
var _player: Node
var _edit_btn: TextureButton

func _ready() -> void:
	_touch_controls = get_parent().get_node("UI/TouchControls")
	_touch_controls.visible = false

	_player = get_parent().get_node_or_null("Entities/Player")
	if _player:
		_player.can_move = false

	# Back button (top-left) → return to settings
	var back_btn: TextureButton = get_parent().get_node_or_null("TextureButton")
	if back_btn:
		back_btn.pressed.connect(_on_back_to_settings)

	# Edit button lives in the scene as "EditButton"
	_edit_btn = get_parent().get_node_or_null("EditButton")
	if _edit_btn:
		_edit_btn.visible = false
		_edit_btn.pressed.connect(_open_editor)

	_open_editor()

func _open_editor() -> void:
	if _edit_btn:
		_edit_btn.visible = false
	_touch_controls.visible = false
	if _player:
		_player.can_move = false

	var editor = CTRL_EDITOR.instantiate()
	get_tree().root.add_child(editor)
	editor.editing_done.connect(_on_editing_done)

func _on_editing_done() -> void:
	_touch_controls.ghost_left.position  = GameData.ctrl_pos_left
	_touch_controls.ghost_right.position = GameData.ctrl_pos_right
	_touch_controls.ghost_jump.position  = GameData.ctrl_pos_up
	_touch_controls._update_zones()
	_touch_controls.visible = true
	if _player:
		_player.can_move = true
	if _edit_btn:
		_edit_btn.visible = true

func _on_back_to_settings() -> void:
	SceneManager.go_back()
