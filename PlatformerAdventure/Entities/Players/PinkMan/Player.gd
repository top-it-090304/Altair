extends CharacterBody2D
class_name PlayerBase

signal died

@export_group("Movement")
@export var speed = 300.0
@export var acceleration: float = 2000.0
@export var friction: float = 2000.0

@export_group("Jumping")
@export var jump_velocity: float = -450.0
@export var jump_cut_multiplier: float = 0.85
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12

@export_group("Wall Mechanics")
@export var wall_mechanics_enabled: bool = false
@export var wall_slide_speed: float = 50.0
@export var wall_jump_extra_x: float = 50.0
@export var wall_jump_extra_y: float = 50.0

@export_group("Double Jump")
@export var double_jump_enabled: bool = true

@export_group("Gravity")
@export var gravity_fall: float = 2200.0
@export var gravity_rise: float = 1600.0
@export var max_fall_speed: float = 900.0

@export_group("Magnet")
@export var magnet_radius_x: float = 120.0 * 1.5
@export var magnet_radius_y: float = 80.0 * 1.5
@export var magnet_pull_speed: float = 300.0

@export_group("Shield")

@export var shield_invincibility_duration: float = 1.0

# NODES
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D  = $CollisionShape2D
@onready var ray_up: RayCast2D        = $RayCastUp
@onready var ray_down: RayCast2D      = $RayCastDown
@onready var ray_left: RayCast2D      = $RayCastLeft
@onready var ray_right: RayCast2D     = $RayCastRight
@onready var ray_left_top: RayCast2D  = $RayCastLeftTop
@onready var ray_right_top: RayCast2D = $RayCastRightTop

@onready var sound_jump: AudioStreamPlayer2D = $SoundJump
@onready var sound_hit: AudioStreamPlayer2D  = $SoundHit

# STATE
var is_dead: bool = false
var animation_speed_compensate: float = 1.0

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

var is_jumping: bool = false
var is_wall_sliding: bool = false
var facing_right: bool = true

var _cling_wall_dir: int = 0

var double_jump_available: bool = false
var is_double_jumping: bool = false

var can_move: bool = true

# БОНУСЫ
var shield_active: bool = false
var magnet_active: bool = false
var _shield_visual: Node2D = null

var _invincibility_timer: float = 0.0

# INIT

func _ready() -> void:
	call_deferred("_connect_enemy_signals")

func _connect_enemy_signals() -> void:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.has_signal("stomped") and not enemy.stomped.is_connected(_on_enemy_stomped):
			enemy.stomped.connect(_on_enemy_stomped)

func _on_enemy_stomped() -> void:
	# Сигнал stomped не несёт ссылки на игрока — bounce вызывается напрямую из plant._die(),
	# здесь обработчик оставлен для внешних подписчиков (UI, счётчик убийств и т.п.).
	pass

# STOMP BOUNCE

# Скорость ДО move_and_slide() — нужна врагам для проверки стомпа,
# потому что body_entered срабатывает уже после того, как move_and_slide обнулил velocity.y
var velocity_before_slide: Vector2 = Vector2.ZERO

func stomp_bounce() -> void:
	velocity.y = -350.0

# PHYSICS

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	if not can_move:
		return

	var real_delta: float = delta / Engine.time_scale

	if _invincibility_timer > 0.0:
		_invincibility_timer -= real_delta

	_update_timers(real_delta)
	_apply_gravity(real_delta)

	if wall_mechanics_enabled:
		_handle_wall_cling()

	_handle_jump()
	_handle_movement(real_delta)
	_update_animation()

	velocity_before_slide = velocity
	move_and_slide()
	_check_deadly_tiles()

	if magnet_active:
		_attract_fruits(real_delta)

# ЩИТ

func activate_shield() -> void:
	shield_active = true
	_create_shield_visual()

func _create_shield_visual() -> void:
	if _shield_visual != null:
		_shield_visual.queue_free()
	_shield_visual = ShieldVisual.new()
	add_child(_shield_visual)

func activate_magnet() -> void:
	magnet_active = true

# МАГНИТ

func _attract_fruits(delta: float) -> void:
	var fruits = get_tree().get_nodes_in_group("fruits")
	for fruit in fruits:
		if not is_instance_valid(fruit):
			continue
		var diff: Vector2 = global_position - fruit.global_position
		var nx: float = diff.x / magnet_radius_x
		var ny: float = diff.y / magnet_radius_y
		if nx * nx + ny * ny <= 1.0:
			var direction: Vector2 = diff.normalized()
			fruit.global_position += direction * magnet_pull_speed * delta

# СМЕРТЬ / ПОПАДАНИЕ

func hit() -> void:
	if is_dead:
		return

	if _invincibility_timer > 0.0:
		return

	if shield_active:
		shield_active = false
		_break_shield()
		return

	_die_sequence()

func _break_shield() -> void:
	_invincibility_timer = shield_invincibility_duration

	if _shield_visual != null:
		_shield_visual.queue_free()
		_shield_visual = null

	sound_hit.play()

	_flash_break()

func _flash_break() -> void:
	animated_sprite.play("hit")

	for i in range(4):
		animated_sprite.modulate.a = 0.0
		await get_tree().create_timer(0.05).timeout
		animated_sprite.modulate.a = 1.0
		await get_tree().create_timer(0.05).timeout

	animated_sprite.modulate.a = 1.0

func _die_sequence() -> void:
	died.emit()
	is_dead = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	collision_shape.set_deferred("disabled", true)
	animated_sprite.play("hit")
	sound_hit.play()
	await get_tree().create_timer(1.0).timeout
	get_tree().reload_current_scene()

# DEADLY TILES

