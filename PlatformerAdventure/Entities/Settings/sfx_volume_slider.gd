extends Control

@onready var knob = %Knob

var volume_level: int = 10
var dragging := false

# КООРДИНАТЫ ПОЛОСКИ (замени под свои)
var min_x := 165.0
var max_x := 530.0
var knob_y := 487.0

var slider_width := 0.0

# Все звуки эффектов
var sfx_players: Array = []

func _ready():
	slider_width = max_x - min_x

	print("slider_width = ", slider_width)
	print("min_x = ", min_x)
	print("max_x = ", max_x)

	_collect_sfx_players()

	update_knob_visual()
	apply_volume()


func _collect_sfx_players():
	sfx_players.clear()

	# =========================
	# 1. ЗВУКИ ИЗ SOUNDMANAGER
	# =========================
	if SoundManager.has_node("CollectSound"):
		sfx_players.append(SoundManager.get_node("CollectSound"))

	# Если потом добавишь ещё звуки в SoundManager:
	# if SoundManager.has_node("MenuClickSound"):
	#     sfx_players.append(SoundManager.get_node("MenuClickSound"))

	# =========================
	# 2. ЗВУКИ ИГРОКА
	# =========================
	var player = get_tree().get_first_node_in_group("player")

	if player:
		if player.has_node("JumpSound"):
			sfx_players.append(player.get_node("JumpSound"))

		if player.has_node("HurtSound"):
			sfx_players.append(player.get_node("HurtSound"))

		if player.has_node("DashSound"):
			sfx_players.append(player.get_node("DashSound"))

		# Если у тебя есть другие:
		# if player.has_node("StepSound"):
		#     sfx_players.append(player.get_node("StepSound"))

	print("Найдено SFX плееров: ", sfx_players.size())


func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if dragging:
				update_from_mouse(event.position.x)

	elif event is InputEventMouseMotion and dragging:
		update_from_mouse(event.position.x)


func update_from_mouse(mouse_x: float):
	mouse_x = clamp(mouse_x, min_x, max_x)

	var step_size = slider_width / 10.0
	volume_level = round((mouse_x - min_x) / step_size)
	volume_level = clamp(volume_level, 0, 10)

	update_knob_visual()
	apply_volume()


func update_knob_visual():
	var step_size = slider_width / 10.0
	var knob_x = min_x + (volume_level * step_size)

	knob.position.x = knob_x - knob.size.x / 2.0
	knob.position.y = knob_y


func apply_volume():
	var normalized = volume_level / 10.0
	var db = -80.0 if normalized <= 0.0 else linear_to_db(normalized)

	for sfx in sfx_players:
		if is_instance_valid(sfx):
			sfx.volume_db = db
