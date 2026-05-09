# Credits.gd
# res://Entities/Main/Credits.gd

extends Control

const FONT_PATH    := "res://Assets/Fonts/EpilepsySansBold.ttf"
const MENU_PATH    := "res://Entities/Main/MainMenu.tscn"
const SCROLL_SPEED := 80.0

var _font: Font
var _bg: ColorRect      # всегда жив — даёт чёрный фон на всех фазах
var _overlay: ColorRect # слой для плавных затемнений
var _tween: Tween
var _gen := 0           # инкремент отменяет все запущенные корутины

enum _Phase { INTRO, CREDITS, FINAL, DONE }
var _phase := _Phase.INTRO


func _ready() -> void:
	_font = load(FONT_PATH)
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	_bg = ColorRect.new()
	_bg.color = Color.BLACK
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)

	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 1)  # стартуем с чёрного — fade-in делаем сами
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.z_index = 100
	add_child(_overlay)

	# Удаляем overlay затемнения, оставшийся от Level.gd после смены сцены
	for node in get_tree().get_nodes_in_group("credits_fade_overlay"):
		node.queue_free()

	# Останавливаем музыку уровня
	MusicManager.stop_music()

	_run_intro()


# ── INPUT ─────────────────────────────────────────────────────────────────────

func _input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	get_viewport().set_input_as_handled()
	match _phase:
		_Phase.INTRO, _Phase.CREDITS:
			_skip_to_final()
		_Phase.FINAL:
			_phase = _Phase.DONE
			get_tree().change_scene_to_file(MENU_PATH)

func _skip_to_final() -> void:
	_gen += 1
	_phase = _Phase.FINAL
	if _tween:
		_tween.kill()
	_clear_content()
	_overlay.color = Color(0, 0, 0, 1)
	await get_tree().process_frame
	if not is_inside_tree():
		return
	_show_final_content()

# Удаляет всё кроме _bg и _overlay
func _clear_content() -> void:
	for child in get_children():
		if child != _overlay and child != _bg:
			child.queue_free()


# ── ИНТРО ──────────────────────────────────────────────────────────────────────

