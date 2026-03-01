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
@export var wall_jump_input_lock_time: float = 0.18
@export var wall_slide_speed: float = 80.0
@export var wall_min_contact_height: float = 8.0

@export_group("Double Jump")
@export var double_jump_enabled: bool = true

@export_group("Gravity")
@export var gravity_fall: float = 2200.0
@export var gravity_rise: float = 1600.0
@export var max_fall_speed: float = 900.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D  = $CollisionShape2D
@onready var ray_up: RayCast2D    = $RayCastUp
@onready var ray_down: RayCast2D  = $RayCastDown
@onready var ray_left: RayCast2D  = $RayCastLeft
@onready var ray_right: RayCast2D = $RayCastRight
@onready var sound_jump: AudioStreamPlayer2D = $SoundJump
@onready var sound_hit: AudioStreamPlayer2D  = $SoundHit

var is_dead: bool = false

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var wall_jump_lock_timer: float = 0.0

var is_jumping: bool = false
var is_wall_sliding: bool = false
var facing_right: bool = true

var double_jump_available: bool = false
var is_double_jumping: bool = false

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	_update_timers(delta)
	_apply_gravity(delta)
	
	if wall_mechanics_enabled:
		_handle_wall_slide()
	
	_handle_jump()
	_handle_movement(delta)
	_update_animation()
	
	move_and_slide()

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
	
func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		return
	
	if is_wall_sliding:
		velocity.y = min(velocity.y + gravity_fall * delta, wall_slide_speed)
		return
	
	var grav := gravity_fall if velocity.y > 0 else gravity_rise
	velocity.y = min(velocity.y + grav * delta, max_fall_speed)

func _handle_wall_slide() -> void:
	is_wall_sliding = false
	
	if not (is_on_wall() and not is_on_floor() and velocity.y > 0.0):
		return
	
	var input_x := Input.get_axis("move_left", "move_right")
	var wall_normal := get_wall_normal()
	
	if input_x == 0.0 or sign(input_x) == sign(wall_normal.x):
		return

	if not _is_valid_wall_contact(wall_normal):
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

func _handle_jump() -> void:
	if Input.is_action_just_pressed("move_up"):
		print("JUMP PRESSED")
		jump_buffer_timer = jump_buffer_time
	
	if Input.is_action_just_released("move_up") and is_jumping and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier
		is_jumping = false
	
	if wall_mechanics_enabled and is_on_wall() and not is_on_floor():
		if Input.is_action_just_pressed("move_up"):
			if _is_valid_wall_contact(get_wall_normal()):
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
	velocity.x = wall_normal.x * wall_jump_velocity.x #Нормаль дает направление ОТ стены
	velocity.y = wall_jump_velocity.y
	wall_jump_lock_timer = wall_jump_input_lock_time
	coyote_timer = 0.0
	is_jumping = true
	jump_buffer_timer = 0.0
	sound_jump.play()

func _handle_movement(delta: float) -> void:
	var input_x := Input.get_axis("move_left", "move_right")

	if wall_jump_lock_timer > 0.0:
		input_x *= 0.3

	if input_x != 0.0:
		velocity.x = move_toward(velocity.x, input_x * speed, acceleration * delta)
		if wall_jump_lock_timer <= 0.0:
			facing_right = input_x > 0.0
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

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
		animated_sprite.speed_scale = clamp(abs(velocity.x) / 150.0, 0.5, 2.5)
		animated_sprite.play("run")
	else:
		animated_sprite.speed_scale = 1.0
		animated_sprite.play("idle")

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

func hit() -> void:
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	collision_shape.set_deferred("disabled", true)
	animated_sprite.play("hit")
	sound_hit.play()
	await get_tree().create_timer(1.0).timeout
	die()

func die() -> void:
	if get_tree():
		get_tree().reload_current_scene()
