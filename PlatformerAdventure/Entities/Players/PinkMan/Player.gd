extends CharacterBody2D
class_name PlayerBase

@export_group("Movement")
@export var speed = 300.0
@export var acceleration: float = 2000.0
@export var friction: float = 2000.0

@export_group("Jumping")
@export var jump_velocity: float = -450.0
@export var jump_cut_multiplier: float = 0.4
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12

@export_group("Wall Mechanics")
@export var wall_mechanics_enabled: bool = false
@export var wall_jump_velocity: Vector2 = Vector2(280.0, -400.0)
@export var wall_jump_input_lock_time: float = 0.25
@export var wall_slide_speed: float = 80.0
@export var wall_min_contact_height: float = 8.0

@export_group("Double Jump")
@export var double_jump_enabled: bool = true

@export_group("Gravity")
@export var gravity_fall: float = 2200.0
@export var gravity_rise: float = 1600.0
@export var max_fall_speed: float = 900.0

@export_group("Magnet")
@export var magnet_radius_x: float = 120.0
@export var magnet_radius_y: float = 80.0
@export var magnet_pull_speed: float = 300.0

@export_group("Shield")

@export var shield_invincibility_duration: float = 1.0

# NODES
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D  = $CollisionShape2D
@onready var ray_up: RayCast2D    = $RayCastUp
@onready var ray_down: RayCast2D  = $RayCastDown
@onready var ray_left: RayCast2D  = $Node2D/RayCastLeft
@onready var ray_right: RayCast2D = $Node2D/RayCastRight
@onready var sound_jump: AudioStreamPlayer2D = $SoundJump
@onready var sound_hit: AudioStreamPlayer2D  = $SoundHit

# STATE
var is_dead: bool = false
var animation_speed_compensate: float = 1.0

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var wall_jump_lock_timer: float = 0.0

var is_jumping: bool = false
var is_wall_sliding: bool = false
var facing_right: bool = true

var double_jump_available: bool = false
var is_double_jumping: bool = false

# БОНУСЫ
var shield_active: bool = false
var magnet_active: bool = false
var _shield_visual: Node2D = null

var _invincibility_timer: float = 0.0

# PHYSICS

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if _invincibility_timer > 0.0:
		_invincibility_timer -= delta

	_update_timers(delta)
	_apply_gravity(delta)

	if wall_mechanics_enabled:
		_handle_wall_slide()

	_handle_jump()
	_handle_movement(delta)
	_update_animation()

	move_and_slide()
	_check_deadly_tiles()

	if magnet_active:
		_attract_fruits(delta)

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

	if wall_jump_lock_timer > 0.0:
		wall_jump_lock_timer -= delta

# GRAVITY

func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	if is_wall_sliding:
		velocity.y = min(velocity.y + gravity_fall * delta, wall_slide_speed)
		return
	var grav := gravity_fall if velocity.y > 0 else gravity_rise
	velocity.y = min(velocity.y + grav * delta, max_fall_speed)
	
# WALL SLIDE

func _handle_wall_slide() -> void:
	is_wall_sliding = false
	if not (is_on_wall() and not is_on_floor() and velocity.y > 0.0):
		return
	var input_x := Input.get_axis("move_left", "move_right")
	var wall_normal := get_wall_normal()
	if input_x == 0.0 or sign(input_x) == sign(wall_normal.x):
		return
	is_wall_sliding = true

func _is_valid_wall_contact(wall_normal: Vector2) -> bool:
	var ray := ray_left if wall_normal.x > 0.0 else ray_right
	ray.force_raycast_update()
	if not ray.is_colliding():
		return false
	var contact_y := ray.get_collision_point().y
	var center_y  := global_position.y
	if contact_y > center_y + wall_min_contact_height:
		return false
	return true

# JUMP

func _handle_jump() -> void:
	if Input.is_action_just_pressed("move_up"):
		jump_buffer_timer = jump_buffer_time

	if Input.is_action_just_released("move_up") and is_jumping and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier
		is_jumping = false

	if wall_mechanics_enabled and is_on_wall() and not is_on_floor():
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
	var wall_normal := get_wall_normal()
	velocity.x = wall_normal.x * wall_jump_velocity.x
	velocity.y = wall_jump_velocity.y
	wall_jump_lock_timer = wall_jump_input_lock_time
	coyote_timer = 0.0
	is_jumping = true
	jump_buffer_timer = 0.0
	sound_jump.play()

# MOVEMENT

func _handle_movement(delta: float) -> void:
	var input_x := Input.get_axis("move_left", "move_right")
	if wall_jump_lock_timer > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, friction * 0.1 * delta)
		return
	if input_x != 0.0:
		velocity.x = move_toward(velocity.x, input_x * speed, acceleration * delta)
		if wall_jump_lock_timer <= 0.0:
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
