# GameData.gd
extends Node

const SAVE_PATH = "user://save.cfg"

var level_records: Dictionary = {}
var total_fruits: int = 0
var _spent: int = 0

signal fruits_changed(new_total: int)

# Количество в инвентаре
var count_shield: int = 0
var count_slowmo: int = 0
var count_magnet: int = 0

const PRICE_SHIELD: int = 10
const PRICE_SLOWMO: int = 10
const PRICE_MAGNET: int = 10

func _ready() -> void:
	load_data()

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

# ── ПОКУПКА — можно покупать сколько угодно ──

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

# ── СОХРАНЕНИЕ / ЗАГРУЗКА ────────────────────

func save_data() -> void:
	var config = ConfigFile.new()
	config.set_value("player", "spent", _spent)
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
	count_shield = config.get_value("shop", "shield", 0)
	count_slowmo = config.get_value("shop", "slowmo", 0)
	count_magnet = config.get_value("shop", "magnet", 0)
	if config.has_section("records"):
		for key in config.get_section_keys("records"):
			level_records[key] = config.get_value("records", key, 0)
	_recalculate_total()
