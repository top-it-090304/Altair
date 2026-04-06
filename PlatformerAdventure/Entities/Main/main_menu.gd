extends Control

const GRAVITY: float = 900.0
const SCREEN_LEFT: float = 0.0
const SCREEN_RIGHT: float = 1280.0
const CLOUD_SPEED: float = 40.0

var _chars: Array = []
var _cloud_rects: Array = []
var _cloud_w: float

func _on_btn_settings_pressed() -> void:
	SceneManager.go_to("res://Entities/Settings/setting.tscn")

func _ready() -> void:
	MusicManager.play_music(preload("res://Assets/audio/For_Levels/MainMenu.mp3"))
	get_tree().get_root().size_changed.connect(_on_viewport_resize)
	_on_viewport_resize()
	_init_chars()
	call_deferred("_init_clouds")

func _init_clouds() -> void:
	var c1: TextureRect = $TextureRect
	var c2: TextureRect = $TextureRect2
	_cloud_w = c1.size.x
	# выравниваем c2 под c1 (одинаковый размер и Y)
	c2.size = c1.size
	c2.position.y = c1.position.y
	# создаём третий спрайт — дубликат c1
	var c3: TextureRect = c1.duplicate()
	add_child(c3)
	move_child(c3, c2.get_index() + 1)  # сразу за c2, перед остальным UI
	# расставляем три спрайта вплотную
	c1.position.x = 0.0
	c2.position.x = _cloud_w
	c3.position.x = _cloud_w * 2.0
	_cloud_rects = [c1, c2, c3]

func _init_chars() -> void:
	var configs = [
		{ "node": $Node2D/mask_dude, "speed": 210.0, "jump_interval": 3.2, "jump_power": -380.0, "left_bound": 230.0, "right_bound": 1080.0 },
		{ "node": $Node2D/pepe,      "speed": 215.0, "jump_interval": 1.6, "jump_power": -450.0, "left_bound": 230.0, "right_bound": 1080.0 },
		{ "node": $Node2D/pink,      "speed": 190.0, "jump_interval": 4.5, "jump_power": -300.0, "left_bound": 230.0, "right_bound": 1080.0 },
		{ "node": $Node2D/vr_guy,    "speed": 250.0, "jump_interval": 4.0, "jump_power": -365.0, "left_bound": 230.0, "right_bound": 1080.0 },
	]
	for cfg in configs:
		var sprite: AnimatedSprite2D = cfg.node
		var dir := 1.0 if randf() > 0.5 else -1.0
		_chars.append({
			"sprite":        sprite,
			"speed":         cfg.speed,
			"dir":           dir,
			"left_bound":    cfg.left_bound,
			"right_bound":   cfg.right_bound,
			"ground_y":      sprite.position.y,
			"vel_y":         0.0,
			"airborne":      false,
			"jump_timer":    randf_range(0.3, cfg.jump_interval),
			"jump_interval": cfg.jump_interval,
			"jump_power":    cfg.jump_power,
		})
		sprite.flip_h = dir < 0.0
		sprite.play("run")

func _scroll_clouds(delta: float) -> void:
	if _cloud_rects.is_empty():
		return
	for cloud in _cloud_rects:
		cloud.position.x -= CLOUD_SPEED * delta
	# находим самый правый спрайт
	var rightmost: TextureRect = _cloud_rects[0]
	for cloud in _cloud_rects:
		if cloud.position.x > rightmost.position.x:
			rightmost = cloud
	# перекидываем вышедший за левый край вправо за самый правый
	for cloud in _cloud_rects:
		if cloud.position.x + _cloud_w < 0.0:
			cloud.position.x = rightmost.position.x + _cloud_w
			break

func _process(delta: float) -> void:
	_scroll_clouds(delta)
	for c in _chars:
		var sprite: AnimatedSprite2D = c.sprite

		# горизонтальное движение
		sprite.position.x += c.speed * c.dir * delta

		# разворот у края
		if sprite.position.x > c.right_bound:
			c.dir = -1.0
			sprite.flip_h = true
		elif sprite.position.x < c.left_bound:
			c.dir = 1.0
			sprite.flip_h = false

		# таймер прыжка (только на зе��ле)
		if not c.airborne:
			c.jump_timer -= delta
			if c.jump_timer <= 0.0:
				c.airborne = true
				c.vel_y = c.jump_power
				c.jump_timer = c.jump_interval + randf_range(-0.3, 0.3)
				sprite.play("jump")

		# гравитация
		if c.airborne:
			c.vel_y += GRAVITY * delta
			sprite.position.y += c.vel_y * delta
			# переключаем на fall когда летим вниз
			if c.vel_y > 0.0 and sprite.animation != &"fall":
				sprite.play("fall")
			if sprite.position.y >= c.ground_y:
				sprite.position.y = c.ground_y
				c.vel_y = 0.0
				c.airborne = false
				sprite.play("run")

func _on_viewport_resize() -> void:
	size = get_viewport().get_visible_rect().size
	position = Vector2.ZERO

func _on_texture_button_pressed() -> void:
	SceneManager.go_to("res://Entities/Main/Levels_Menu.tscn")

func _on_texture_button_2_pressed() -> void:
	SceneManager.go_to("res://Entities/Shop/shop.tscn")

func _on_texture_button_3_pressed() -> void:
	get_tree().quit()
