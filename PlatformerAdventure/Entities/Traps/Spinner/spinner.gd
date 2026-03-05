extends AnimatableBody2D

enum Direction { CLOCKWISE, COUNTER_CLOCKWISE }

@export_group("Rotation")
@export var direction: Direction = Direction.CLOCKWISE
@export var rotation_speed: float = 120.0 

@export_group("Pause")
@export var pause_duration: float = 1.0  

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var _is_paused: bool = false
var _pause_timer: float = 0.0
var _rotated: float = 0.0  

func _ready() -> void:
	animated_sprite.play("on")

func _physics_process(delta: float) -> void:
	if _is_paused:
		_pause_timer -= delta
		if _pause_timer <= 0.0:
			_is_paused = false
			_rotated = 0.0
			animated_sprite.play("on")
		return

	var speed = rotation_speed if direction == Direction.CLOCKWISE else -rotation_speed
	var step = speed * delta
	rotation_degrees += step
	_rotated += abs(step)

	if _rotated >= 360.0:
		_rotated = 0.0
		_is_paused = true
		_pause_timer = pause_duration
		animated_sprite.play("off")
