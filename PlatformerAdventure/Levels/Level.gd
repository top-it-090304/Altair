# Level.gd
# Путь: res://Levels/Level.gd

extends Node2D

@onready var spawn_marker = $Entities/SpawnPoint
@onready var player: PlayerBase = $Entities/Player
@onready var flag = $Entities/Flag

@export_file("*.tscn") var next_level_path: String
@export var manual_fruit_count: int = 0

@export_group("Level Bonuses")
@export var allow_shield: bool = true
@export var allow_slowmo: bool = true
@export var allow_magnet: bool = true

@export_range(0.1, 1.0, 0.05) var slowmo_scale: float = 0.5

@export_group("Bonus Limits")
@export var max_shield_uses: int = 1
@export var max_slowmo_uses: int = 2
@export var max_magnet_uses: int = 2

var total_fruits: int = 0
var collected_count: int = 0

var used_shield: int = 0
var used_slowmo: int = 0
var used_magnet: int = 0

@onready var fruit_counter = preload("res://Entities/Level/Buttons/сounter.tscn").instantiate()

func _ready() -> void:
	MusicManager.play_music(preload("res://Assets/audio/For_Levels/kissan4-pixel-paradise-358340.mp3"))
	add_to_group("level")  # ← нужно для BonusHUD

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

	if player:
		player.died.connect(reset_bonus_uses)


# ── БОНУСЫ — вызываются из BonusHUD ──────────

func can_use_shield() -> bool: return used_shield < max_shield_uses
func can_use_slowmo() -> bool: return used_slowmo < max_slowmo_uses
func can_use_magnet() -> bool: return used_magnet < max_magnet_uses

func activate_shield_bonus() -> void:
	if allow_shield and player and can_use_shield():
		used_shield += 1
		player.activate_shield()

func activate_slowmo_bonus() -> void:
	if not allow_slowmo or player == null or not can_use_slowmo():
		return
	used_slowmo += 1
	Engine.time_scale = slowmo_scale
	var c: float = 1.0 / slowmo_scale
	player.speed          *= c
	player.acceleration   *= c
	player.friction       *= c
	player.gravity_fall   *= c
	player.gravity_rise   *= c
	player.max_fall_speed *= c
	player.jump_velocity  *= c
	player.animated_sprite.speed_scale = c

func activate_magnet_bonus() -> void:
	if allow_magnet and player and can_use_magnet():
		used_magnet += 1
		player.activate_magnet()

func reset_bonus_uses() -> void:
	used_shield = 0
	used_slowmo = 0
	used_magnet = 0
	var hud = get_tree().get_first_node_in_group("bonus_hud")
	if hud:
		hud._refresh()


# ── ЗАВЕРШЕНИЕ УРОВНЯ ─────────────────────────

func _on_level_completed() -> void:
	Engine.time_scale = 1.0
	var level_name = get_tree().current_scene.scene_file_path.get_file().get_basename()
	GameData.submit_level_result(level_name, collected_count)
	Input.flush_buffered_events()
	get_tree().call_deferred("change_scene_to_file", next_level_path)


# ── ФРУКТЫ ───────────────────────────────────

func _on_fruit_collected() -> void:
	collected_count += 1
	fruit_counter.update_count(collected_count)
	if collected_count >= total_fruits:
		if flag:
			flag.activate()

func _on_button_pressed() -> void:
	reset_bonus_uses()
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		Engine.time_scale = 1.0
