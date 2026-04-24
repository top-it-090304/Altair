# GameData.gd
# Путь: res://Entities/Shop/GameData.gd

extends Node

const SAVE_PATH = "user://save.cfg"

# false = уровни открываются по мере прохождения (боевой режим)
const DEV_UNLOCK_ALL: bool = false

const LEVEL_ORDER: Array = [
	"Level1", "Level2", "Level3", "Level4", "Level5",
	"Level6", "Level7", "Level8",
	"Level9", "Level10", "Level11", "Level12", "Level13",
	"Level14", "Level15", "Level16"
]

var level_records: Dictionary = {}
var total_fruits: int = 0
var _spent: int = 0
var show_ctrl_hits: bool = true
var tutorial_shown: bool = false
var tutorial_shown_9: bool = false
var tutorial_skip_shown: bool = false

# ── СЧЁТЧИК СМЕРТЕЙ (не сохраняется, живёт в памяти) ─────────────────────────
var current_level_deaths: int = 0
var bonuses_popup_shown: bool = false   # показали попап бонусов на этом уровне
var last_skip_popup_deaths: int = -1    # при каком количестве смертей последний раз показали попап пропуска
var _coming_from_death_reload: bool = false  # перезагрузка после смерти
var _tracked_level_path: String = ""

func reset_level_death_tracking(level_path: String) -> void:
	if _coming_from_death_reload:
		# Перезагрузка после смерти — счётчик не сбрасываем
		_coming_from_death_reload = false
		return
	# Свежий старт уровня (из меню или нового уровня) — сбрасываем
	current_level_deaths = 0
	bonuses_popup_shown = false
	last_skip_popup_deaths = -1
	_tracked_level_path = level_path

func record_death() -> void:
	current_level_deaths += 1
signal fruits_changed(new_total: int)

# Состояние возврата из магазина (return_position == ZERO = не задано)
var return_position: Vector2 = Vector2.ZERO
var return_collected_count: int = -1
var return_uncollected_positions: Array[Vector2] = []

# Количество в инвентаре
var count_shield: int = 0
var count_slowmo: int = 0
var count_magnet: int = 0

const PRICE_SHIELD: int = 10
const PRICE_SLOWMO: int = 10
const PRICE_MAGNET: int = 10

# Настройки звука (0.0 - 1.0)
var volume_master: float = 1.0
var volume_music: float = 1.0
var volume_sfx: float = 1.0

var ctrl_pos_left:  Vector2 = Vector2(125.0,  595.0)
var ctrl_pos_right: Vector2 = Vector2(376.0,  595.0)
var ctrl_pos_up:    Vector2 = Vector2(1120.0, 607.0)

func _ready() -> void:
	load_data()
	_apply_volumes()

# ── ФРУКТЫ ───────────────────────────────────

func submit_level_result(level_name: String, collected: int) -> void:
	var old_record = level_records.get(level_name, -1)
	if collected > old_record:
		level_records[level_name] = collected
		_recalculate_total()
		save_data()
	elif not level_records.has(level_name):
		level_records[level_name] = 0
		save_data()

func _recalculate_total() -> void:
	total_fruits = 0
	for record in level_records.values():
		total_fruits += record
	fruits_changed.emit(total_fruits)

func spend_fruits(amount: int) -> bool:
	if get_balance() < amount:
		return false
	_spent += amount
	save_data()
	fruits_changed.emit(get_balance())
	return true

func get_balance() -> int:
	return total_fruits - _spent

# ── ПОКУПКА ───────────────────────────────────

func buy_shield() -> bool:
	if not spend_fruits(PRICE_SHIELD):
		return false
	count_shield += 1
	save_data()
	return true

func buy_slowmo() -> bool:
	if not spend_fruits(PRICE_SLOWMO):
		return false
	count_slowmo += 1
	save_data()
	return true

func buy_magnet() -> bool:
	if not spend_fruits(PRICE_MAGNET):
		return false
	count_magnet += 1
	save_data()
	return true

# ── ИСПОЛЬЗОВАНИЕ ────────────────────────────

func use_shield() -> bool:
	if count_shield <= 0:
		return false
	count_shield -= 1
	save_data()
	return true

func use_slowmo() -> bool:
	if count_slowmo <= 0:
		return false
	count_slowmo -= 1
	save_data()
	return true

func use_magnet() -> bool:
	if count_magnet <= 0:
		return false
	count_magnet -= 1
	save_data()
	return true

# Совместимость с shop.gd
var purchased_shield: bool:
	get: return count_shield > 0

var purchased_slowmo: bool:
	get: return count_slowmo > 0

var purchased_magnet: bool:
	get: return count_magnet > 0

# ── ГРОМКОСТЬ ────────────────────────────────

func set_volume_master(value: float) -> void:
	volume_master = clamp(value, 0.0, 1.0)
	_apply_volumes()
	save_data()

func set_volume_music(value: float) -> void:
	volume_music = clamp(value, 0.0, 1.0)
	_apply_volumes()
	save_data()

func set_volume_sfx(value: float) -> void:
	volume_sfx = clamp(value, 0.0, 1.0)
	_apply_volumes()
	save_data()

