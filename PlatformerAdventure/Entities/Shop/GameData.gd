# GameData.gd
extends Node

const SAVE_PATH = "user://save.cfg"

var level_records: Dictionary = {}
var total_fruits: int = 0
var _spent: int = 0

signal fruits_changed(new_total: int)

# Куплено
var purchased_shield: bool = false
var purchased_slowmo: bool = false
var purchased_magnet: bool = false

# Использовано (после использования нельзя снова)
var used_shield: bool = false
var used_slowmo: bool = false
var used_magnet: bool = false

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

# ── ПОКУПКА ──────────────────────────────────

func buy_shield() -> bool:
	if purchased_shield:
		return false
	if not spend_fruits(PRICE_SHIELD):
		return false
	purchased_shield = true
	save_data()
	return true

func buy_slowmo() -> bool:
	if purchased_slowmo:
		return false
	if not spend_fruits(PRICE_SLOWMO):
		return false
	purchased_slowmo = true
	save_data()
	return true

func buy_magnet() -> bool:
	if purchased_magnet:
		return false
	if not spend_fruits(PRICE_MAGNET):
		return false
	purchased_magnet = true
	save_data()
	return true

# ── ИСПОЛЬЗОВАНИЕ ────────────────────────────

func use_shield() -> bool:
	if not purchased_shield or used_shield:
		return false
	used_shield = true
	save_data()
	return true

func use_slowmo() -> bool:
	if not purchased_slowmo or used_slowmo:
		return false
	used_slowmo = true
	save_data()
	return true

func use_magnet() -> bool:
	if not purchased_magnet or used_magnet:
		return false
	used_magnet = true
	save_data()
	return true

# ── СОХРАНЕНИЕ / ЗАГРУЗКА ────────────────────

func save_data() -> void:
	var config = ConfigFile.new()
	config.set_value("player", "spent", _spent)
	config.set_value("shop", "shield", purchased_shield)
	config.set_value("shop", "slowmo", purchased_slowmo)
	config.set_value("shop", "magnet", purchased_magnet)
	config.set_value("used", "shield", used_shield)
	config.set_value("used", "slowmo", used_slowmo)
	config.set_value("used", "magnet", used_magnet)
	for level_name in level_records:
		config.set_value("records", level_name, level_records[level_name])
	config.save(SAVE_PATH)

func load_data() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	_spent = config.get_value("player", "spent", 0)
	purchased_shield = config.get_value("shop", "shield", false)
	purchased_slowmo = config.get_value("shop", "slowmo", false)
	purchased_magnet = config.get_value("shop", "magnet", false)
	used_shield = config.get_value("used", "shield", false)
	used_slowmo = config.get_value("used", "slowmo", false)
	used_magnet = config.get_value("used", "magnet", false)
	if config.has_section("records"):
		for key in config.get_section_keys("records"):
			level_records[key] = config.get_value("records", key, 0)
	_recalculate_total()