func _check_deadly_tiles() -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is TileMapLayer:
			var local_pos: Vector2 = collider.to_local(collision.get_position())
			var tile_pos: Vector2i = collider.local_to_map(local_pos)
			var tile_data: TileData  = collider.get_cell_tile_data(tile_pos)
			if tile_data and tile_data.get_custom_data("is_deadly"):
				hit()
				return

# TIMERS

func _update_timers(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time
		is_jumping = false
		is_double_jumping = false
		double_jump_available = double_jump_enabled
	elif coyote_timer > 0.0:
		coyote_timer -= delta

	if jump_buffer_timer > 0.0:
		jump_buffer_timer -= delta

# GRAVITY

func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	if is_wall_sliding:
		velocity.y = wall_slide_speed
		velocity.x = 0.0
		return
	var grav := gravity_fall if velocity.y > 0 else gravity_rise
	velocity.y = min(velocity.y + grav * delta, max_fall_speed)
	
# WALL CLING

func _handle_wall_cling() -> void:
	# Already clinging — exit on landing, wall lost, or pressing away.
	if is_wall_sliding:
		if is_on_floor():
			_exit_wall_cling()
			return
		if not _wall_detected_dir(_cling_wall_dir):
			_exit_wall_cling()
			return
		var input_x := Input.get_axis("move_left", "move_right")
		if input_x != 0.0 and sign(input_x) != _cling_wall_dir:
			_exit_wall_cling()
			return
		return

	# Entry: airborne + falling (velocity.y > 0) + touching wall via raycast.
	if is_on_floor():
		return
	if velocity.y <= 0.0:
		return

	var wall_dir := _detect_wall_dir()
	if wall_dir == 0:
		return

	# Pressing away from the detected wall — don't cling, let player pass freely.
	var input_x := Input.get_axis("move_left", "move_right")
	if input_x != 0.0 and sign(input_x) != wall_dir:
		return

	is_wall_sliding = true
	_cling_wall_dir = wall_dir
	facing_right = (wall_dir == 1)
	is_jumping = false
	is_double_jumping = false
	double_jump_available = double_jump_enabled

func _exit_wall_cling() -> void:
	is_wall_sliding = false
	_cling_wall_dir = 0

# Detects a wall via side raycasts. Returns -1 (left), +1 (right), or 0 (none).
# When both sides report a wall, the one the player is currently facing wins.
func _detect_wall_dir() -> int:
	ray_left.force_raycast_update()
	ray_right.force_raycast_update()
	var left_hit: bool = ray_left.is_colliding()
	var right_hit: bool = ray_right.is_colliding()
	if left_hit and right_hit:
		return 1 if facing_right else -1
	if right_hit:
		return 1
	if left_hit:
		return -1
	return 0

func _wall_detected_dir(direction: int) -> bool:
	if direction == 0:
		return false
	var ray: RayCast2D = ray_left if direction == -1 else ray_right
	ray.force_raycast_update()
	return ray.is_colliding()

# JUMP

func _handle_jump() -> void:
	if Input.is_action_just_pressed("move_up"):
		jump_buffer_timer = jump_buffer_time

	if Input.is_action_just_released("move_up") and is_jumping and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier
		is_jumping = false

	if wall_mechanics_enabled and is_wall_sliding:
		if jump_buffer_timer > 0.0:
			_do_wall_jump()
			return

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		is_jumping = true
		coyote_timer = 0.0
		jump_buffer_timer = 0.0
		sound_jump.play()
		return

	if double_jump_enabled and double_jump_available:
		if Input.is_action_just_pressed("move_up"):
			velocity.y = jump_velocity
			is_jumping = true
			is_double_jumping = true
			double_jump_available = false
			sound_jump.play()

func _do_wall_jump() -> void:
	velocity.y = jump_velocity - wall_jump_extra_y
	velocity.x = -_cling_wall_dir * wall_jump_extra_x
	coyote_timer = 0.0
	is_jumping = true
	jump_buffer_timer = 0.0
	_exit_wall_cling()
	sound_jump.play()

# MOVEMENT

func _handle_movement(delta: float) -> void:
	var input_x := Input.get_axis("move_left", "move_right")

	# While clinging, velocity.x is already zeroed by _apply_gravity; keep it zero
	if is_wall_sliding:
		velocity.x = 0.0
		return

	if input_x != 0.0:
		velocity.x = move_toward(velocity.x, input_x * speed, acceleration * delta)
		facing_right = input_x > 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

# ANIMATION

func _update_animation() -> void:
	animated_sprite.flip_h = not facing_right

	if wall_mechanics_enabled and is_wall_sliding:
		animated_sprite.speed_scale = 1.0
		animated_sprite.play("walljump")
		return

	if not is_on_floor():
		animated_sprite.speed_scale = 1.0
		if is_double_jumping:
			animated_sprite.play("doublejump")
		elif velocity.y < 0.0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
		return

	if abs(velocity.x) > 10.0:
		animated_sprite.speed_scale = clamp(abs(velocity.x) / 150.0, 0.5, 2.5) * animation_speed_compensate
		animated_sprite.play("run")
	else:
		animated_sprite.speed_scale = 1.0
		animated_sprite.play("idle")

# UTILITIES

func is_wall_in_direction(dir: Vector2) -> bool:
	var ray: RayCast2D
	if   dir.y < -0.5: ray = ray_up
	elif dir.y >  0.5: ray = ray_down
	elif dir.x < -0.5: ray = ray_left
	elif dir.x >  0.5: ray = ray_right
	else: return false
	ray.force_raycast_update()
	if not ray.is_colliding():
		return false
	var c = ray.get_collider()
	return c is StaticBody2D or c is TileMapLayer or c is AnimatableBody2D

func die() -> void:
	_die_sequence()
