extends Control

@onready var anim: AnimatedSprite2D = $Right/AnimatedSprite2D
@onready var btn: Button = $Right

func _ready() -> void:
	anim.play("idle")
	anim.animation_finished.connect(_on_animation_finished)
	btn.button_down.connect(_on_press)
	btn.button_up.connect(_on_release)

func _on_press() -> void:
	anim.play("hit")

func _on_release() -> void:
	pass  
	
func _on_animation_finished() -> void:
	anim.play("idle")
