extends Node2D

@onready var spawn_marker = $SpawnPoint
@onready var player = $Player

func _ready() -> void:
	if player and spawn_marker:
		player.global_position = spawn_marker.global_position
