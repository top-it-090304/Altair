extends Node2D

@export var fire_on: float = 5.0
@export var fire_off: float = 1.0
@export var fire_hit: float = 1.5
var is_burning: bool = false

func _ready() -> void:
	get_node("Area2D/CollisionShape2D").disabled = true
	$AnimatedSprite2D.play("fire_off")  
	await get_tree().create_timer(1.0).timeout
	_start_burning()

func _start_burning():
	$AnimatedSprite2D.play("fire_hit")
	await get_tree().create_timer(fire_hit).timeout
	is_burning = true
	$AnimatedSprite2D.play("fire_on")
	get_node("Area2D/CollisionShape2D").disabled = false
	$Timer.start(fire_on)

func _on_timer_timeout() -> void:
	if is_burning:
		is_burning = false
		$AnimatedSprite2D.play("fire_off")
		get_node("Area2D/CollisionShape2D").disabled = true
		$Timer.start(fire_off)
	else:
		_start_burning()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_burning and body.is_in_group("player"):
		body.hit()
