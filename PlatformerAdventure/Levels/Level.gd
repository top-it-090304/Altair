extends Node2D

# Игровые объекты
@onready var spawn_marker = $Entities/SpawnPoint
@onready var player = $Entities/Player
@onready var flag = $Entities/Flag

@export_file("*.tscn") var next_level_path: String

@export var manual_fruit_count: int = 0

var total_fruits = 0
var collected_count = 0

@onready var fruit_counter = preload("res://Entities/Level/Buttons/сounter.tscn").instantiate()
func _ready() -> void:

	if player and spawn_marker:
		player.global_position = spawn_marker.global_position

  
	add_child(fruit_counter)
	fruit_counter.update_count(0)  

	var fruits = get_tree().get_nodes_in_group("fruits")
	if manual_fruit_count > 0:
		total_fruits = manual_fruit_count
	else:
		total_fruits = fruits.size()

	print("Всего фруктов на уровне: ", total_fruits)

 
	for fruit in fruits:
		fruit.collected.connect(_on_fruit_collected)

	if flag:
		flag.level_completed.connect(_on_level_completed)

func _on_fruit_collected():
	collected_count += 1

	fruit_counter.update_count(collected_count)

	#if collected_count >= total_fruits:
		#if flag:
			#flag.activate()

func _on_level_completed():
 
	get_tree().call_deferred("change_scene_to_file", next_level_path)

func _on_button_pressed() -> void:
   
	get_tree().reload_current_scene()
