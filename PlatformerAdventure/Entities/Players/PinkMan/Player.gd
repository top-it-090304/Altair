extends CharacterBody2D

@export var speed = 400.0
@export var jump_velocity = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var double_jump_available = true

func _physics_process(delta):

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		double_jump_available = true

	if Input.is_action_just_pressed("move_up"):
		if is_on_floor():
			velocity.y = jump_velocity
		elif double_jump_available:
			velocity.y = jump_velocity
			double_jump_available = false

	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	if not is_on_floor():
		if velocity.y < 0:
			$AnimatedSprite2D.play("up")    
		else:
			$AnimatedSprite2D.play("fall")  
	else:
		if velocity.x != 0:
			$AnimatedSprite2D.play("run")   
		else:
			$AnimatedSprite2D.play("idle")  

	move_and_slide()
