extends Node2D
class_name ShieldVisual

# Цвет 
const SHIELD_COLOR_FILL   := Color(0.3, 0.7, 1.0, 0.18)
const SHIELD_COLOR_BORDER := Color(0.5, 0.9, 1.0, 0.85)

# Размер овала 
const RADIUS_X: float = 22.0
const RADIUS_Y: float = 28.0
const BORDER_WIDTH: float = 2.5

# Скорость пульсации 
const PULSE_SPEED: float = 3.0
# Амплитуда пульсации 
const PULSE_AMP: float = 2.5

var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta
	queue_redraw()  

func _draw() -> void:
	# Пульсация
	var pulse: float = sin(_time * PULSE_SPEED) * PULSE_AMP

	var rx: float = RADIUS_X + pulse
	var ry: float = RADIUS_Y + pulse

	# Рисуем заполненный эллипс (тело щита)
	draw_arc_filled(rx, ry, SHIELD_COLOR_FILL)

	# Рисуем границу эллипса (обводка)
	draw_arc_border(rx, ry, SHIELD_COLOR_BORDER, BORDER_WIDTH)

## Рисуем заполненный эллипс через полигон из точек
func draw_arc_filled(rx: float, ry: float, color: Color) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var steps: int = 32  
	for i in range(steps + 1):
		var angle: float = (float(i) / float(steps)) * TAU
		points.append(Vector2(cos(angle) * rx, sin(angle) * ry))
	draw_colored_polygon(points, color)

## Рисуем обводку эллипса через набор линий
func draw_arc_border(rx: float, ry: float, color: Color, width: float) -> void:
	var points: PackedVector2Array = PackedVector2Array()
	var steps: int = 32
	for i in range(steps + 1):
		var angle: float = (float(i) / float(steps)) * TAU
		points.append(Vector2(cos(angle) * rx, sin(angle) * ry))
	# Рисуем полилинию (замкнутую)
	draw_polyline(points, color, width, true)
