extends CanvasLayer

@onready var btn_shield: TextureButton = $PanelContainer/BonusList/BtnShield
@onready var btn_slowmo: TextureButton = $PanelContainer/BonusList/BtnSlowmo
@onready var btn_magnet: TextureButton = $PanelContainer/BonusList/BtnMagnet

@onready var count_shield_sprite: AnimatedSprite2D = $PanelContainer/BonusList/BtnShield/CountShield
@onready var count_slowmo_sprite: AnimatedSprite2D = $PanelContainer/BonusList/BtnSlowmo/CountSlowmo
@onready var count_magnet_sprite: AnimatedSprite2D = $PanelContainer/BonusList/BtnMagnet/CountMagnet

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

	btn_shield.disabled = not can_shield
	btn_slowmo.disabled = not can_slowmo
	btn_magnet.disabled = not can_magnet

	count_shield_sprite.frame = min(GameData.count_shield, 9)
	count_slowmo_sprite.frame = min(GameData.count_slowmo, 9)
	count_magnet_sprite.frame = min(GameData.count_magnet, 9)

func _show_shop_dialog() -> void:
	get_tree().paused = true

	var dialog = CanvasLayer.new()
	dialog.layer = 20
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS

	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.5)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)

	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(320, 120)
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -160.0
	panel.offset_top = -60.0
	panel.offset_right = 160.0
	panel.offset_bottom = 60.0

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 10
	vbox.offset_top = 10
	vbox.offset_right = -10
	vbox.offset_bottom = -10

	var lbl = Label.new()
	lbl.text = "Бонуса нет! Открыть магазин?"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 16)

	var btn_yes = Button.new()
	btn_yes.text = "Да"
	btn_yes.custom_minimum_size = Vector2(100, 36)

	var btn_no = Button.new()
	btn_no.text = "Нет"
	btn_no.custom_minimum_size = Vector2(100, 36)

	hbox.add_child(btn_yes)
	hbox.add_child(btn_no)
	vbox.add_child(lbl)
	vbox.add_child(hbox)
	panel.add_child(vbox)
	dialog.add_child(bg)
	dialog.add_child(panel)
	add_child(dialog)

	btn_no.pressed.connect(func():
		get_tree().paused = false
		dialog.queue_free()
	)

	btn_yes.pressed.connect(func():
		get_tree().paused = false
		dialog.queue_free()
		SceneManager.go_to("res://Entities/Shop/shop.tscn")
	)

func _on_use_shield() -> void:
	if GameData.count_shield == 0:
		_show_shop_dialog()
		return
	if GameData.use_shield():
		var level = _get_level()
		if level: level.activate_shield_bonus()
	_refresh()

func _on_use_slowmo() -> void:
	if GameData.count_slowmo == 0:
		_show_shop_dialog()
		return
	if GameData.use_slowmo():
		var level = _get_level()
		if level: level.activate_slowmo_bonus()
	_refresh()

func _on_use_magnet() -> void:
	if GameData.count_magnet == 0:
		_show_shop_dialog()
		return
	if GameData.use_magnet():
		var level = _get_level()
		if level: level.activate_magnet_bonus()
	_refresh()

func _get_level() -> Node:
	return get_tree().get_first_node_in_group("level")
