extends CharacterBody2D

@export var move_speed: float = 120.0
@export var gravity_value: float = 900.0
@export var idle_wait_time: float = 0.6
@export var stomp_bounce: float = -350.0

enum State { RUN, HITWALL, IDLE, DEAD }

var state: State = State.RUN
var direction: float = -1.0
var idle_timer: float = 0.0
var wall_check_cooldown: float = 0.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var body_area: Area2D = $BodyArea
@onready var stomp_area: Area2D = $StompArea
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var horn_shape: CollisionShape2D = $BodyArea/CollisionShape2D


func _ready() -> void:
	if scale.x < 0.0:
		direction = 1.0
		scale.x = 1.0
	animated_sprite.animation_finished.connect(_on_animation_finished)
	body_area.body_entered.connect(_on_body_area_body_entered)
	stomp_area.body_entered.connect(_on_stomp_area_body_entered)
	animated_sprite.play("run")
	animated_sprite.flip_h = direction > 0
	_update_horn_position()


func _update_horn_position() -> void:
	horn_shape.position.x = 22.0 * direction


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity_value * delta

	match state:
		State.RUN:
			velocity.x = direction * move_speed
			animated_sprite.flip_h = direction > 0
			if wall_check_cooldown > 0.0:
				wall_check_cooldown -= delta
			elif is_on_wall() and _is_real_wall():
				velocity.x = 0
				animated_sprite.play("hitwall")
				state = State.HITWALL

		State.HITWALL:
			velocity.x = 0

		State.IDLE:
			velocity.x = 0
			idle_timer -= delta
			if idle_timer <= 0.0:
				direction *= -1.0
				animated_sprite.flip_h = direction > 0
				animated_sprite.play("run")
				wall_check_cooldown = 0.2
				_update_horn_position()
				state = State.RUN

		State.DEAD:
			pass

	move_and_slide()


func _is_real_wall() -> bool:
	for i in get_slide_collision_count():
		var col := get_slide_collision(i)
		if abs(col.get_normal().x) > 0.5:
			if not col.get_collider().is_in_group("player"):
				return true
	return false


func _on_animation_finished() -> void:
	if state == State.HITWALL:
		animated_sprite.play("idle")
		idle_timer = idle_wait_time
		state = State.IDLE


func _on_body_area_body_entered(body: Node2D) -> void:
	if state == State.DEAD:
		return
	if body.is_in_group("player"):
		body.hit()


func _on_stomp_area_body_entered(body: Node2D) -> void:
	if state == State.DEAD:
		return
	if body.is_in_group("player") and body.velocity.y > 0:
		_die_rino()
		body.velocity.y = stomp_bounce


func _die_rino() -> void:
	state = State.DEAD
	velocity = Vector2.ZERO
	animated_sprite.play("hit")
	collision_shape.set_deferred("disabled", true)
	body_area.monitoring = false
	stomp_area.monitoring = false
	await animated_sprite.animation_finished
	queue_free()
