# death_help_popup.gd
# Попапы помощи при частых смертях.
# Используется как: var p = DeathHelpPopup.new(); level.add_child(p); p.show_*()
extends CanvasLayer

const FONT          := preload("res://Assets/Fonts/EpilepsySansBold.ttf")
const VICTORY_SOUND := preload("res://Assets/audio/Voicy_Level up sfx 2.mp3")
const CONFETTI      := preload("res://Entities/Level/Effects/confetti_effect.tscn")
const SKIP_COST: int  = 50
const BONUS_COST: int = 10

func _ready() -> void:
	layer = 12
	process_mode = Node.PROCESS_MODE_ALWAYS

# ── ПОПАП БОНУСОВ (10 смертей, один раз за уровень) ──────────────────────────

func show_bonuses_popup(_level_ref: Node) -> void:
	get_tree().paused = true
	GameData.bonuses_popup_shown = true

	var vbox := _build_frame(-245.0, -158.0, 245.0, 158.0)
	_add_title(vbox, "Уровень даётся тяжело?")
	_add_sep(vbox)
	_add_label(vbox, "Тебе помогут бонусы:", 14, Color(0.75, 0.75, 0.75))

	_add_bonus_row(vbox, "Щит",        "защитит от одного удара")
	_add_bonus_row(vbox, "Замедление", "время замедляется на попытку")
	_add_bonus_row(vbox, "Магнит",     "притягивает ближайшие фрукты")

	_add_sep(vbox)
	_add_label(vbox, "Купить бонусы можно в магазине", 13, Color(1.0, 0.78, 0.28))

	var btn_cont := _action_btn("Играть дальше", Color(0.15, 0.45, 0.15), Color(0.25, 0.60, 0.25))
	vbox.add_child(btn_cont)

	btn_cont.pressed.connect(func():
		get_tree().paused = false
		queue_free()
	)

# ── ПОПАП ПРОПУСКА УРОВНЯ (20, 35, 50, 65...) ────────────────────────────────

func show_skip_popup(level_ref: Node) -> void:
	get_tree().paused = true
	GameData.last_skip_popup_deaths = GameData.current_level_deaths

	var vbox := _build_frame(-230.0, -110.0, 230.0, 110.0)
	_add_title(vbox, "Уровень даётся тяжело...", 25)
	_add_sep(vbox)
	_add_label(vbox, "Смертей: %d. Хочешь пропустить?" % GameData.current_level_deaths,
		15, Color(0.70, 0.70, 0.70))

	var balance := GameData.get_balance()
	var is_free := balance < SKIP_COST

	var skip_text: String
	var skip_bg:   Color
	if is_free:
		skip_text = "Пропустить бесплатно"
		skip_bg   = Color(0.15, 0.45, 0.15)
	else:
		skip_text = "Пропустить — %d фруктов" % SKIP_COST
		skip_bg   = Color(0.50, 0.28, 0.05)

	var btn_skip := _action_btn(skip_text, skip_bg, skip_bg.lightened(0.15))
	var btn_cont := _action_btn("Играть дальше", Color(0.15, 0.15, 0.35), Color(0.25, 0.25, 0.50))
	vbox.add_child(btn_skip)
	_add_sep(vbox)
	vbox.add_child(btn_cont)

	btn_skip.pressed.connect(func():
		# Скрываем попап визуально — нода остаётся живой для await в _do_skip
		visible = false
		_do_skip(level_ref, is_free)
	)
	btn_cont.pressed.connect(func():
		get_tree().paused = false
		queue_free()
	)

# ── ТУТОРИАЛ О ПРОПУСКЕ (уровни 3–4, один раз навсегда) ──────────────────────

func show_skip_tutorial() -> void:
	get_tree().paused = true
	GameData.tutorial_skip_shown = true
	GameData.save_data()

	var vbox := _build_frame(-240.0, -145.0, 240.0, 145.0)
	_add_title(vbox, "Знаешь ли ты?", 26)
	_add_sep(vbox)
	_add_label(vbox,
		"Если уровень слишком сложный —\nсобери 50 🍎 и сможешь пропустить его!",
		20, Color(0.9, 0.9, 0.9))
	_add_sep(vbox)

	var btn := _action_btn("Понятно!", Color(0.15, 0.45, 0.15), Color(0.25, 0.60, 0.25))
	vbox.add_child(btn)

	btn.pressed.connect(func():
		get_tree().paused = false
		queue_free()
	)

# ── ПРОПУСК УРОВНЯ ────────────────────────────────────────────────────────────

