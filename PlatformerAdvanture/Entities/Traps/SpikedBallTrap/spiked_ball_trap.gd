extends Node2D

func _on_ball_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hit()
