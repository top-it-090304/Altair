extends Area2D

@onready var collision_shape = $CollisionShape2D
@onready var animated_sprite = $AnimatedSprite2D

func _ready():
	animated_sprite.play("fruits")
	body_entered.connect(_on_body_entered)
	monitoring = true
	monitorable = true

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		if get_parent() is Node2D:
			pass
			#get_parent().add_coin()
		collision_shape.disabled = true
		animated_sprite.play("collected")
		await get_tree().create_timer(0.5).timeout
		queue_free()
