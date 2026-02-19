extends CharacterBody2D

enum MoveMode { UP, DOWN, LEFT, RIGHT, CIRKLE}

@export var move_mode: MoveMode = MoveMode.UP
@export var speed: float = 200.0
@export var wait_time: float = 1.5

var direction: Vector2
var waiting := false
var wait_timer := 0.0
var player_in_area = null
var up = false; var down = false; var left = false; var right = false

func _ready() -> void:
	match move_mode:
		MoveMode.UP:
			direction = Vector2.UP
		MoveMode.DOWN:
			direction = Vector2.DOWN
		MoveMode.LEFT:
			direction = Vector2.LEFT
		MoveMode.RIGHT:
			direction = Vector2.RIGHT
		MoveMode.CIRKLE:
			pass

	$CrushCheck.body_entered.connect(_on_crush_body_entered)
	$CrushCheck.body_exited.connect(_on_crush_body_exited)
	$AnimatedSprite2D.play("Idle")
func _on_crush_body_entered(body) -> void:
	if body.is_in_group("player"):
		player_in_area = body

func _on_crush_body_exited(body) -> void:
	if body == player_in_area:
		player_in_area = null

func _resume_move():
	$AnimatedSprite2D.play("Idle")

func _physics_process(delta: float) -> void:
	if waiting:
		wait_timer -= delta
		if wait_timer <= 0.0:
			waiting = false
			_resume_move()
		return

	velocity = direction * speed
	var collision = move_and_collide(velocity * delta) #Перемещаем и возвращаем не null если столкнулись
	if collision:
		_on_hit_wall(collision)
		_check_crush(collision)

func _on_hit_wall(collision):
	waiting = true
	wait_timer = wait_time
	velocity = Vector2.ZERO
	
	var n = collision.get_normal()
	
	if n.x > 0.5:
		$AnimatedSprite2D.play("Left_hit")
		direction = Vector2.RIGHT
		move_mode = MoveMode.RIGHT
	if n.x < -0.5:
		$AnimatedSprite2D.play("Right_hit")
		direction = Vector2.LEFT
		move_mode = MoveMode.LEFT
	if n.y > 0.5:
		$AnimatedSprite2D.play("Top_hit")
		direction = Vector2.DOWN
		move_mode = MoveMode.DOWN
	if n.y < -0.5:
		$AnimatedSprite2D.play("Bottom_hit")
		direction = Vector2.UP
		move_mode = MoveMode.UP
	
func _check_crush(collision):
	if player_in_area == null:
		return
	
	var n = collision.get_normal()
	var player = player_in_area
	var player_pos = player.global_position
	var cube_pos = global_position
	var crushed = false
	
	if n.x > 0.5 and player_pos.x < cube_pos.x:
		crushed = true
	elif n.x < -0.5 and player_pos.x > cube_pos.x:
		crushed = true
	elif n.y > 0.5 and player_pos.y < cube_pos.y:
		crushed = true
	elif n.y < -0.5 and player_pos.y > cube_pos.y:
		crushed = true
	
	if crushed and player.has_method("hit"):
		player.hit()
	
