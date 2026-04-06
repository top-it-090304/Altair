extends CanvasLayer

@onready var tens_sprite: AnimatedSprite2D = $Control/AnimatedSprite_10s2
@onready var ones_sprite: AnimatedSprite2D = $Control/AnimatedSprite_1s

var collected_count: int = 0

func _ready() -> void:
	tens_sprite.stop()
	ones_sprite.stop()
	tens_sprite.animation = "numbers"
	ones_sprite.animation = "numbers"


func update_count(count: int) -> void:
	collected_count = count

	var tens: int = collected_count / 10
	var ones: int = collected_count % 10

	tens_sprite.frame = tens
	ones_sprite.frame = ones
