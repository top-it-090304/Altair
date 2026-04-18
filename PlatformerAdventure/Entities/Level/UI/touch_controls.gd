extends CanvasLayer

const ZONE_LEFT := Rect2(40, 510, 170, 170)
const ZONE_RIGHT := Rect2(291, 510, 170, 170)
const ZONE_JUMP := Rect2(1035, 522, 170, 170)

var _finger_left: int = -1
var _finger_rigjt: int = -1
var _finger_jump: int = -1

@onready var ghost_left: AnimatedSprite2D = $GhostLeft
@onready var ghost_right: AnimatedSprite2D = $GhostRight
@onready var ghost_jump: AnimatedSprite2D = $GhostJump

@export var show_zone_hints: bool = true
@onready var _hints: Node2D = $TouchZoneHints

func _ready() -> void:
	_hints.visible = false
	ghost_left.play("idle")
	ghost_right.play("idle")
	ghost_jump.play("idle")

	ghost_left.animation_finished.connect(_on_anim_finished.bind(ghost_left))
	ghost_right.animation_finished.connect(_on_anim_finished.bind(ghost_right))
	ghost_jump.animation_finished.connect(_on_anim_finished.bind(ghost_jump))
	
func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_on_finger_down(event.index, event.position)
		else:
			_on_finger_up(event.index)
	elif event is InputEventScreenDrag:
		_on_finger_drag(event.index, event.position)
			
func _on_finger_down(id : int, pos : Vector2) -> void:
	
	var scaled = _to_base(pos)
	
	if ZONE_LEFT.has_point(scaled) and _finger_left == -1:
		_finger_left = id
		_press("move_left")
		_show_ghost(ghost_left)

	elif ZONE_RIGHT.has_point(scaled) and _finger_rigjt == -1:
		_finger_rigjt = id
		_press("move_right")
		_show_ghost(ghost_right)

	elif ZONE_JUMP.has_point(scaled) and _finger_jump == -1:
		_finger_jump = id
		_press("move_up")
		_show_ghost(ghost_jump)

func _on_finger_up(id : int) -> void:
	
	if id == _finger_left:
		_finger_left = -1
		_release("move_left")
		ghost_left.modulate = Color(1, 1, 1, 0.5)
		ghost_left.play("idle")

	if id == _finger_rigjt:
		_finger_rigjt = -1
		_release("move_right")
		ghost_right.modulate = Color(1, 1, 1, 0.5)
		ghost_right.play("idle")

	if id == _finger_jump:
		_finger_jump = -1
		_release("move_up")
		ghost_jump.modulate = Color(1, 1, 1, 0.5)
		ghost_jump.play("idle")

func _on_finger_drag (id: int, pos : Vector2) -> void:
	pass

func _on_anim_finished (ghost: AnimatedSprite2D):
	ghost.modulate = Color(1, 1, 1, 0.5)
	ghost.play("idle")
		
func _press(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)

func _release(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = false
	Input.parse_input_event(event)
	
func _show_ghost(ghost: AnimatedSprite2D) -> void:
	ghost.modulate = Color(1, 1, 1, 1.0)
	ghost.play("hit")

func _to_base(pos: Vector2) -> Vector2:
	var viewport_size := get_viewport().get_visible_rect().size
	return Vector2(
		pos.x * 1280.0 / viewport_size.x,
		pos.y * 720.0 / viewport_size.y
	)

func release_all() -> void:
	if _finger_left != -1:
		_finger_left = -1
		_release("move_left")
		ghost_left.modulate = Color(1, 1, 1, 0.5)
		ghost_left.play("idle")
	if _finger_rigjt != -1:
		_finger_rigjt = -1
		_release("move_right")
		ghost_right.modulate = Color(1, 1, 1, 0.5)
		ghost_right.play("idle")
	if _finger_jump != -1:
		_finger_jump = -1
		_release("move_up")
		ghost_jump.modulate = Color(1, 1, 1, 0.5)
		ghost_jump.play("idle")

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		release_all()
