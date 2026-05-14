extends Control

@onready var video: VideoStreamPlayer = $VideoStreamPlayer

func _ready() -> void:
	video.stream = load("res://Assets/Video/ALTAIR-WHITEE_2.ogv")
	video.expand = true
	video.audio_track = 0
	video.bus = "Music"
	print("[IntroScreen] stream: ", video.stream)
	var timer = get_tree().create_timer(0.3)
	await timer.timeout
	var transition = get_tree().root.get_node_or_null("TransitionLayer")
	if transition:
		transition.hide()
	video.play()
	print("[IntroScreen] is_playing after timer: ", video.is_playing())
	video.finished.connect(_go_to_menu)

func _go_to_menu() -> void:
	# Show transition again before leaving so other scenes work normally
	var transition = get_tree().root.get_node_or_null("TransitionLayer")
	if transition:
		transition.show()
	get_tree().change_scene_to_file("res://Entities/Main/MainMenu.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_go_to_menu()
