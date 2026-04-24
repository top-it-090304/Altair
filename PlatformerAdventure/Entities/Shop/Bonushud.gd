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

func _make_btn_style(bg: Color, border: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.border_width_left = 2
	s.border_width_top = 2
	s.border_width_right = 2
	s.border_width_bottom = 2
	s.corner_radius_top_left = 6
	s.corner_radius_top_right = 6
	s.corner_radius_bottom_right = 6
	s.corner_radius_bottom_left = 6
	return s

func _style_button(btn: Button, font: Font) -> void:
	btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	btn.add_theme_font_override("font", font)
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_stylebox_override("normal",  _make_btn_style(Color(0.20, 0.20, 0.30), Color(0.40, 0.40, 0.50)))
	btn.add_theme_stylebox_override("hover",   _make_btn_style(Color(0.28, 0.28, 0.42), Color(0.55, 0.55, 0.70)))
	btn.add_theme_stylebox_override("pressed", _make_btn_style(Color(0.15, 0.15, 0.25), Color(0.35, 0.35, 0.45)))
	btn.add_theme_stylebox_override("focus",   _make_btn_style(Color(0, 0, 0, 0), Color(0, 0, 0, 0)))

func _show_shop_dialog() -> void:
	get_tree().paused = true
	var font: Font = preload("res://Assets/Fonts/EpilepsySansBold.ttf")

	var dialog := CanvasLayer.new()
	dialog.layer = 20
	dialog.process_mode = Node.PROCESS_MODE_ALWAYS

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.7)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.12, 0.12, 0.18, 1.0)
	panel_style.border_color = Color(0.4, 0.4, 0.5, 1.0)
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.corner_radius_bottom_left = 8

	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -190.0
	panel.offset_top = -75.0
	panel.offset_right = 190.0
	panel.offset_bottom = 75.0
	panel.add_theme_stylebox_override("panel", panel_style)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 24)

	var lbl := Label.new()
	lbl.text = "Бонуса нет! Открыть магазин?"
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	lbl.add_theme_font_override("font", font)
	lbl.add_theme_font_size_override("font_size", 22)

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 16)

	var btn_yes := Button.new()
	btn_yes.text = "Да"
	btn_yes.custom_minimum_size = Vector2(100, 40)
	_style_button(btn_yes, font)

	var btn_no := Button.new()
	btn_no.text = "Нет"
	btn_no.custom_minimum_size = Vector2(100, 40)
	_style_button(btn_no, font)

	hbox.add_child(btn_yes)
	hbox.add_child(btn_no)
	vbox.add_child(lbl)
	vbox.add_child(hbox)
	center.add_child(vbox)
	panel.add_child(center)
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
		var level = _get_level()
		if level:
			var p = level.get("player")
			if p:
				GameData.return_position = p.global_position
			var cc = level.get("collected_count")
			GameData.return_collected_count = cc if cc != null else 0
			GameData.return_uncollected_positions.clear()
			for fruit in get_tree().get_nodes_in_group("fruits"):
				GameData.return_uncollected_positions.append(fruit.global_position)
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
