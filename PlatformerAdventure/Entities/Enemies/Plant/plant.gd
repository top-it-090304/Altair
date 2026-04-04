extends Node2D

# ──────────────────────────────────────────────
#  ЭКСПОРТИРУЕМЫЕ ПАРАМЕТРЫ
# ──────────────────────────────────────────────
@export var shoot_interval: float = 2.0          # интервал стрельбы — редактируется в инспекторе
@export var bullet_scene: PackedScene            # перетащить Bullet.tscn в инспекторе
@export var shoot_direction: Vector2 = Vector2(-1, 0)  # направление пули

# ──────────────────────────────────────────────
#  ССЫЛКИ НА ДОЧЕРНИЕ УЗЛЫ
# ──────────────────────────────────────────────
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var shoot_timer: Timer     = $ShootTimer
@onready var spawn_point: Marker2D  = $BulletSpawnPoint

# ──────────────────────────────────────────────
#  СОСТОЯНИЕ
# ──────────────────────────────────────────────
var _is_attacking: bool = false

# ──────────────────────────────────────────────
#  ИНИЦИАЛИЗАЦИЯ
# ──────────────────────────────────────────────
func _ready() -> void:
	anim.play("idle")

	# Подключаем оба сигнала к одному обработчику:
	# animation_finished — для незацикленной анимации
	# animation_looped   — для зацикленной (тогда finished никогда не придёт)
	anim.animation_finished.connect(_on_attack_complete)
	anim.animation_looped.connect(_on_attack_complete)

	shoot_timer.timeout.connect(_on_shoot_timer_timeout)

	# Явный старт с интервалом из @export
	shoot_timer.start(shoot_interval)

# ──────────────────────────────────────────────
#  ТАЙМЕР ВЫСТРЕЛА
# ──────────────────────────────────────────────
func _on_shoot_timer_timeout() -> void:
	# Пропускаем тик, если предыдущая атака ещё не завершена
	if _is_attacking:
		return

	_is_attacking = true
	anim.play("attack")

# ──────────────────────────────────────────────
#  КОНЕЦ АНИМАЦИИ АТАКИ
# ──────────────────────────────────────────────
func _on_attack_complete() -> void:
	# Срабатывает и для looping (animation_looped), и для non-looping (animation_finished).
	# Игнорируем всё, что не атака, и повторные вызовы.
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

	# Добавляем в текущую сцену, а не в Plant —
	# пуля живёт независимо и не удалится вместе с растением
	get_tree().current_scene.add_child(bullet)

	# Позицию и направление выставляем ПОСЛЕ add_child (после _ready пули).
	# Умножаем x на sign(scale.x): если цветок отражён по X (scale.x = -1),
	# пуля полетит в зеркальном направлении.
	bullet.global_position = spawn_point.global_position
	bullet.direction = Vector2(shoot_direction.x * sign(scale.x), shoot_direction.y)
