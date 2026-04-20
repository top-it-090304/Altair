extends Node2D

@export var bounce_force: float = -800.0
@export var horizontal: bool = false        # ← новый параметр
@export var animated_time: float = 0.3

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D  
@onready var detector: Area2D = $Detector

func _ready() -> void:
	sprite.play("off")
	detector.body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	pass

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
	
	if horizontal:
		body.velocity.x = bounce_force   # толкаем по X
	else:
		body.velocity.y = bounce_force   # стандартный прыжок вверх
	
	play_bounce_animation()

func play_bounce_animation():
	sprite.play("on")
	await get_tree().create_timer(animated_time).timeout
	sprite.play("off")
	
