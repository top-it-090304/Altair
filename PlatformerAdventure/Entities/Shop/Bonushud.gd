extends CanvasLayer

@onready var btn_shield: TextureButton = $PanelContainer/BonusList/BtnShield
@onready var btn_slowmo: TextureButton = $PanelContainer/BonusList/BtnSlowmo
@onready var btn_magnet: TextureButton = $PanelContainer/BonusList/BtnMagnet

func _ready() -> void:
	add_to_group("bonus_hud")
	btn_shield.pressed.connect(_on_use_shield)
	btn_slowmo.pressed.connect(_on_use_slowmo)
	btn_magnet.pressed.connect(_on_use_magnet)
	call_deferred("_refresh")

func _refresh() -> void:
	var level = _get_level()
	var can_shield: bool = level == null or level.can_use_shield()
	var can_slowmo: bool = level == null or level.can_use_slowmo()
	var can_magnet: bool = level == null or level.can_use_magnet()

	btn_shield.disabled = GameData.count_shield <= 0 or not can_shield
	btn_slowmo.disabled = GameData.count_slowmo <= 0 or not can_slowmo
	btn_magnet.disabled = GameData.count_magnet <= 0 or not can_magnet

func _on_use_shield() -> void:
	if GameData.use_shield():
		var level = _get_level()
		if level: level.activate_shield_bonus()
	_refresh()

func _on_use_slowmo() -> void:
	if GameData.use_slowmo():
		var level = _get_level()
		if level: level.activate_slowmo_bonus()
	_refresh()

func _on_use_magnet() -> void:
	if GameData.use_magnet():
		var level = _get_level()
		if level: level.activate_magnet_bonus()
	_refresh()

func _get_level() -> Node:
	return get_tree().get_first_node_in_group("level")
