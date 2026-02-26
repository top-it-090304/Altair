extends Area2D

enum MoveType {
	PingPong,
	Loop,
	Once
}
@export var move_type : MoveType = MoveType.PingPong
@export var speed : float = 150.0
@export var start_delay : float = 0.0

@onready var path_follow : PathFollow2D = get_parent()

var _current_speed: float = 0.0
var is_started: bool = false
var _delay_timer: float = 0.0
var is_finished: bool = false

func _ready() -> void:
	path_follow.loop = (move_type == MoveType.Loop) #При завершении переход в начало пути
	path_follow.rotates = false
	
	_current_speed = speed
	
	if start_delay > 0.0:
		_delay_timer = start_delay
		$AnimatedSprite2D.play("Off")
	else:
		is_started = true 
		$AnimatedSprite2D.play("On")
	
	body_entered.connect(_on_body_entered)
	

func _physics_process(delta: float) -> void:
	if not is_started:
		_delay_timer -= delta
		if _delay_timer <= 0.0:
			is_started = true
		return
	
	if is_finished:
		return
	
	path_follow.progress += delta * _current_speed
	
	match move_type:
		MoveType.PingPong:
			if path_follow.progress_ratio >= 1.0:
				_current_speed = -abs(speed)
			elif path_follow.progress_ratio <= 0.0:
				_current_speed = abs(speed)
		
		MoveType.Loop:
			pass
		
		MoveType.Once:
			if path_follow.progress_ratio >= 1.0:
				is_finished = true
				_current_speed = 0.0

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.hit()
