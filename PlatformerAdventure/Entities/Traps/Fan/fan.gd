extends Node2D

@export_group("Lift")
@export var lift_force: float = 2800.0
@export var max_lift_speed: float = 200.0
@export var air_height: float = 60.0  

@export_group("On/Off Cycle")
@export var starts_on: bool = true
@export var time_on: float = 3.0
@export var time_off: float = 2.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var lift_area: Area2D = $LiftArea
@onready var collision_shape: CollisionShape2D = $LiftArea/CollisionShape2D

var is_on: bool = false
var cycle_timer: float = 0.0
var players_in_zone: Array[Node2D] = []

func _ready() -> void:
	lift_area.body_entered.connect(_on_body_entered)
	lift_area.body_exited.connect(_on_body_exited)

	
	_update_air_height()

	is_on = starts_on
	cycle_timer = time_on if starts_on else time_off
	_apply_state()

func _update_air_height() -> void:
	var shape := collision_shape.shape as RectangleShape2D
	shape.size.y = air_height
	
	collision_shape.position.y = -(air_height / 2.0)

func _physics_process(delta: float) -> void:
	cycle_timer -= delta
	if cycle_timer <= 0.0:
		is_on = !is_on
		cycle_timer = time_on if is_on else time_off
		_apply_state()

	if not is_on:
		return

	for player in players_in_zone:
		if is_instance_valid(player) and not player.is_dead:
			player.velocity.y -= lift_force * delta
			player.velocity.y = max(player.velocity.y, -max_lift_speed)

func _apply_state() -> void:
	if is_on:
		animated_sprite.play("on")
		lift_area.monitoring = true
	else:
		animated_sprite.play("off")
		lift_area.monitoring = false
		players_in_zone.clear()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body not in players_in_zone:
		players_in_zone.append(body)

func _on_body_exited(body: Node2D) -> void:
	players_in_zone.erase(body)
