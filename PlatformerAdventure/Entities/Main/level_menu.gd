extends Control

const LEVEL_PATHS: Array = [
	"res://Levels/PinkMan_1-12Levels/Level1.tscn",
	"res://Levels/PinkMan_1-12Levels/Level2.tscn",
	"res://Levels/PinkMan_1-12Levels/Level3.tscn",
	"res://Levels/PinkMan_1-12Levels/Level4.tscn",
	"res://Levels/PinkMan_1-12Levels/Level_n.tscn",
	"res://Levels/VirtualGuy_13-24Levels/LevelV.tscn",
	"res://Levels/PinkMan_1-12Levels/Level7.tscn",
	"res://Levels/PinkMan_1-12Levels/Level8.tscn",
]

const LEVEL_NAMES: Array = [
	"Level1", "Level2", "Level3", "Level4", "Level_n",
	"LevelV", "Level7", "Level8"
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
			btn.modulate = Color(0.5, 1.0, 0.5)
		else:
			btn.disabled = false

func _on_level_pressed(index: int) -> void:
	get_tree().change_scene_to_file(LEVEL_PATHS[index])

# Кнопка «Назад»
func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Entities/Main/MainMenu.tscn")

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
