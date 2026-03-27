extends Node2D

@export var show_hints: bool = true

const HINT_COLOR := Color(1.0, 1.0, 1.0, 0.08)
const LINE_WIDTH := 2.0
const CORNER_RADIUS := 30.0

const ZONE_LEFT  := Rect2(8,   480, 230, 220)
const ZONE_RIGHT := Rect2(260, 480, 230, 220)
const ZONE_JUMP  := Rect2(970, 480, 295, 220)

var _scale := Vector2.ONE

func _ready() -> void:
	show_hints = GameData.show_ctrl_hits  # читаем из сохранения
	get_viewport().size_changed.connect(_on_resize)
	_on_resize()
	
func _on_resize() -> void:
	var vp := get_viewport().get_visible_rect().size
	_scale = Vector2(vp.x / 1280.0, vp.y / 720.0)
	queue_redraw()

func _draw() -> void:
	if not show_hints:
		return
	_draw_rounded_rect(ZONE_LEFT)
	_draw_rounded_rect(ZONE_RIGHT)
	_draw_rounded_rect(ZONE_JUMP)

func _draw_rounded_rect(zone: Rect2) -> void:
	var r := zone
	r.position.x *= _scale.x
	r.position.y *= _scale.y
	r.size.x *= _scale.x
	r.size.y *= _scale.y

	var cr: float = CORNER_RADIUS * min(_scale.x, _scale.y)
	var segments := 8
	var points := PackedVector2Array()

	# Верхний левый угол
	for i in range(segments + 1):
		var a := PI + i * (PI * 0.5) / segments
		points.append(r.position + Vector2(cr, cr) + Vector2(cos(a), sin(a)) * cr)

	# Верхний правый угол
	for i in range(segments + 1):
		var a := -PI * 0.5 + i * (PI * 0.5) / segments
		points.append(r.position + Vector2(r.size.x - cr, cr) + Vector2(cos(a), sin(a)) * cr)

	# Нижний правый угол
	for i in range(segments + 1):
		var a := 0.0 + i * (PI * 0.5) / segments
		points.append(r.position + Vector2(r.size.x - cr, r.size.y - cr) + Vector2(cos(a), sin(a)) * cr)

	# Нижний левый угол
	for i in range(segments + 1):
		var a := PI * 0.5 + i * (PI * 0.5) / segments
		points.append(r.position + Vector2(cr, r.size.y - cr) + Vector2(cos(a), sin(a)) * cr)

	# Замыкаем
	points.append(points[0])
	draw_polyline(points, HINT_COLOR, LINE_WIDTH, true)
