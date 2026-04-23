extends Control

const LEVEL_PATHS: Array = [
	"res://Levels/MaskDude_9-15Levels/Level9.tscn",
	"res://Levels/MaskDude_9-15Levels/Level10.tscn",
	"res://Levels/MaskDude_9-15Levels/Level11.tscn",
	"res://Levels/MaskDude_9-15Levels/Level12.tscn",
	"res://Levels/MaskDude_9-15Levels/Level13.tscn",
	"res://Levels/MaskDude_9-15Levels/Level14.tscn",
	"res://Levels/MaskDude_9-15Levels/Level15.tscn",
	"res://Levels/MaskDude_9-15Levels/Level16.tscn",
]

const LEVEL_NAMES: Array = [
	"Level9", "Level10", "Level11", "Level12",
	"Level13", "Level14", "Level15", "Level16"
]

# Смещение в GameData.LEVEL_ORDER: уровни 9-16 = индексы 8-15
const LEVEL_INDEX_OFFSET = 8

const GREEN_TEXTURES: Array = [
	"res://Assets/Textures/Menu/Levels/9green.png",
	"res://Assets/Textures/Menu/Levels/10green.png",
	"res://Assets/Textures/Menu/Levels/11green.png",
	"res://Assets/Textures/Menu/Levels/12green.png",
	"res://Assets/Textures/Menu/Levels/13green.png",
	"res://Assets/Textures/Menu/Levels/14green.png",
	"res://Assets/Textures/Menu/Levels/15green.png",
	"res://Assets/Textures/Menu/Levels/16green.png",
]

const GREEN_HOVER_TEXTURES: Array = [
	"res://Assets/Textures/Menu/Levels/9green_light.png",
	"res://Assets/Textures/Menu/Levels/10green_light.png",
	"res://Assets/Textures/Menu/Levels/11green_light.png",
	"res://Assets/Textures/Menu/Levels/12green_light.png",
	"res://Assets/Textures/Menu/Levels/13green_light.png",
	"res://Assets/Textures/Menu/Levels/14green_light.png",
	"res://Assets/Textures/Menu/Levels/15green_light.png",
	"res://Assets/Textures/Menu/Levels/16green_light.png",
]

const GREEN_PRESSED_TEXTURES: Array = [
	"res://Assets/Textures/Menu/Levels/9green_grey.png",
	"res://Assets/Textures/Menu/Levels/10green_grey.png",
	"res://Assets/Textures/Menu/Levels/11green_grey.png",
	"res://Assets/Textures/Menu/Levels/12green_grey.png",
	"res://Assets/Textures/Menu/Levels/13green_grey.png",
	"res://Assets/Textures/Menu/Levels/14green_grey.png",
	"res://Assets/Textures/Menu/Levels/15green_grey.png",
	"res://Assets/Textures/Menu/Levels/16green_grey.png",
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
		var unlocked = GameData.is_level_unlocked(i + LEVEL_INDEX_OFFSET)
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

# Кнопка «Назад»
func _on_texture_button_pressed() -> void:
	SceneManager.go_to("res://Entities/Main/MainMenu.tscn")

# Сигналы из Level_Menu_MaskDude.tscn (Button – Button7)
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
