extends Node2D
class_name MagnetVisual

@export var ring_color: Color = Color(1.0, 0.85, 0.1, 1.0)
@export var ring_count: int = 3
@export var wave_speed: float = 0.7
@export var wave_frequency: float = 1.0
@export var max_radius_x: float = 90.0
@export var max_radius_y: float = 60.0

var _time: float = 0.0

func _process(delta: float) -> void:
	_time += delta / Engine.time_scale
	queue_redraw()

func _draw() -> void:
	for i in ring_count:
		var t: float = fmod(_time * wave_speed + float(i) / float(ring_count), 1.0)
		var alpha: float = t * 0.75
		var rx: float = max_radius_x * (1.0 - t)
		var ry: float = max_radius_y * (1.0 - t)
		var color: Color = Color(ring_color.r, ring_color.g, ring_color.b, alpha)
		var points: PackedVector2Array = PackedVector2Array()
		var segments: int = 32
		for j in segments:
			var angle: float = TAU * float(j) / float(segments)
			points.append(Vector2(cos(angle) * rx, sin(angle) * ry))
		points.append(points[0])
		draw_polyline(points, color, 1.5)
