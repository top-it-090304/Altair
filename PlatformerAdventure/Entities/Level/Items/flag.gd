extends Area2D

signal level_completed

var is_active = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimatedSprite2D.play("No")
	monitoring = false
	body_entered.connect(_on_body_entered)
	activate()

func activate():
	is_active = true
	monitoring = true
	$AnimatedSprite2D.play("Out")
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("Idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_body_entered(body):
	if not is_active:
		return
	if body.is_in_group("player"):
		level_completed.emit()
		
