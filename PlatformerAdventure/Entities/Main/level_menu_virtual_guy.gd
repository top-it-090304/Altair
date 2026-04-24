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
	"Level1", "Level2", "Level3", "Level4", "Level5",
	"Level6", "Level7", "Level8"
]

const GREEN_TEXTURES: Array = [
	"res://Assets/Textures/Menu/Levels/1green.png",
	"res://Assets/Textures/Menu/Levels/2green.png",
	"res://Assets/Textures/Menu/Levels/3green.png",
	"res://Assets/Textures/Menu/Levels/4green.png",
	"res://Assets/Textures/Menu/Levels/5green.png",
	"res://Assets/Textures/Menu/Levels/6green.png",
	"res://Assets/Textures/Menu/Levels/7green.png",
	"res://Assets/Textures/Menu/Levels/8green.png",
]

const GREEN_HOVER_TEXTURES: Array = [
	"res://Assets/Textures/Menu/Levels/1green_light.png",
	"res://Assets/Textures/Menu/Levels/2green_light.png",
	"res://Assets/Textures/Menu/Levels/3green_light.png",
	"res://Assets/Textures/Menu/Levels/4green_light.png",
	"res://Assets/Textures/Menu/Levels/5green_light.png",
	"res://Assets/Textures/Menu/Levels/6green_light.png",
	"res://Assets/Textures/Menu/Levels/7green_light.png",
	"res://Assets/Textures/Menu/Levels/8green_light.png",
]

const GREEN_PRESSED_TEXTURES: Array = [
	"res://Assets/Textures/Menu/Levels/1green_grey.png",
	"res://Assets/Textures/Menu/Levels/2green_grey.png",
	"res://Assets/Textures/Menu/Levels/3green_grey.png",
	"res://Assets/Textures/Menu/Levels/4green_grey.png",
	"res://Assets/Textures/Menu/Levels/5green_grey.png",
	"res://Assets/Textures/Menu/Levels/6green_grey.png",
	"res://Assets/Textures/Menu/Levels/7green_grey.png",
	"res://Assets/Textures/Menu/Levels/8green_grey.png",
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

	# Button8 не имеет сигнала в .tscn — подключаем вручную
	buttons[7].pressed.connect(func(): _on_level_pressed(7))

	_refresh_buttons()

func _refresh_buttons() -> void:
	for i in range(buttons.size()):
		var btn: TextureButton = buttons[i]
		var unlocked = GameData.is_level_unlocked(i)
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
	SceneManager.go_to(LEVEL_PATHS[index])

# Кнопка «Назад»
func _on_texture_button_pressed() -> void:
	SceneManager.go_to("res://Entities/Main/MainMenu.tscn")

# Сигналы из Levels_Menu.tscn (Button – Button7)
func _on_button_pressed() -> void:
	_on_level_pressed(0)

func _on_button_2_pressed() -> void:
	_on_level_pressed(1)

func _on_button_3_pressed() -> void:
	_on_level_pressed(2)

func _on_button_4_pressed() -> void:
	_on_level_pressed(3)

func _on_button_5_pressed() -> void:
	_on_level_pressed(4)

func _on_button_6_pressed() -> void:
	_on_level_pressed(5)

func _on_button_7_pressed() -> void:
	_on_level_pressed(6)


func _on_texture_button_2_pressed() -> void:
	SceneManager.go_to("res://Entities/Main/Level_Menu_MaskDude.tscn")


func _on_texture_button_3_pressed() -> void:
	SceneManager.go_to("res://Entities/Main/Level_Menu_MaskDude.tscn")
