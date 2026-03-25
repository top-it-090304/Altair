# BonusHUD.gd
extends CanvasLayer

@onready var btn_shield: TextureButton = $Panel/BtnShield
@onready var btn_slowmo: TextureButton = $Panel/BtnSlowmo
@onready var btn_magnet: TextureButton = $Panel/BtnMagnet

func _ready() -> void:
	btn_shield.pressed.connect(_on_use_shield)
	btn_slowmo.pressed.connect(_on_use_slowmo)
	btn_magnet.pressed.connect(_on_use_magnet)
	print("shield count: ", GameData.count_shield)
	_refresh()


func _refresh() -> void:
	# Серая если нет в инвентаре
	btn_shield.disabled = not GameData.purchased_shield
	btn_slowmo.disabled = not GameData.purchased_slowmo
	btn_magnet.disabled = not GameData.purchased_magnet


func _on_use_shield() -> void:
	if GameData.use_shield():
		_get_level().activate_shield_bonus()
	_refresh()

func _on_use_slowmo() -> void:
	if GameData.use_slowmo():
		_get_level().activate_slowmo_bonus()
	_refresh()

func _on_use_magnet() -> void:
	if GameData.use_magnet():
		_get_level().activate_magnet_bonus()
	_refresh()


func _get_level() -> Node:
	return get_tree().get_first_node_in_group("level")
