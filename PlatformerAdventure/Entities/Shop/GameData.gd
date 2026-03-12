extends Node

const SAVE_PATH = "user://save.cfg"

# Фрукты 
var level_records: Dictionary = {}
var total_fruits: int = 0
var _spent: int = 0

signal fruits_changed(new_total: int)

# --- Покупки в магазине ---
var purchased_shield: bool = false
var purchased_slowmo: bool = false
var purchased_magnet: bool = false

# Цены бонусов
const PRICE_SHIELD: int = 20
const PRICE_SLOWMO: int = 20
const PRICE_MAGNET: int = 20

func _ready() -> void:
	##ВРЕМЕННО
	
	load_data()
	purchased_slowmo = true 

# ФРУКТЫ

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

# МАГАЗИН — покупка бонусов

func buy_shield() -> bool:
	if purchased_shield:
		return false  # уже куплен
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

# СОХРАНЕНИЕ / ЗАГРУЗКА

func save_data() -> void:
	var config = ConfigFile.new()
	config.set_value("player", "spent", _spent)
	config.set_value("shop", "shield", purchased_shield)
	config.set_value("shop", "slowmo", purchased_slowmo)
	config.set_value("shop", "magnet", purchased_magnet)
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
	if config.has_section("records"):
		for key in config.get_section_keys("records"):
			level_records[key] = config.get_value("records", key, 0)
	_recalculate_total()
