extends Node2D
enum RotationMode { SINE, CONSTANT }

@export var rotation_mode: RotationMode = RotationMode.SINE
@export var constant_speed: float = 180
@export var speed: float = 2.0 
@export var amplitude: float = 80.0
var time: float = 0.0

func _process(delta):
	match rotation_mode:
		RotationMode.SINE:
			time += delta * speed
			rotation_degrees = sin(time) * amplitude
		RotationMode.CONSTANT:
			rotation_degrees += constant_speed * delta
	
