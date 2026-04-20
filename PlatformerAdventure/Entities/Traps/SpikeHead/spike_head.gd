extends AnimatableBody2D

enum MoveMode { UP, DOWN, LEFT, RIGHT }

@export var move_mode: MoveMode = MoveMode.UP
@export var speed: float = 200.0
@export var wait_time: float = 0.5

var direction: Vector2
var waiting: bool = false
var wait_timer: float = 0.0


func _ready() -> void:
	match move_mode:
		MoveMode.UP:    direction = Vector2.UP
		MoveMode.DOWN:  direction = Vector2.DOWN
		MoveMode.LEFT:  direction = Vector2.LEFT
		MoveMode.RIGHT: direction = Vector2.RIGHT

	if not $KillArea.body_entered.is_connected(_on_kill_area_body_entered):
		$KillArea.body_entered.connect(_on_kill_area_body_entered)
	$AnimatedSprite2D.play("Idle")


func _on_kill_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hit()


func _physics_process(delta: float) -> void:
	if waiting:
		wait_timer -= delta
		if wait_timer <= 0.0:
			waiting = false
			$AnimatedSprite2D.play("Idle")
		return

	var motion := direction * speed * delta
	var collision := move_and_collide(motion)

	if collision == null:
		return

	var collider := collision.get_collider()
	if collider != null and collider.is_in_group("player"):
		collider.hit()
		return

	_start_wait(collision.get_normal())


func _start_wait(normal: Vector2) -> void:
	waiting = true
	wait_timer = wait_time

	if normal.x > 0.5:
		$AnimatedSprite2D.play("Left_Hit")
		direction = Vector2.RIGHT
		move_mode = MoveMode.RIGHT
	elif normal.x < -0.5:
		$AnimatedSprite2D.play("Right_Hit")
		direction = Vector2.LEFT
		move_mode = MoveMode.LEFT
	elif normal.y > 0.5:
		$AnimatedSprite2D.play("Top_Hit")
		direction = Vector2.DOWN
		move_mode = MoveMode.DOWN
	elif normal.y < -0.5:
		$AnimatedSprite2D.play("Bottom Hit")
		direction = Vector2.UP
		move_mode = MoveMode.UP
