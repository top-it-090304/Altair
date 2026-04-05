extends Node2D

const SCREEN_WIDTH: float = 1280.0
const SCREEN_HEIGHT: float = 720.0
const CLOUD_COUNT: int = 6
const TEXTURE_PATH: String = "res://Assets/Textures/Menu/Clouds V2.png"

var cloud_texture: Texture2D
var clouds: Array = []

class CloudData:
	var pos: Vector2
	var speed: float
	var scale_val: float

	func _init(x: float, y: float):
		pos = Vector2(x, y)
		speed = randf_range(25, 55)
		scale_val = randf_range(0.8, 1.6)

func _ready() -> void:
	cloud_texture = load(TEXTURE_PATH)
	for i in CLOUD_COUNT:
		var x = randf_range(0, SCREEN_WIDTH)
		var y = randf_range(30, SCREEN_HEIGHT * 0.45)
		clouds.append(CloudData.new(x, y))

func _process(delta: float) -> void:
	for cloud in clouds:
		cloud.pos.x -= cloud.speed * delta
		if cloud.pos.x < -300:
			cloud.pos.x = SCREEN_WIDTH + randf_range(0, 300)
			cloud.pos.y = randf_range(30, SCREEN_HEIGHT * 0.45)
	queue_redraw()

func _draw() -> void:
	if cloud_texture == null:
		return
	for cloud in clouds:
		draw_texture_rect(
			cloud_texture,
			Rect2(cloud.pos, cloud_texture.get_size() * cloud.scale_val),
			false
		)
