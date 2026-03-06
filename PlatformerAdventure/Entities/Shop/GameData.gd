extends Node

const SAVE_PATH = "user://save.cfg"

var level_records: Dictionary = {}
var total_fruits: int = 0
var _spent: int = 0

signal fruits_changed(new_total: int)

func _ready() -> void:
	load_data()

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

func save_data() -> void:
	var config = ConfigFile.new()
	config.set_value("player", "spent", _spent)
	for level_name in level_records:
		config.set_value("records", level_name, level_records[level_name])
	config.save(SAVE_PATH)

func load_data() -> void:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	_spent = config.get_value("player", "spent", 0)
	
	if config.has_section("records"):
		for key in config.get_section_keys("records"):
			level_records[key] = config.get_value("records", key, 0)
	_recalculate_total()
