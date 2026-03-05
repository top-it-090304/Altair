extends CanvasLayer

@onready var btn_left: Button = $Control/Left
@onready var btn_right: Button = $Control2/Right
@onready var btn_jump: Button = $Control3/Up

func _ready() -> void:
	btn_left.button_down.connect(_press.bind("move_left"))
	btn_left.button_up.connect(_release.bind("move_left"))
	
	btn_right.button_down.connect(_press.bind("move_right"))
	btn_right.button_up.connect(_release.bind("move_right"))
	
	btn_jump.button_down.connect(_press.bind("move_up"))
	btn_jump.button_up.connect(_release.bind("move_up"))

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
