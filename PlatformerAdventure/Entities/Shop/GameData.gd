# GameData.gd
# Путь: res://Entities/Shop/GameData.gd

extends Node

const SAVE_PATH = "user://save.cfg"

# ВРЕМЕННО: true = все уровни разблокированы и зелёные (для тестирования)
# Перед релизом поставить false
const DEV_UNLOCK_ALL: bool = true

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
	for level_name in level_records:
		config.set_value("records", level_name, level_records[level_name])
	config.save(SAVE_PATH)

func reset_progress() -> void:
	level_records.clear()
	total_fruits = 0
	_spent = 0
	count_shield = 0
	count_slowmo = 0
	count_magnet = 0
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