func _do_skip(level_ref: Node, is_free: bool) -> void:
	# Списываем фрукты (если платный)
	if not is_free:
		GameData.spend_fruits(SKIP_COST)

	# Помечаем уровень пройденным
	var lvl_name: String = level_ref.scene_file_path.get_file().get_basename()
	var collected = level_ref.get("collected_count")
	GameData.submit_level_result(lvl_name, collected if collected != null else 0)

	# Победный звук
	var sfx := AudioStreamPlayer.new()
	sfx.stream = VICTORY_SOUND
	sfx.bus = &"SFX"
	sfx.volume_db = 6.0
	get_tree().root.add_child(sfx)
	sfx.play()

	# Конфетти
	var confetti = CONFETTI.instantiate()
	get_tree().root.add_child(confetti)

	get_tree().paused = false

	# Ждём конца конфетти, потом переходим
	var next: String = level_ref.get("next_level_path") if level_ref.get("next_level_path") != null else ""
	await confetti.play()
	confetti.queue_free()

	if next != "":
		SceneManager.go_to(next)
	else:
		SceneManager.go_to("res://Entities/Main/MainMenu.tscn")

# ── СТРОИТЕЛИ UI ──────────────────────────────────────────────────────────────

# Создаёт затемнение + панель, возвращает VBoxContainer внутри панели
func _build_frame(l: float, t: float, r: float, b: float) -> VBoxContainer:
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.70)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)

	var style := StyleBoxFlat.new()
	style.bg_color           = Color(0.12, 0.12, 0.18, 1.0)
	style.border_color       = Color(0.40, 0.40, 0.50, 1.0)
	style.border_width_left  = 3
	style.border_width_top   = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left     = 8
	style.corner_radius_top_right    = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left  = 8

	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left   = l
	panel.offset_top    = t
	panel.offset_right  = r
	panel.offset_bottom = b
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical   = Control.GROW_DIRECTION_BOTH
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left   =  16.0
	vbox.offset_top    =  12.0
	vbox.offset_right  = -16.0
	vbox.offset_bottom = -12.0
	vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	vbox.grow_vertical   = Control.GROW_DIRECTION_BOTH
	vbox.add_theme_constant_override("separation", 8)
	panel.add_child(vbox)

	return vbox

func _add_title(parent: Control, text: String, size: int = 28) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.add_theme_font_override("font", FONT)
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.2))
	parent.add_child(lbl)

func _add_label(parent: Control, text: String, size: int, color: Color) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = 3
	lbl.add_theme_font_override("font", FONT)
	lbl.add_theme_font_size_override("font_size", size)
	lbl.add_theme_color_override("font_color", color)
	parent.add_child(lbl)

func _add_sep(parent: Control) -> void:
	parent.add_child(HSeparator.new())

func _add_bonus_row(parent: Control, bonus_name: String, description: String) -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)

	var name_lbl := Label.new()
	name_lbl.text = bonus_name
	name_lbl.custom_minimum_size = Vector2(115, 0)
	name_lbl.add_theme_font_override("font", FONT)
	name_lbl.add_theme_font_size_override("font_size", 15)
	name_lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.25))

	var sep_lbl := Label.new()
	sep_lbl.text = "—"
	sep_lbl.add_theme_font_override("font", FONT)
	sep_lbl.add_theme_font_size_override("font_size", 15)
	sep_lbl.add_theme_color_override("font_color", Color(0.45, 0.45, 0.50))

	var desc_lbl := Label.new()
	desc_lbl.text = description
	desc_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	desc_lbl.add_theme_font_override("font", FONT)
	desc_lbl.add_theme_font_size_override("font_size", 13)
	desc_lbl.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))

	hbox.add_child(name_lbl)
	hbox.add_child(sep_lbl)
	hbox.add_child(desc_lbl)
	parent.add_child(hbox)

func _bonus_btn(text: String, enabled: bool) -> Button:
	var btn := _action_btn(text, Color(0.20, 0.20, 0.35), Color(0.30, 0.30, 0.50))
	if not enabled:
		btn.disabled = true
		btn.modulate = Color(0.5, 0.5, 0.5, 1.0)
	return btn

func _action_btn(text: String, bg: Color, bg_hover: Color) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(0, 36)
	btn.add_theme_font_override("font", FONT)
	btn.add_theme_font_size_override("font_size", 18)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.5))
	btn.add_theme_stylebox_override("normal",   _box(bg))
	btn.add_theme_stylebox_override("hover",    _box(bg_hover))
	btn.add_theme_stylebox_override("pressed",  _box(bg.darkened(0.15)))
	btn.add_theme_stylebox_override("focus",    _box(Color(0, 0, 0, 0), Color(0, 0, 0, 0)))
	btn.add_theme_stylebox_override("disabled", _box(Color(0.15, 0.15, 0.20), Color(0.28, 0.28, 0.35)))
	return btn

func _box(bg: Color, border: Color = Color(0.40, 0.40, 0.55)) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color            = bg
	s.border_color        = border
	s.border_width_left   = 2
	s.border_width_top    = 2
	s.border_width_right  = 2
	s.border_width_bottom = 2
	s.corner_radius_top_left     = 6
	s.corner_radius_top_right    = 6
	s.corner_radius_bottom_right = 6
	s.corner_radius_bottom_left  = 6
	return s
