extends Node

var previous_scene: String = ""
var _diamond: Sprite2D = null
var _cover_scale: float = 1.0

const TEXTURE_HALF_SIZE: float = 22.0   # half of 44px diamond tip-to-tip
const DURATION_COVER:  float = 0.45
const DURATION_REVEAL: float = 0.5

func _ready() -> void:
	var transition = preload("res://Entities/Level/UI/transition_layer.tscn").instantiate()
	get_tree().root.call_deferred("add_child", transition)
	await get_tree().process_frame
	_diamond = transition.get_node("Diamond")
	_setup_diamond()
	_diamond.scale = Vector2.ONE * _cover_scale
	_reveal()

# Centre the diamond on screen and compute the scale that fully covers every corner.
# Diamond (rotated square) covers point (x,y) from centre when |x|+|y| <= half_size * scale.
# Worst case corner: half_w + half_h.
func _setup_diamond() -> void:
	var vp_size: Vector2 = get_viewport().get_visible_rect().size
	_diamond.position      = vp_size * 0.5
	_diamond.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_cover_scale = (vp_size.x * 0.5 + vp_size.y * 0.5) / TEXTURE_HALF_SIZE + 2.0

func go_to(scene_path: String) -> void:
	previous_scene = get_tree().current_scene.scene_file_path
	_cover_then_go(scene_path)

func go_back(fallback: String = "res://Entities/Main/MainMenu.tscn") -> void:
	var target := previous_scene if previous_scene != "" else fallback
	previous_scene = ""
	_fade_out_then_go(target)

# Diamond grows from 0 → full cover in integer scale steps, then switches scene.
func _cover_then_go(scene_path: String) -> void:
	var tween := get_tree().create_tween()
	tween.tween_method(_set_scale_snapped, 0.0, _cover_scale, DURATION_COVER)
	tween.tween_callback(func() -> void:
		var err := get_tree().change_scene_to_file(scene_path)
		if err != OK:
			push_error("[SceneManager] change_scene_to_file failed: %d  path: %s" % [err, scene_path])
			_reveal()
			return
		get_tree().root.child_entered_tree.connect(_on_new_scene_ready, CONNECT_ONE_SHOT)
	)

# Diamond shrinks from full cover → 0 in integer scale steps, revealing new scene.
func _reveal() -> void:
	var tween := get_tree().create_tween()
	tween.tween_method(_set_scale_snapped, _cover_scale, 0.0, DURATION_REVEAL)

# Snap scale to nearest integer so each step shows a full pixel block.
func _set_scale_snapped(s: float) -> void:
	_diamond.scale = Vector2.ONE * round(s)

func _on_new_scene_ready(_node: Node) -> void:
	_reveal()
