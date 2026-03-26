
extends Control

@onready var btn_shield: TextureButton = %TextureButton2
@onready var btn_slowmo: TextureButton = %TextureButton4
@onready var btn_magnet: TextureButton = %TextureButton3

func _ready() -> void:
	btn_shield.pressed.connect(_on_buy_shield)
	btn_slowmo.pressed.connect(_on_buy_slowmo)
	btn_magnet.pressed.connect(_on_buy_magnet)

	_refresh_buttons()
	GameData.fruits_changed.connect(func(_v): _refresh_buttons())


func _refresh_buttons() -> void:
	var balance := GameData.get_balance()
	btn_shield.disabled = balance < GameData.PRICE_SHIELD
	btn_slowmo.disabled = balance < GameData.PRICE_SLOWMO
	btn_magnet.disabled = balance < GameData.PRICE_MAGNET


func _on_buy_shield() -> void:
	GameData.buy_shield()
	_refresh_buttons()

func _on_buy_slowmo() -> void:
	GameData.buy_slowmo()
	_refresh_buttons()

func _on_buy_magnet() -> void:
	GameData.buy_magnet()
	_refresh_buttons()
