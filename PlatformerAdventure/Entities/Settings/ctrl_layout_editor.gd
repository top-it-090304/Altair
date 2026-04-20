extends Control

@onready var ghost_left:  AnimatedSprite2D = $CanvasLayer/GhostLeft
@onready var ghost_right: AnimatedSprite2D = $CanvasLayer/GhostRight
@onready var ghost_jump:  AnimatedSprite2D = $CanvasLayer/GhostJump

var _dragging: AnimatedSprite2D = null
var _drag_offset: Vector2 = Vector2.ZERO

const GHOST_RADIUS := 72.0
const MIN_Y_RATIO  := 0.4

func _ready() -> void:
	ghost_left.position  = GameData.ctrl_pos_left
	ghost_right.position = GameData.ctrl_pos_right
	ghost_jump.position  = GameData.ctrl_pos_up

func _to_base(pos: Vector2) -> Vector2:
	var vs := get_viewport().get_visible_rect().size
	return Vector2(pos.x * 1280.0 / vs.x, pos.y * 720.0 / vs.y)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var p := _to_base(event.position)
		if event.pressed:
			_start_drag(p)
		else:
			_end_drag()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var p := _to_base(event.position)
		if event.pressed:
			_start_drag(p)
		else:
			_end_drag()
	elif event is InputEventScreenDrag and _dragging:
		_do_drag(_to_base(event.position))
	elif event is InputEventMouseMotion and _dragging:
		_do_drag(_to_base(event.position))

func _start_drag(base_pos: Vector2) -> void:
	for ghost in [ghost_left, ghost_right, ghost_jump]:
		var rect := Rect2(ghost.position - Vector2(GHOST_RADIUS, GHOST_RADIUS),
				Vector2(GHOST_RADIUS * 2.0, GHOST_RADIUS * 2.0))
		rect = rect.grow(20.0)
		if rect.has_point(base_pos):
			_dragging = ghost
			_drag_offset = ghost.position - base_pos
			return

func _do_drag(base_pos: Vector2) -> void:
	if not _dragging:
		return
	var new_pos := base_pos + _drag_offset
	new_pos.x = clamp(new_pos.x, GHOST_RADIUS, 1280.0 - GHOST_RADIUS)
	new_pos.y = clamp(new_pos.y, 720.0 * MIN_Y_RATIO, 720.0 - GHOST_RADIUS)
	_dragging.position = new_pos

func _end_drag() -> void:
	if not _dragging:
		return
	if _dragging == ghost_left:
		GameData.ctrl_pos_left = _dragging.position
	elif _dragging == ghost_right:
		GameData.ctrl_pos_right = _dragging.position
	elif _dragging == ghost_jump:
		GameData.ctrl_pos_up = _dragging.position
	GameData.save_data()
	_dragging = null

func reset_positions() -> void:
	GameData.reset_ctrl_positions()
	ghost_left.position  = GameData.ctrl_pos_left
	ghost_right.position = GameData.ctrl_pos_right
	ghost_jump.position  = GameData.ctrl_pos_up

func _on_reset_pressed() -> void:
	reset_positions()

func _on_back_pressed() -> void:
	queue_free()
