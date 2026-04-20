extends Node

const CTRL_EDITOR  = preload("res://Entities/Settings/ctrl_layout_editor.tscn")
const EDIT_TEX     = preload("res://Assets/Textures/Menu/Buttons/Settings.png")

var _touch_controls: Node
var _player: Node
var _edit_canvas: CanvasLayer
var _edit_btn: TextureButton

func _ready() -> void:
	_touch_controls = get_parent().get_node("UI/TouchControls")
	_touch_controls.visible = false

	_player = get_parent().get_node_or_null("Entities/Player")
	if _player:
		_player.can_move = false

	# Re-edit button lives in its own CanvasLayer at root level
	_edit_canvas = CanvasLayer.new()
	_edit_canvas.layer = 5
	get_tree().root.add_child(_edit_canvas)

	_edit_btn = TextureButton.new()
	_edit_btn.texture_normal = EDIT_TEX
	_edit_btn.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_edit_btn.offset_left   = 10.0
	_edit_btn.offset_top    = 10.0
	_edit_btn.offset_right  = 70.0
	_edit_btn.offset_bottom = 70.0
	_edit_btn.visible = false
	_edit_btn.pressed.connect(_open_editor)
	_edit_canvas.add_child(_edit_btn)

	_open_editor()

func _open_editor() -> void:
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
	_edit_btn.visible = true

func _exit_tree() -> void:
	if is_instance_valid(_edit_canvas):
		_edit_canvas.queue_free()
