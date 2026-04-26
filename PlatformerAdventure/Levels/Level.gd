# Level.gd
# Путь: res://Levels/Level.gd

extends Node2D

@onready var spawn_marker = $Entities/SpawnPoint
@onready var player: PlayerBase = $Entities/Player
@onready var flag = $Entities/Flag

@export_file("*.tscn") var next_level_path: String
@export var manual_fruit_count: int = 0
@export var show_fruit_counter: bool = true

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

# Время жизни игрока с момента загрузки уровня (для проверки >3 сек)
var _time_alive: float = 0.0

var used_shield: int = 0
var used_slowmo: int = 0
var used_magnet: int = 0

@onready var fruit_counter = preload("res://Entities/Level/Buttons/сounter.tscn").instantiate()

const TUTORIAL_SCENE  = preload("res://Entities/Level/UI/TutorialOverlay.tscn")
const CONFETTI_SCENE  = preload("res://Entities/Level/Effects/confetti_effect.tscn")
const VICTORY_SOUND   = preload("res://Assets/audio/Voicy_Level up sfx 2.mp3")
const DeathHelpPopup  = preload("res://Entities/Level/UI/death_help_popup.gd")

const MUSIC_LEVELS_1_8 = preload("res://Assets/audio/For_Levels/kissan4-pixel-paradise-358340.mp3")
const MUSIC_LEVELS_9_16 = preload("res://Assets/audio/maskdude1.mp3")

func _ready() -> void:
	var level_name := scene_file_path.get_file().get_basename()
	var level_num := level_name.trim_prefix("Level").to_int()
	if level_num >= 9:
		MusicManager.play_music(MUSIC_LEVELS_9_16)
	else:
		MusicManager.play_music(MUSIC_LEVELS_1_8)
	add_to_group("level")  # ← нужно для BonusHUD

	if player and spawn_marker:
		player.global_position = spawn_marker.global_position

	if GameData.return_position != Vector2.ZERO:
		player.global_position = GameData.return_position
		GameData.return_position = Vector2.ZERO

	if show_fruit_counter:
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
		player.died.connect(_on_player_died)

	# Инициализация счётчика смертей (сбрасывается только при свежем старте уровня)
	GameData.reset_level_death_tracking(scene_file_path)
	_check_death_popups_deferred()

	# Туториал о пропуске — один раз на уровнях 3 или 4
	if (level_num == 3 or level_num == 4) and not GameData.tutorial_skip_shown:
		_show_skip_tutorial_deferred()

	if level_num == 1 and not GameData.tutorial_shown:
		_show_tutorial("PinkMan", false, func():
			GameData.tutorial_shown = true
			GameData.save_data()
		)
	elif level_num == 9 and not GameData.tutorial_shown_9:
		_show_tutorial("MaskDude", true, func():
			GameData.tutorial_shown_9 = true
			GameData.save_data()
		)

	if GameData.return_collected_count >= 0:
		collected_count = GameData.return_collected_count
		if show_fruit_counter:
			fruit_counter.update_count(collected_count)
		for fruit in get_tree().get_nodes_in_group("fruits"):
			if not GameData.return_uncollected_positions.has(fruit.global_position):
				fruit.visible = false
				fruit.queue_free()
		GameData.return_collected_count = -1
		GameData.return_uncollected_positions.clear()


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
	player.speed               *= c
	player.acceleration        *= c
	player.friction            *= c
	player.gravity_fall        *= c
	player.gravity_rise        *= c
	player.max_fall_speed      *= c
	player.jump_velocity       *= c
	player.wall_slide_speed    *= c
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

func _show_tutorial(char_name: String, wall_jump: bool, on_close: Callable) -> void:
	player.can_move = false
	var tutorial := TUTORIAL_SCENE.instantiate()
	tutorial.character_name = char_name
	tutorial.show_wall_jump = wall_jump
	add_child(tutorial)
	tutorial.tutorial_closed.connect(func():
		if player:
			player.can_move = true
		on_close.call()
	)


func _on_level_completed() -> void:
	Engine.time_scale = 1.0
	_release_all_input()
	if player:
		player._invincibility_timer = 99.0
	var level_name = get_tree().current_scene.scene_file_path.get_file().get_basename()
	GameData.submit_level_result(level_name, collected_count)

	var victory_sfx := AudioStreamPlayer.new()
	victory_sfx.stream = VICTORY_SOUND
	victory_sfx.bus = &"SFX"
	victory_sfx.volume_db = 6.0
	add_child(victory_sfx)
	victory_sfx.play()

	var confetti = CONFETTI_SCENE.instantiate()
	get_tree().root.add_child(confetti)
	await confetti.play()
	confetti.queue_free()

	SceneManager.go_to(next_level_path)

func _release_all_input() -> void:
	for action in ["move_left", "move_right", "move_up"]:
		var event := InputEventAction.new()
		event.action = action
		event.pressed = false
		Input.parse_input_event(event)

# ── ФРУКТЫ ───────────────────────────────────

func _on_fruit_collected() -> void:
	collected_count += 1
	if show_fruit_counter:
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

# ── СЧЁТЧИК СМЕРТЕЙ И ПОПАПЫ ПОМОЩИ ─────────────────────────────────────────

func _process(delta: float) -> void:
	_time_alive += delta

func _on_player_died() -> void:
	# Флаг перезагрузки ставим всегда — иначе счётчик сбросится при быстрой смерти
	GameData._coming_from_death_reload = true
	# Сама смерть считается только если игрок прожил > 3 секунд
	if _time_alive > 3.0:
		GameData.current_level_deaths += 1

func _check_death_popups_deferred() -> void:
	# Небольшая задержка чтобы уровень успел отрисоваться
	await get_tree().create_timer(0.6).timeout
	if not is_instance_valid(self):
		return
	if _should_show_bonuses_popup():
		var popup := DeathHelpPopup.new()
		add_child(popup)
		popup.show_bonuses_popup(self)
	elif _should_show_skip_popup():
		var popup := DeathHelpPopup.new()
		add_child(popup)
		popup.show_skip_popup(self)

func _show_skip_tutorial_deferred() -> void:
	await get_tree().create_timer(1.2).timeout
	if not is_instance_valid(self):
		return
	var popup := DeathHelpPopup.new()
	add_child(popup)
	popup.show_skip_tutorial()

# 10 смертей — попап бонусов (только один раз за уровень)
func _should_show_bonuses_popup() -> bool:
	return GameData.current_level_deaths >= 2 and not GameData.bonuses_popup_shown

# 20, 35, 50, 65... — попап пропуска (каждые 15 после 20)
func _should_show_skip_popup() -> bool:
	var d := GameData.current_level_deaths
	if d < 4:
		return false
	if (d - 4) % 2 != 0:
		return false
	# Не показывать повторно при одном и том же количестве смертей
	return GameData.last_skip_popup_deaths != d
