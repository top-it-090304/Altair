extends Node2D

@onready var spawn_marker = $Entities/SpawnPoint
@onready var player: PlayerBase = $Entities/Player
@onready var flag = $Entities/Flag

@export_file("*.tscn") var next_level_path: String
@export var manual_fruit_count: int = 0

@export_group("Level Bonuses")
@export var allow_shield: bool = false
@export var allow_slowmo: bool = false
@export var allow_magnet: bool = false

@export_range(0.1, 1.0, 0.05) var slowmo_scale: float = 0.5

var total_fruits: int = 0
var collected_count: int = 0

@onready var fruit_counter = preload("res://Entities/Level/Buttons/сounter.tscn").instantiate()

func _ready() -> void:
	if player and spawn_marker:
		player.global_position = spawn_marker.global_position

	add_child(fruit_counter)
	fruit_counter.update_count(0)

	var fruits = get_tree().get_nodes_in_group("fruits")
	if manual_fruit_count > 0:
		total_fruits = manual_fruit_count
	else:
		total_fruits = fruits.size()

	for fruit in fruits:
		fruit.collected.connect(_on_fruit_collected)

	if flag:
		flag.level_completed.connect(_on_level_completed)

	_activate_bonuses()
	
# АКТИВАЦИЯ БОНУСОВ

func _activate_bonuses() -> void:
	if player == null:
		return
	# ЩИТ
	if allow_shield and GameData.purchased_shield:
		player.activate_shield()

	# ЗАМЕДЛЕНИЕ ВРЕМЕНИ
	if allow_slowmo and GameData.purchased_slowmo:
		Engine.time_scale = slowmo_scale
		#Компенсация скорости игрока
		player.speed *= (1.0 / slowmo_scale)
		player.acceleration *= (1.0 / slowmo_scale)
		player.friction *= (1.0 / slowmo_scale)

	# МАГНИТ
	if allow_magnet and GameData.purchased_magnet:
		player.activate_magnet()

# ЗАВЕРШЕНИЕ УРОВНЯ — сбрасываем Engine.time_scale

func _on_level_completed() -> void:
	# !!! всегда возвращаем скорость времени к норме при выходе с уровня
	Engine.time_scale = 1.0

	var level_name = get_tree().current_scene.scene_file_path.get_file().get_basename()
	GameData.submit_level_result(level_name, collected_count)
	get_tree().call_deferred("change_scene_to_file", next_level_path)

# ФРУКТЫ

func _on_fruit_collected() -> void:
	collected_count += 1
	fruit_counter.update_count(collected_count)
	if collected_count >= total_fruits:
		if flag:
			flag.activate()

func _on_button_pressed() -> void:
	Engine.time_scale = 1.0  # Сбрасываем при рестарте тоже
	get_tree().reload_current_scene()

# !!! сбрасываем time_scale если сцена выгружается
# (например через паузу → выход в меню)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		Engine.time_scale = 1.0
