extends AnimatableBody2D

@export_group("Sine Bobbing")
@export var bob_amplitude: float = 5.0
@export var bob_frequency: float = 1.5

@export_group("Sine Rotation")
@export var rotate_amplitude: float = 8.0
@export var rotate_frequency: float = 1.2

@export_group("Fall")
@export var fall_delay: float = 0.8
@export var fall_gravity: float = 1200.0

var _start_x: float = 0.0
var _start_y: float = 0.0
var _time: float = 0.0
var _state: String = "idle"
var _fall_timer: float = 0.0
var _fall_velocity: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var body_collision: CollisionShape2D = $CollisionShape2D
@onready var detector: Area2D = $Area2D

func _ready() -> void:
	_start_x = position.x
	_start_y = position.y
	animated_sprite.play("on")
	detector.body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	_time += delta

	match _state:
		"idle":
			_do_bob_and_rotate()
		"waiting":
			_fall_timer -= delta
			_do_bob_and_rotate()
			if _fall_timer <= 0.0:
				_start_fall()
		"falling":
			_fall_velocity += fall_gravity * delta
			position.y += _fall_velocity * delta

func _do_bob_and_rotate() -> void:
	position.y = _start_y + sin(_time * bob_frequency * TAU) * bob_amplitude
	position.x = _start_x
	rotation_degrees = sin(_time * rotate_frequency * TAU) * rotate_amplitude

func _start_fall() -> void:
	_state = "falling"
	rotation_degrees = 0.0
	body_collision.set_deferred("disabled", true)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and _state == "idle":
		if fall_delay <= 0.0:
			_start_fall()
		else:
			_state = "waiting"
			_fall_timer = fall_delay
