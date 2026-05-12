extends Control

const LEVEL_PATHS: Array = [
	"res://Levels/VirtualGuy_17-24Levels/Level17.tscn",
	"res://Levels/VirtualGuy_17-24Levels/Level18.tscn",
	"res://Levels/VirtualGuy_17-24Levels/Level19.tscn",
	"res://Levels/VirtualGuy_17-24Levels/Level20.tscn",
	"res://Levels/VirtualGuy_17-24Levels/Level21.tscn",
	"res://Levels/VirtualGuy_17-24Levels/Level22.tscn",
	"res://Levels/VirtualGuy_17-24Levels/Level23.tscn",
	"res://Levels/VirtualGuy_17-24Levels/Level24.tscn",
]

const LEVEL_NAMES: Array = [
	"Level17", "Level18", "Level19", "Level20",
	"Level21", "Level22", "Level23", "Level24"
]

const GREEN_TEXTURES: Array = [
	"res://Assets/Textures/Menu/Levels/17green.png",
	"res://Assets/Textures/Menu/Levels/18green.png",
	"res://Assets/Textures/Menu/Levels/19green.png",
	"res://Assets/Textures/Menu/Levels/20green.png",
	"res://Assets/Textures/Menu/Levels/21green.png",
	"res://Assets/Textures/Menu/Levels/22green.png",
	"res://Assets/Textures/Menu/Levels/23green.png",
	"res://Assets/Textures/Menu/Levels/24green.png",
]

const GREEN_HOVER_TEXTURES: Array = [
	"res://Assets/Textures/Menu/Levels/17green_light.png",
	"res://Assets/Textures/Menu/Levels/18green_light.png",
	"res://Assets/Textures/Menu/Levels/19green_light.png",
	"res://Assets/Textures/Menu/Levels/20green_light.png",
	"res://Assets/Textures/Menu/Levels/21green_light.png",
	"res://Assets/Textures/Menu/Levels/22green_light.png",
	"res://Assets/Textures/Menu/Levels/23green_light.png",
	"res://Assets/Textures/Menu/Levels/24green_light.png",
]

const GREEN_PRESSED_TEXTURES: Array = [
	"res://Assets/Textures/Menu/Levels/17green_pressed.png",
	"res://Assets/Textures/Menu/Levels/18green_pressed.png",
	"res://Assets/Textures/Menu/Levels/19green_pressed.png",
	"res://Assets/Textures/Menu/Levels/20green_pressed.png",
	"res://Assets/Textures/Menu/Levels/21green_pressed.png",
	"res://Assets/Textures/Menu/Levels/22green_pressed.png",
	"res://Assets/Textures/Menu/Levels/23green_pressed.png",
	"res://Assets/Textures/Menu/Levels/24green_pressed.png",
]

var buttons: Array = []

func _ready() -> void:
	MusicManager.play_music(preload("res://Assets/audio/For_Levels/MainMenu.mp3"))

	var grid = $CenterContainer/GridContainer
	buttons = [
		grid.get_node("Button"),
		grid.get_node("Button2"),
		grid.get_node("Button3"),
		grid.get_node("Button4"),
		grid.get_node("Button5"),
		grid.get_node("Button6"),
		grid.get_node("Button7"),
		grid.get_node("Button8"),
	]

	for i in range(buttons.size()):
		var idx = i
		buttons[i].pressed.connect(func(): _on_level_pressed(idx))

	_refresh_buttons()

func _refresh_buttons() -> void:
	for i in range(buttons.size()):
		var btn: TextureButton = buttons[i]
		var unlocked: bool = GameData.is_level_unlocked(16 + i)
		var completed = GameData.is_level_completed(LEVEL_NAMES[i])

		btn.modulate = Color(1, 1, 1)

		if not unlocked:
			btn.disabled = true
		elif completed:
			btn.disabled = false
			btn.texture_normal = load(GREEN_TEXTURES[i])
			btn.texture_hover = load(GREEN_HOVER_TEXTURES[i])
			btn.texture_pressed = load(GREEN_PRESSED_TEXTURES[i])
		else:
			btn.disabled = false

func _on_level_pressed(index: int) -> void:
	var path = LEVEL_PATHS[index]
	if ResourceLoader.exists(path):
		SceneManager.go_to(path)

func _on_texture_button_pressed() -> void:
	SceneManager.go_to("res://Entities/Main/MainMenu.tscn")

func _on_texture_button_3_pressed() -> void:
	SceneManager.go_to("res://Entities/Main/Level_Menu_MaskDude.tscn")
