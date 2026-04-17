extends CanvasLayer

@onready var hundreds_sprite: AnimatedSprite2D = $Control/AnimatedSprite_100s
@onready var tens_sprite: AnimatedSprite2D = $Control/AnimatedSprite_10s2
@onready var ones_sprite: AnimatedSprite2D = $Control/AnimatedSprite_1s

func _ready() -> void:
	hundreds_sprite.stop()
	tens_sprite.stop()
	ones_sprite.stop()
	hundreds_sprite.animation = "numbers"
	tens_sprite.animation = "numbers"
	ones_sprite.animation = "numbers"

	_update_count(GameData.get_balance())

	GameData.fruits_changed.connect(func(_v): _update_count(GameData.get_balance()))

func _update_count(count: int) -> void:
	var hundreds: int = count / 100
	var tens: int = (count % 100) / 10
	var ones: int = count % 10
	hundreds_sprite.frame = hundreds
	tens_sprite.frame = tens
	ones_sprite.frame = ones
func _on_texture_button_pressed() -> void:
	SceneManager.go_back("res://Entities/Main/MainMenu.tscn")
