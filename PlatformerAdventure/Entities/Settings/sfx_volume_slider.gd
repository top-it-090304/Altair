extends Control

@onready var knob = %Knob

var volume_level: int = 10
var dragging := false

# Координаты полоски (оставляем твои)
var min_x := 165.0
var max_x := 530.0
var knob_y := 487.0
var slider_width := 0.0

func _ready():
	slider_width = max_x - min_x
	update_knob_visual()
	apply_volume()

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if dragging:
				update_from_mouse(event.position.x)
	elif event is InputEventMouseMotion and dragging:
		update_from_mouse(event.position.x)

func update_from_mouse(mouse_x: float):
	var local_x = clamp(mouse_x, min_x, max_x)
	var step_size = slider_width / 10.0
	volume_level = round((local_x - min_x) / step_size)
	volume_level = clamp(volume_level, 0, 10)

	update_knob_visual()
	apply_volume()

func update_knob_visual():
	var step_size = slider_width / 10.0
	var knob_x = min_x + (volume_level * step_size)
	knob.position.x = knob_x - knob.size.x / 2.0
	knob.position.y = knob_y

func apply_volume():
	# Находим индекс шины по имени
	var bus_index = AudioServer.get_bus_index("SFX")
	
	if bus_index == -1:
		push_error("Шина SFX не найдена! Проверь вкладку Audio.")
		return

	# Переводим 0..10 в 0.0..1.0
	var normalized = volume_level / 10.0
	
	if volume_level <= 0:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_mute(bus_index, false)
		# Преобразуем линейное значение в децибелы
		var db = linear_to_db(normalized)
		AudioServer.set_bus_volume_db(bus_index, db)
