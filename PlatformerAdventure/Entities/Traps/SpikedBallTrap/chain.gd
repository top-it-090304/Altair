extends Line2D

@export var chain_length: float = 80.0
@export var segment_step: float = 8.0

@onready var ball: Area2D = get_parent().get_node("Ball")

func _ready():
	update_chain()

func update_chain():
	var pts: Array[Vector2] = []
	var y: float = 0.0
	while y < chain_length:
		pts.append(Vector2(0, y))
		y += segment_step
	pts.append(Vector2(0, chain_length))
	
	points = pts
	
	if ball:
		ball.position = Vector2(0, chain_length)
