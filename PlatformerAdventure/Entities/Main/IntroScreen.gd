extends Control

@onready var video: VideoStreamPlayer = $VideoStreamPlayer

func _ready() -> void:
	video.stream = load("res://Assets/Video/ALTAIR WHITEE.ogv")
	video.expand = true
	# Wait one frame for the node to be fully ready
	await get_tree().process_frame
	await get_tree().process_frame
	video.play()
	await get_tree().process_frame
	print("[IntroScreen] is_playing after wait: ", video.is_playing())
	video.finished.connect(_go_to_menu)

func _go_to_menu() -> void:
	get_tree().change_scene_to_file("res://Entities/Main/MainMenu.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		_go_to_menu()
