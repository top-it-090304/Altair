extends Node

@onready var collect_sound = $CollectSound
@export_range(-40, 0) var collect_volume_db: float = 0.0   
func play_collect():
	collect_sound.volume_db = collect_volume_db
	collect_sound.play()