func _run_intro() -> void:
	var my_gen := _gen
	var vp     := get_viewport_rect().size

	var title := _make_label("ТЫ ПРОШЁЛ ИГРУ", 72, Color("#ffd700"))
	title.size     = Vector2(vp.x, 90)
	# Начинаем чуть ниже финальной позиции — очень лёгкий дрейф снизу
	title.position = Vector2(0.0, vp.y / 2.0 - 45.0 + 22.0)
	title.modulate.a = 0.0
	add_child(title)

	var sub := _make_label("все 24 уровня позади", 36, Color("#777777"))
	sub.size     = Vector2(vp.x, 50)
	sub.position = Vector2(0.0, vp.y / 2.0 + 55.0 + 22.0)
	sub.modulate.a = 0.0
	add_child(sub)

	# Пауза в темноте — нагнетание
	await get_tree().create_timer(1.0).timeout
	if _gen != my_gen or not is_inside_tree():
		return

	# Текст появляется «из темноты» — overlay медленно уходит вместе с текстом
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(_overlay, "color:a", 0.0, 2.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(title, "modulate:a", 1.0, 2.2)
	_tween.tween_property(title, "position:y", vp.y / 2.0 - 45.0, 2.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(sub, "modulate:a", 1.0, 1.8).set_delay(1.0)
	_tween.tween_property(sub, "position:y", vp.y / 2.0 + 55.0, 1.8).set_delay(1.0).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Держим на экране
	await get_tree().create_timer(2.0).timeout
	if _gen != my_gen or not is_inside_tree():
		return

	# Уход в чёрный перед титрами
	_tween = create_tween()
	_tween.tween_property(_overlay, "color:a", 1.0, 1.2)
	await _tween.finished
	if _gen != my_gen or not is_inside_tree():
		return

	title.queue_free()
	sub.queue_free()
	_phase = _Phase.CREDITS
	_run_credits()


# ── ТИТРЫ ─────────────────────────────────────────────────────────────────────

func _run_credits() -> void:
	var my_gen := _gen
	var vp     := get_viewport_rect().size

	var clip := Control.new()
	clip.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	clip.clip_contents = true
	add_child(clip)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 16)
	content.custom_minimum_size = Vector2(vp.x, 0)
	clip.add_child(content)

	_build_credits(content, vp.x)

	# Кнопка «Пропустить» — поверх overlay, ведёт сразу в главное меню
	var skip_btn := _make_skip_button()
	skip_btn.pressed.connect(func() -> void:
		_gen += 1
		_phase = _Phase.DONE
		if _tween:
			_tween.kill()
		get_tree().change_scene_to_file(MENU_PATH)
	)
	add_child(skip_btn)

	# Ждём пока layout посчитает размеры
	for _i in 4:
		await get_tree().process_frame
	if _gen != my_gen or not is_inside_tree():
		return

	var content_h := content.size.y
	if content_h < 10.0:
		content_h = content.get_combined_minimum_size().y

	content.position = Vector2(0.0, vp.y)

	# Плавно убираем затемнение
	_tween = create_tween()
	_tween.tween_property(_overlay, "color:a", 0.0, 0.8)

	# Прокрутка с постоянной скоростью
	var scroll_dur := (content_h + vp.y) / SCROLL_SPEED
	var scroll_tw  := create_tween()
	scroll_tw.tween_property(content, "position:y", -content_h, scroll_dur) \
			.set_trans(Tween.TRANS_LINEAR)
	_tween = scroll_tw

	await scroll_tw.finished
	if _gen != my_gen or not is_inside_tree():
		return

	skip_btn.queue_free()
	_run_final()


func _build_credits(c: VBoxContainer, width: float) -> void:
	_spacer(c, 200)

	# ── Вступление ───────────────────────────────────────────────
	for line: String in [
		"Эта игра началась как учебное задание.",
		"Но где-то между февралём и маем 2026 года",
		"она стала чем-то большим.",
		"",
		"Мы не просто писали код.",
		"Мы придумывали миры, рисовали текстуры,",
		"спорили, переделывали, не спали.",
		"",
		"И вот ты дошёл до конца.",
		"Это значит — мы сделали что-то настоящее.",
	]:
		if line.is_empty():
			_spacer(c, 18)
		else:
			c.add_child(_make_label(line, 28, Color("#999999")))

	_spacer(c, 50)
	_sep(c, width)
	_spacer(c, 50)

	# ── РАЗРАБОТКА ───────────────────────────────────────────────
	c.add_child(_make_label("РАЗРАБОТКА", 42, Color("#ffd700")))
	_spacer(c, 24)
	c.add_child(_make_label("Vladislav Ellert", 34, Color("#ffffff")))
	c.add_child(_make_label("Геймдизайн · Программирование · Графика", 22, Color("#555555")))
	_spacer(c, 20)
	c.add_child(_make_label("Andrey Kolokhmatov", 34, Color("#ffffff")))
	c.add_child(_make_label("Геймдизайн · Программирование · Графика", 22, Color("#555555")))

	_spacer(c, 50)
	_sep(c, width)
	_spacer(c, 50)

	# ── ГРАФИКА ──────────────────────────────────────────────────
	c.add_child(_make_label("ГРАФИКА", 42, Color("#ffd700")))
	_spacer(c, 24)
	for nm: String in ["PixelFrog", "Andrey Kolokhmatov", "Vladislav Ellert"]:
		c.add_child(_make_label(nm, 34, Color("#ffffff")))

	_spacer(c, 50)
	_sep(c, width)
	_spacer(c, 50)

	# ── МУЗЫКА ───────────────────────────────────────────────────
	c.add_child(_make_label("МУЗЫКА", 42, Color("#ffd700")))
	_spacer(c, 24)
	c.add_child(_make_label("ZvukiPro", 34, Color("#ffffff")))

	_spacer(c, 50)
	_sep(c, width)
	_spacer(c, 50)

	# ── Подпись ──────────────────────────────────────────────────
	c.add_child(_make_label("Версия 1.0.0 · 2026", 22, Color("#555555")))
	_spacer(c, 16)
	c.add_child(_make_label("команда", 20, Color("#555555")))
	_spacer(c, 16)
	c.add_child(_make_label("— ALTAIR —", 60, Color("#ffd700")))

	# Минимальный отступ — чтобы последняя строка успела уйти за верхний край
	_spacer(c, 60)


# ── ФИНАЛЬНЫЙ ЭКРАН ───────────────────────────────────────────────────────────

func _run_final() -> void:
	var my_gen := _gen

	# Быстро гасим экран
	_tween = create_tween()
	_tween.tween_property(_overlay, "color:a", 1.0, 0.6)
	await _tween.finished
	if _gen != my_gen or not is_inside_tree():
		return

	_clear_content()
	_phase = _Phase.FINAL
	_show_final_content()


func _show_final_content() -> void:
	var my_gen := _gen
	var vp     := get_viewport_rect().size

	var final_ctrl := Control.new()
	final_ctrl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(final_ctrl)

	var thank := _make_label("СПАСИБО, ЧТО ИГРАЛ", 64, Color("#ffd700"))
	thank.size     = Vector2(vp.x, 90)
	thank.position = Vector2(0.0, vp.y / 2.0 - 110.0)
	thank.modulate.a = 0.0
	final_ctrl.add_child(thank)

	var altair_lbl := _make_label("— ALTAIR —", 42, Color("#ffd700"))
	altair_lbl.size     = Vector2(vp.x, 60)
	altair_lbl.position = Vector2(0.0, vp.y / 2.0 + 10.0)
	altair_lbl.modulate.a = 0.0
	final_ctrl.add_child(altair_lbl)

	var year := _make_label("2026", 22, Color("#444444"))
	year.size     = Vector2(vp.x, 36)
	year.position = Vector2(0.0, vp.y / 2.0 + 90.0)
	year.modulate.a = 0.0
	final_ctrl.add_child(year)

	_tween = create_tween().set_parallel(true)
	_tween.tween_property(_overlay,   "color:a",    0.0, 1.5)
	_tween.tween_property(thank,      "modulate:a", 1.0, 1.5).set_delay(0.3)
	_tween.tween_property(altair_lbl, "modulate:a", 1.0, 1.5).set_delay(0.6)
	_tween.tween_property(year,       "modulate:a", 1.0, 1.5).set_delay(0.9)

	await get_tree().create_timer(5.0).timeout
	if _gen != my_gen or not is_inside_tree():
		return

	_phase = _Phase.DONE
	get_tree().change_scene_to_file(MENU_PATH)


# ── ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ ───────────────────────────────────────────────────

func _make_label(text: String, font_size: int, color: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", _font)
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l

func _make_skip_button() -> Button:
	var btn := Button.new()
	btn.text = "Пропустить"
	btn.add_theme_font_override("font", _font)
	btn.add_theme_font_size_override("font_size", 20)
	btn.add_theme_color_override("font_color", Color("#777777"))
	btn.add_theme_color_override("font_hover_color", Color("#ffffff"))
	btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	btn.offset_left   = -180.0
	btn.offset_top    = -52.0
	btn.offset_right  = -20.0
	btn.offset_bottom = -20.0
	btn.z_index       = 150
	return btn

func _spacer(c: Control, h: int) -> void:
	var s := Control.new()
	s.custom_minimum_size = Vector2(0, h)
	c.add_child(s)

func _sep(c: Control, width: float) -> void:
	var line := ColorRect.new()
	line.color = Color("#333333")
	line.custom_minimum_size = Vector2(width * 0.5, 2)
	line.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	c.add_child(line)
