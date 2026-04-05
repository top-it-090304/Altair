extends Node2D

signal stomped

# ──────────────────────────────────────────────
#  ЭКСПОРТИРУЕМЫЕ ПАРАМЕТРЫ
# ──────────────────────────────────────────────
@export var shoot_interval: float = 2.0          # интервал стрельбы — редактируется в инспекторе
@export var bullet_scene: PackedScene            # перетащить Bullet.tscn в инспекторе
@export var shoot_direction: Vector2 = Vector2(-1, 0)  # направление пули

# ──────────────────────────────────────────────
#  ССЫЛКИ НА ДОЧЕРНИЕ УЗЛЫ
# ──────────────────────────────────────────────
@onready var anim: AnimatedSprite2D       = $AnimatedSprite2D
@onready var shoot_timer: Timer           = $ShootTimer
@onready var spawn_point: Marker2D        = $BulletSpawnPoint
@onready var body_col: CollisionShape2D   = $StaticBody2D/CollisionShape2D
@onready var stomp_area: Area2D           = $StompArea

# ──────────────────────────────────────────────
#  СОСТОЯНИЕ
# ──────────────────────────────────────────────
var _is_attacking: bool = false
var _is_dead: bool = false

# ──────────────────────────────────────────────
#  ИНИЦИАЛИЗАЦИЯ
# ──────────────────────────────────────────────
func _ready() -> void:
	add_to_group("enemies")
	# StaticBody2D нужен в той же группе, чтобы пули врага не уничтожались о своё же тело
	$StaticBody2D.add_to_group("enemies")
	anim.play("idle")

	anim.animation_finished.connect(_on_attack_complete)
	anim.animation_looped.connect(_on_attack_complete)

	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	shoot_timer.start(shoot_interval)

	stomp_area.body_entered.connect(_on_stomp_area_body_entered)

# ──────────────────────────────────────────────
#  ТАЙМЕР ВЫСТРЕЛА
# ──────────────────────────────────────────────
func _on_shoot_timer_timeout() -> void:
	if _is_attacking or _is_dead:
		return

	_is_attacking = true
	anim.play("attack")

# ──────────────────────────────────────────────
#  КОНЕЦ АНИМАЦИИ АТАКИ
# ──────────────────────────────────────────────
func _on_attack_complete() -> void:
	if not _is_attacking or anim.animation != "attack":
		return

	_spawn_bullet()
	_is_attacking = false
	anim.play("idle")

# ──────────────────────────────────────────────
#  СПАВН ПУЛИ
# ──────────────────────────────────────────────
func _spawn_bullet() -> void:
	if bullet_scene == null:
		push_error("Plant: bullet_scene не назначен в инспекторе!")
		return

	var bullet: Node = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = spawn_point.global_position
	bullet.direction = Vector2(shoot_direction.x * sign(scale.x), shoot_direction.y)

# ──────────────────────────────────────────────
#  ОБНАРУЖЕНИЕ СТОМПА
# ──────────────────────────────────────────────
func _on_stomp_area_body_entered(body: Node2D) -> void:
	if _is_dead:
		return
	if not body.is_in_group("player"):
		return
	if not body.has_method("stomp_bounce"):
		return
	# body_entered срабатывает ПОСЛЕ move_and_slide, поэтому velocity.y уже обнулён.
	# Читаем velocity_before_slide — скорость, сохранённую до физического шага.
	if body.velocity_before_slide.y <= 0.0:
		return

	_die(body)

# ──────────────────────────────────────────────
#  СМЕРТЬ ОТ СТОМПА
# ──────────────────────────────────────────────
func _die(stomper: Node2D) -> void:
	_is_dead = true
	shoot_timer.stop()
	_is_attacking = false

	# Отключаем коллизии
	body_col.set_deferred("disabled", true)
	stomp_area.set_deferred("monitoring", false)

	anim.play("hit")

	# Отправляем игрока вверх
	stomper.stomp_bounce()

	# Сигнал для внешних подписчиков
	stomped.emit()

	await get_tree().create_timer(0.5).timeout
	queue_free()
