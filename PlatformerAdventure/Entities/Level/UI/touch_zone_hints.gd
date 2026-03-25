extends Node2D

@export var show_hints: bool = true

# Цвет луж — серый, очень прозрачный
const HINT_COLOR := Color(0.5, 0.5, 0.5, 0.13)

# Зоны в базовом разрешении 1280x720
const ZONE_LEFT  := Rect2(0,   470, 250, 250)
const ZONE_RIGHT := Rect2(251, 470, 250, 250)
const ZONE_JUMP  := Rect2(960, 470, 320, 275)

var _scale := Vector2.ONE

func _ready() -> void:
	get_viewport().size_changed.connect(_on_resize)
	_on_resize()

func _on_resize() -> void:
	var vp := get_viewport().get_visible_rect().size
	_scale = Vector2(vp.x / 1280.0, vp.y / 720.0)
	queue_redraw()

func _draw() -> void:
	if not show_hints:
		return
	_draw_zone(ZONE_LEFT)
	_draw_zone(ZONE_RIGHT)
	_draw_zone(ZONE_JUMP)

func _draw_zone(zone: Rect2) -> void:
	# Переводим зону из базовых координат в экранные
	var center := Vector2(
		(zone.position.x + zone.size.x * 0.5) * _scale.x,
		(zone.position.y + zone.size.y * 0.5) * _scale.y
	)
	var radius_x := zone.size.x * 0.5 * _scale.x
	var radius_y := zone.size.y * 0.4 * _scale.y  # приплюснутый эллипс — "лужа"
	
	# Рисуем эллипс через полигон
	var points := PackedVector2Array()
	var segments := 48
	for i in range(segments):
		var angle := i * TAU / segments
		points.append(center + Vector2(cos(angle) * radius_x, sin(angle) * radius_y))
	
	draw_colored_polygon(points, HINT_COLOR)
