extends Area2D

# ──────────────────────────────────────────────
#  ЭКСПОРТИРУЕМЫЕ ПАРАМЕТРЫ
# ──────────────────────────────────────────────
@export var speed: float     = 300.0
@export var direction: Vector2 = Vector2(-1, 0)   # задаётся Plant при спавне

# ──────────────────────────────────────────────
#  ССЫЛКИ НА ДОЧЕРНИЕ УЗЛЫ
# ──────────────────────────────────────────────
@onready var anim: AnimatedSprite2D     = $AnimatedSprite2D
@onready var col: CollisionShape2D      = $CollisionShape2D

# ──────────────────────────────────────────────
#  СОСТОЯНИЕ
# ──────────────────────────────────────────────
var _hit: bool          = false   # пуля уже попала в цель
var _lifetime: float    = 0.0    # счётчик времени жизни (без Timer-узла)
const MAX_LIFETIME: float = 5.0  # авто-удаление через 5 секунд

# ──────────────────────────────────────────────
#  ИНИЦИАЛИЗАЦИЯ
# ──────────────────────────────────────────────
func _ready() -> void:
	anim.play("bullet")
	body_entered.connect(_on_body_entered)
	anim.animation_finished.connect(_on_animation_finished)

# ──────────────────────────────────────────────
#  ДВИЖЕНИЕ И АВТО-УДАЛЕНИЕ
# ──────────────────────────────────────────────
func _physics_process(delta: float) -> void:
	if _hit:
		return

	# Движение в заданном направлении
	position += direction * speed * delta

	# Авто-уничтожение, если пуля никуда не попала
	_lifetime += delta
	if _lifetime >= MAX_LIFETIME:
		queue_free()

# ──────────────────────────────────────────────
#  ПОПАДАНИЕ В ТЕЛО
# ──────────────────────────────────────────────
func _on_body_entered(body: Node2D) -> void:
	if _hit:
		return
	_hit = true

	# Наносим урон игроку
	if body.is_in_group("player"):
		body.hit()

	# Отключаем коллизию сразу, чтобы не было повторных срабатываний
	col.set_deferred("disabled", true)

	# Проигрываем анимацию попадания; queue_free — в _on_animation_finished
	anim.play("hit")

# ──────────────────────────────────────────────
#  КОНЕЦ АНИМАЦИИ
# ──────────────────────────────────────────────
func _on_animation_finished() -> void:
	if anim.animation == "hit":
		queue_free()
