extends AnimatableBody2D

enum MoveMode { UP, DOWN, LEFT, RIGHT }

@export var move_mode: MoveMode = MoveMode.UP
@export var speed: float = 200.0
@export var wait_time: float = 1.5

var direction: Vector2
var waiting: bool = false
var wait_timer: float = 0.0
var player_in_area: Node2D = null


func _ready() -> void:
	match move_mode:
		MoveMode.UP:    direction = Vector2.UP
		MoveMode.DOWN:  direction = Vector2.DOWN
		MoveMode.LEFT:  direction = Vector2.LEFT
		MoveMode.RIGHT: direction = Vector2.RIGHT

	$CrushCheck.body_entered.connect(_on_crush_body_entered)
	$CrushCheck.body_exited.connect(_on_crush_body_exited)
	$AnimatedSprite2D.play("Idle")


func _on_crush_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = body


func _on_crush_body_exited(body: Node2D) -> void:
	if body == player_in_area:
		player_in_area = null


func _physics_process(delta: float) -> void:
	if waiting:
		wait_timer -= delta
		if wait_timer <= 0.0:
			waiting = false
			$AnimatedSprite2D.play("Idle")
		return

	var motion = direction * speed * delta
	var collision = move_and_collide(motion)

	if collision == null:
		return

	var collider = collision.get_collider()

	# ФИКС МЕНТОРА 
	if collider != null and collider.is_in_group("player"):
		if collider.is_wall_in_direction(direction):
			collider.hit()
		else:
			var remainder = collision.get_remainder()
			collider.global_position += remainder
			global_position += remainder
		return

	_check_crush(collision.get_normal())
	_start_wait(collision.get_normal())


func _check_crush(normal: Vector2) -> void:
	if player_in_area == null:
		return
	if not player_in_area.has_method("hit"):
		return

	var player_pos = player_in_area.global_position
	var cube_pos = global_position
	var crushed = false

	if normal.x > 0.5 and player_pos.x < cube_pos.x:
		crushed = true
	elif normal.x < -0.5 and player_pos.x > cube_pos.x:
		crushed = true
	elif normal.y > 0.5 and player_pos.y < cube_pos.y:
		crushed = true
	elif normal.y < -0.5 and player_pos.y > cube_pos.y:
		crushed = true

	if crushed:
		player_in_area.hit()


func _start_wait(normal: Vector2) -> void:
	waiting = true
	wait_timer = wait_time

	if normal.x > 0.5:
		$AnimatedSprite2D.play("Left_hit")
		direction = Vector2.RIGHT
		move_mode = MoveMode.RIGHT
	elif normal.x < -0.5:
		$AnimatedSprite2D.play("Right_hit")
		direction = Vector2.LEFT
		move_mode = MoveMode.LEFT
	elif normal.y > 0.5:
		$AnimatedSprite2D.play("Top_hit")
		direction = Vector2.DOWN
		move_mode = MoveMode.DOWN
	elif normal.y < -0.5:
		$AnimatedSprite2D.play("Bottom_hit")
		direction = Vector2.UP
		move_mode = MoveMode.UP
