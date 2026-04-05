extends Node

var previous_scene: String = ""
var _overlay: ColorRect = null

func _ready() -> void:
	var transition = preload("res://Entities/Level/UI/transition_layer.tscn").instantiate()
	get_tree().root.call_deferred("add_child", transition)
	await get_tree().process_frame
	_overlay = transition.get_node("Overlay")
	_overlay.modulate.a = 1.0
	_fade_in()

func go_to(scene_path: String) -> void:
	previous_scene = get_tree().current_scene.scene_file_path
	_fade_out_then_go(scene_path)

func go_back(fallback: String = "res://Entities/Main/MainMenu.tscn") -> void:
	var target = previous_scene if previous_scene != "" else fallback
	previous_scene = ""
	go_to(target)

func _fade_in() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(_overlay, "modulate:a", 0.0, 0.3)

func _fade_out_then_go(scene_path: String) -> void:
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	var tween = get_tree().create_tween()
	tween.tween_property(_overlay, "modulate:a", 1.0, 0.3)
	tween.tween_callback(func():
		get_tree().change_scene_to_file(scene_path)
		await get_tree().process_frame
		_fade_in()
		_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	)
