extends Node

const SAVE_PATH = "user://save.cfg"

var level_records: Dictionary = {}
var total_fruits: int = 0
var _spent: int = 0
var sfx_volume: int = 10 # Переменная для звука
signal fruits_changed(new_total: int)

# Количество в инвентаре
var count_shield: int = 0
var count_slowmo: int = 0
var count_magnet: int = 0

const PRICE_SHIELD: int = 10
const PRICE_SLOWMO: int = 10
const PRICE_MAGNET: int = 10

var purchased_shield: bool:
	get: return count_shield > 0
var purchased_slowmo: bool:
	get: return count_slowmo > 0
var purchased_magnet: bool:
	get: return count_magnet > 0

func _ready() -> void:
	load_data()
	apply_audio_settings() # Применяем звук при старте

# ── ЗВУК (НОВОЕ) ─────────────────────────────

func apply_audio_settings() -> void:
	var bus_index = AudioServer.get_bus_index("SFX")
	if bus_index != -1:
		var normalized = sfx_volume / 10.0
		AudioServer.set_bus_mute(bus_index, sfx_volume <= 0)
		if sfx_volume > 0:
			AudioServer.set_bus_volume_db(bus_index, linear_to_db(normalized))

# ── ФРУКТЫ ───────────────────────────────────

func submit_level_result(level_name: String, collected: int) -> void:
	var old_record = level_records.get(level_name, 0)
	if collected > old_record:
		level_records[level_name] = collected
		_recalculate_total()
		save_data()

func _recalculate_total() -> void:
	total_fruits = 0
	for record in level_records.values():
		total_fruits += record
	fruits_changed.emit(get_balance())

func spend_fruits(amount: int) -> bool:
	if get_balance() < amount:
		return false
	_spent += amount
	save_data()
	fruits_changed.emit(get_balance())
	return true

func get_balance() -> int:
	return total_fruits - _spent

# ── ПОКУПКА ──────────────────────────────────

func buy_shield() -> bool:
	if not spend_fruits(PRICE_SHIELD): return false
	count_shield += 1
	save_data()
	return true

func buy_slowmo() -> bool:
	if not spend_fruits(PRICE_SLOWMO): return false
	count_slowmo += 1
	save_data()
	return true

func buy_magnet() -> bool:
	if not spend_fruits(PRICE_MAGNET): return false
	count_magnet += 1
	save_data()
	return true

# ── ИСПОЛЬЗОВАНИЕ ────────────────────────────

func use_shield() -> bool:
	if count_shield <= 0: return false
	count_shield -= 1
	save_data()
	return true

func use_slowmo() -> bool:
	if count_slowmo <= 0: return false
	count_slowmo -= 1
	save_data()
	return true

func use_magnet() -> bool:
	if count_magnet <= 0: return false
	count_magnet -= 1
	save_data()
	return true

# ── СОХРАНЕНИЕ / ЗАГРУЗКА ────────────────────

func save_data() -> void:
	var config = ConfigFile.new()
	config.set_value("player", "spent", _spent)
	config.set_value("audio", "sfx_volume", sfx_volume) # Сохраняем звук
	config.set_value("shop", "shield", count_shield)
	config.set_value("shop", "slowmo", count_slowmo)
	config.set_value("shop", "magnet", count_magnet)
	for level_name in level_records:
		config.set_value("records", level_name, level_records[level_name])
	config.save(SAVE_PATH)

func load_data() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	_spent = config.get_value("player", "spent", 0)
	sfx_volume = config.get_value("audio", "sfx_volume", 10) # Загружаем звук
	count_shield = config.get_value("shop", "shield", 0)
	count_slowmo = config.get_value("shop", "slowmo", 0)
	count_magnet = config.get_value("shop", "magnet", 0)
	if config.has_section("records"):
		for key in config.get_section_keys("records"):
			level_records[key] = config.get_value("records", key, 0)
	_recalculate_total()
	apply_audio_settings() # Сразу применяем загруженный звук
