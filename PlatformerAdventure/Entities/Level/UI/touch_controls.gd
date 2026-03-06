extends CanvasLayer

const ZONE_LEFT := Rect2(0, 470, 250, 250)
const ZONE_RIGHT := Rect2(251, 470, 250, 250)
const ZONE_JUMP := Rect2(960, 470, 320, 275)

var _finger_left: int = -1
var _finger_rigjt: int = -1
var _finger_jump: int = -1

@onready var ghost_left: AnimatedSprite2D = $GhostLeft
@onready var ghost_right: AnimatedSprite2D = $GhostRight
@onready var ghost_jump: AnimatedSprite2D = $GhostJump

func _ready() -> void:
	
	ghost_left.visible = false
	ghost_right.visible = false
	ghost_jump.visible = false
	
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
		_show_ghost(ghost_left, pos)
		
	elif ZONE_RIGHT.has_point(scaled) and _finger_rigjt == -1:
		_finger_rigjt = id
		_press("move_right")
		_show_ghost(ghost_right, pos)
		
	elif ZONE_JUMP.has_point(scaled) and _finger_jump == -1:
		_finger_jump = id
		_press("move_up")
		_show_ghost(ghost_jump, pos)

func _on_finger_up(id : int) -> void:
	
	if id == _finger_left:
		_finger_left = -1
		_release("move_left")
		ghost_left.visible = false
	
	if id == _finger_rigjt:
		_finger_rigjt = -1
		_release("move_right")
		ghost_right.visible = false
	
	if id == _finger_jump:
		_finger_jump = -1
		_release("move_up")
		ghost_jump.visible = false

func _on_finger_drag (id: int, pos : Vector2) -> void:
	if id == _finger_left:
		ghost_left.global_position = pos
	elif id == _finger_rigjt:
		ghost_right.global_position = pos
	elif id == _finger_jump:
		ghost_jump.global_position = pos
	
func _on_anim_finished (ghost: AnimatedSprite2D):
	if ghost.visible:
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
	
func _show_ghost(ghost: AnimatedSprite2D, pos: Vector2) -> void:
	ghost.visible = true
	ghost.position = pos
	ghost.play("hit")

func _to_base(pos: Vector2) -> Vector2:
	var viewport_size := get_viewport().get_visible_rect().size
	return Vector2(
		pos.x * 1280.0 / viewport_size.x,
		pos.y * 720.0 / viewport_size.y
	)
