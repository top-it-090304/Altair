extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -350.0
@onready var spawn_point: Marker2D = get_parent().get_node("SpawnPoint")

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var double_jump_available = true
var wall_slide_timer: float = 0.0
var is_dead := false
const wall_hold_time: float = 1.0
const wall_slide_time: float = 4.0
const slide_speed: float = 100
var is_hanging = false


func _physics_process(delta):
	
	var platform_vel = get_platform_velocity()
		
	if is_on_wall() and not is_on_floor() and Input.get_axis("move_left", "move_right"):
		is_hanging = true
		if wall_slide_timer < wall_hold_time:
			velocity.y = 0
			wall_slide_timer += delta 
		else: 
			if wall_slide_timer < wall_slide_time:
				wall_slide_timer += delta
				velocity.y = slide_speed
			else:
				is_hanging = false
				
	else:
		wall_slide_timer = 0.0
		is_hanging = false
			
	if not is_on_floor() and not is_hanging:
		velocity.y += gravity * delta
		
	if is_on_floor():
		double_jump_available = true
		if platform_vel.y < 0:
			velocity.y = platform_vel.y	
		elif platform_vel.y > 0:
			velocity.y = platform_vel.y
	if Input.is_action_just_pressed("move_up"):
		if is_on_floor():
			velocity.y = jump_velocity
		elif double_jump_available:
			velocity.y = jump_velocity
			double_jump_available = false

	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed + platform_vel.x
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, platform_vel.x, speed)

	if not is_on_floor():
		if is_hanging:
			$AnimatedSprite2D.play("walljump")
		else:
			if velocity.y < 0:
				if double_jump_available == false:
					$AnimatedSprite2D.play("doublejump")    
				else:
					$AnimatedSprite2D.play("jump")    
			else:
				$AnimatedSprite2D.play("fall")  
	else:
		if velocity.x != 0:
			$AnimatedSprite2D.play("run")   
		else:
			$AnimatedSprite2D.play("idle")  
	move_and_slide()
	
func is_wall_in_direction(dir) -> bool:
	var ray : RayCast2D
	if dir.y < -0.5: 
		ray = $RayCastUp
	elif dir.y >  0.5: 
		ray = $RayCastDown
	elif dir.x < -0.5:
		ray = $RayCastLeft
	elif dir.x >  0.5:
		ray = $RayCastRight
	else: 
		return false
	ray.force_raycast_update()
	
	if not ray.is_colliding():
		return false
	
	var check = ray.get_collider()
	return check is StaticBody2D or check is TileMapLayer

func hit():
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	set_physics_process(false)
	$CollisionShape2D.set_deferred("disabled", true) 
	$AnimatedSprite2D.play("hit")
	await get_tree().create_timer(1.0).timeout
	die()
	
func die():
	if get_tree():                                     
		get_tree().reload_current_scene()
