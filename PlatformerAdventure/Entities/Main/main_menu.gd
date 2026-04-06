extends Control

const GRAVITY: float = 900.0
const SCREEN_LEFT: float = 0.0
const SCREEN_RIGHT: float = 1280.0

var _chars: Array = []

func _on_btn_settings_pressed() -> void:
	SceneManager.go_to("res://Entities/Settings/setting.tscn")

func _ready() -> void:
	MusicManager.play_music(preload("res://Assets/audio/For_Levels/MainMenu.mp3"))
	get_tree().get_root().size_changed.connect(_on_viewport_resize)
	_on_viewport_resize()
	_init_chars()

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

func _process(delta: float) -> void:
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
