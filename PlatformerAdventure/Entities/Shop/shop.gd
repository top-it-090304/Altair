extends Control

@onready var btn_shield: TextureButton = %TextureButton2
@onready var btn_slowmo: TextureButton = %TextureButton4
@onready var btn_magnet: TextureButton = %TextureButton3
@onready var count_shield_sprite: AnimatedSprite2D = %CountShield
@onready var count_slowmo_sprite: AnimatedSprite2D = %CountSlowmo
@onready var count_magnet_sprite: AnimatedSprite2D = %CountMagnet

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
	count_shield_sprite.frame = min(GameData.count_shield, 9)
	count_slowmo_sprite.frame = min(GameData.count_slowmo, 9)
	count_magnet_sprite.frame = min(GameData.count_magnet, 9)

func _on_buy_shield() -> void:
	GameData.buy_shield()
	_refresh_buttons()

func _on_buy_slowmo() -> void:
	GameData.buy_slowmo()
	_refresh_buttons()

func _on_buy_magnet() -> void:
	GameData.buy_magnet()
	_refresh_buttons()
