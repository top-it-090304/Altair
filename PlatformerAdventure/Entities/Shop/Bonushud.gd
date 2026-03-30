extends CanvasLayer

@onready var btn_shield: TextureButton = $PanelContainer/BonusList/BtnShield
@onready var btn_slowmo: TextureButton = $PanelContainer/BonusList/BtnSlowmo
@onready var btn_magnet: TextureButton = $PanelContainer/BonusList/BtnMagnet
@onready var bonus_list: VBoxContainer = $PanelContainer/BonusList

var _tween: Tween

func _ready() -> void:
	btn_shield.pressed.connect(_on_use_shield)
	btn_slowmo.pressed.connect(_on_use_slowmo)
	btn_magnet.pressed.connect(_on_use_magnet)
	
	_refresh()


func _refresh() -> void:
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