func _apply_volumes() -> void:
	# Шина "Music"
	var music_idx = AudioServer.get_bus_index("Music")
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(volume_music))
		AudioServer.set_bus_mute(music_idx, volume_music <= 0.0)

	# Шина "SFX"
	var sfx_idx = AudioServer.get_bus_index("SFX")
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(volume_sfx))
		AudioServer.set_bus_mute(sfx_idx, volume_sfx <= 0.0)

# ── СОХРАНЕНИЕ / ЗАГРУЗКА ────────────────────

func save_data() -> void:
	var config = ConfigFile.new()
	config.set_value("player", "spent", _spent)
	config.set_value("shop", "shield", count_shield)
	config.set_value("shop", "slowmo", count_slowmo)
	config.set_value("shop", "magnet", count_magnet)
	config.set_value("audio", "volume_master", volume_master)
	config.set_value("audio", "volume_music", volume_music)
	config.set_value("audio", "volume_sfx", volume_sfx)
	config.set_value("settings", "show_ctrl_hits", show_ctrl_hits)
	config.set_value("ctrl_layout", "left_x",  ctrl_pos_left.x)
	config.set_value("ctrl_layout", "left_y",  ctrl_pos_left.y)
	config.set_value("ctrl_layout", "right_x", ctrl_pos_right.x)
	config.set_value("ctrl_layout", "right_y", ctrl_pos_right.y)
	config.set_value("ctrl_layout", "up_x",    ctrl_pos_up.x)
	config.set_value("ctrl_layout", "up_y",    ctrl_pos_up.y)
	config.set_value("tutorial", "shown", tutorial_shown)
	config.set_value("tutorial", "shown_9", tutorial_shown_9)
	config.set_value("tutorial", "skip_shown", tutorial_skip_shown)
	for level_name in level_records:
		config.set_value("records", level_name, level_records[level_name])
	config.save(SAVE_PATH)

func reset_ctrl_positions() -> void:
	ctrl_pos_left  = Vector2(125.0,  595.0)
	ctrl_pos_right = Vector2(376.0,  595.0)
	ctrl_pos_up    = Vector2(1120.0, 607.0)
	save_data()

func reset_progress() -> void:
	level_records.clear()
	total_fruits = 0
	_spent = 0
	count_shield = 0
	count_slowmo = 0
	count_magnet = 0
	tutorial_shown = false
	tutorial_shown_9 = false
	fruits_changed.emit(0)
	save_data()

func load_data() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	_spent = config.get_value("player", "spent", 0)
	count_shield = config.get_value("shop", "shield", 0)
	count_slowmo = config.get_value("shop", "slowmo", 0)
	count_magnet = config.get_value("shop", "magnet", 0)
	volume_master = config.get_value("audio", "volume_master", 1.0)
	volume_music  = config.get_value("audio", "volume_music",  1.0)
	volume_sfx    = config.get_value("audio", "volume_sfx",    1.0)
	show_ctrl_hits = config.get_value("settings", "show_ctrl_hits", true)
	ctrl_pos_left.x  = config.get_value("ctrl_layout", "left_x",  125.0)
	ctrl_pos_left.y  = config.get_value("ctrl_layout", "left_y",  595.0)
	ctrl_pos_right.x = config.get_value("ctrl_layout", "right_x", 376.0)
	ctrl_pos_right.y = config.get_value("ctrl_layout", "right_y", 595.0)
	ctrl_pos_up.x    = config.get_value("ctrl_layout", "up_x",    1120.0)
	ctrl_pos_up.y    = config.get_value("ctrl_layout", "up_y",    607.0)
	tutorial_shown = config.get_value("tutorial", "shown", false)
	tutorial_shown_9 = config.get_value("tutorial", "shown_9", false)
	tutorial_skip_shown = config.get_value("tutorial", "skip_shown", false)
	if config.has_section("records"):
		for key in config.get_section_keys("records"):
			level_records[key] = config.get_value("records", key, 0)
	_recalculate_total()

# ── ПРОГРЕСС УРОВНЕЙ ─────────────────────────

func is_level_completed(level_name: String) -> bool:
	if DEV_UNLOCK_ALL:
		return true
	return level_records.has(level_name)

func is_level_unlocked(level_index: int) -> bool:
	if DEV_UNLOCK_ALL:
		return true
	if level_index == 0:
		return true
	var prev_level = LEVEL_ORDER[level_index - 1]
	return is_level_completed(prev_level)

func get_progress_scene() -> String:
	# Find the first uncompleted level, open the menu for that character.
	# LEVEL_ORDER is 0-indexed: 0-7 PinkMan, 8-15 MaskDude
	# Future: 16-23 VirtualGuy, 24-31 NinjaFrog
	for i in LEVEL_ORDER.size():
		if not is_level_completed(LEVEL_ORDER[i]):
			return _level_index_to_menu_scene(i)
	# All levels completed — open last menu (MaskDude for now)
	return _level_index_to_menu_scene(LEVEL_ORDER.size() - 1)

func _level_index_to_menu_scene(index: int) -> String:
	if index < 8:
		return "res://Entities/Main/Levels_Menu.tscn"
	elif index < 16:
		return "res://Entities/Main/Level_Menu_MaskDude.tscn"
	# Placeholders for future characters — add when scenes exist
	# elif index < 24:
	#     return "res://Entities/Main/Level_Menu_VirtualGuy.tscn"
	# elif index < 32:
	#     return "res://Entities/Main/Level_Menu_NinjaFrog.tscn"
	return "res://Entities/Main/Levels_Menu.tscn"
