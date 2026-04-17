extends TextureRect

@export var scroll_speed: float = 30.0

var _offset_y: float = 0.0
var _tex_h: float = 64.0

func _ready() -> void:
	stretch_mode = TextureRect.STRETCH_TILE
	_tex_h = float(texture.get_height()) if texture else 64.0
	if _tex_h <= 0.0:
		_tex_h = 64.0
	var vp_size := get_viewport().get_visible_rect().size
	size = Vector2(vp_size.x, vp_size.y + _tex_h)
	position = Vector2.ZERO

func _process(delta: float) -> void:
	_offset_y += scroll_speed * delta
	if _offset_y >= _tex_h:
		_offset_y -= _tex_h
	position.y = -_offset_y
