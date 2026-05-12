extends Control

@onready var video: VideoStreamPlayer = $VideoStreamPlayer

var _transition_layer: Node = null

func _ready() -> void:
	video.stream = load("res://Assets/Video/ALTAIR WHITEE.ogv")
	print("[IntroScreen] stream loaded: ", video.stream)
	video.expand = true
	video.play()
	print("[IntroScreen] is_playing: ", video.is_playing())
	video.finished.connect(_go_to_menu)

	await get_tree().process_frame
	_transition_layer = get_tree().root.get_node_or_null("TransitionLayer")
	if _transition_layer:
		_transition_layer.hide()
		print("[IntroScreen] TransitionLayer hidden")
	else:
		print("[IntroScreen] TransitionLayer not found")

func _go_to_menu() -> void:
	if _transition_layer:
		_transition_layer.show()
	get_tree().change_scene_to_file("res://Entities/Main/MainMenu.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_go_to_menu()
