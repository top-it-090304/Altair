extends CanvasLayer

signal tutorial_closed

@export var character_name: String = ""
@export var show_wall_jump: bool = false

@onready var _root_control: Control = $RootControl
@onready var _char_header: Label = $RootControl/Center/Panel/VBox/CharacterHeader
@onready var _wall_jump_section: VBoxContainer = $RootControl/Center/Panel/VBox/WallJumpSection
@onready var _tap_prompt: Label = $RootControl/Center/Panel/VBox/TapPrompt

var _can_dismiss: bool = false

func _ready() -> void:
	_char_header.text = "У %s доступно:" % character_name if character_name != "" else ""
	_char_header.visible = character_name != ""
	_wall_jump_section.visible = show_wall_jump
	_start_countdown()

func _start_countdown() -> void:
	for i in range(5, 0, -1):
		_tap_prompt.text = "Подождите %d сек..." % i
		await get_tree().create_timer(1.0).timeout
	_can_dismiss = true
	_tap_prompt.text = "Коснитесь экрана чтобы начать"

func _input(event: InputEvent) -> void:
	if not _can_dismiss or _root_control == null:
		return
	var is_press: bool = (
		(event is InputEventScreenTouch and event.pressed) or
		(event is InputEventKey and event.pressed and not event.echo) or
		(event is InputEventMouseButton and event.pressed)
	)
	if is_press:
		_dismiss()

func _dismiss() -> void:
	set_process_input(false)
	var tween := create_tween()
	tween.tween_property(_root_control, "modulate:a", 0.0, 0.3)
	await tween.finished
	tutorial_closed.emit()
	queue_free()
