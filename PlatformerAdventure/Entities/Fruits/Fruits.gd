extends Area2D  

@onready var collision_shape = $CollisionShape2D  
@onready var animated_sprite = $AnimatedSprite2D  

func _ready():  
	animated_sprite.play("fruits")  
	
func _on_body_entered(body: Node2D):  
	if body.is_in_group("player"):  
		if get_parent() is Node2D:  
			pass  
		collision_shape.set_deferred("disabled", true)  
		animated_sprite.play("collected")  
		await get_tree().create_timer(0.5).timeout  
		queue_free()  
