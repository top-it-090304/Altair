extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer

var current_track: AudioStream = null

func play_music(track: AudioStream):
	if track == null:
		return

	# Если уже играет этот же трек — не трогаем
	if current_track == track and music_player.playing:
		return

	# Если играет другой трек — просто заменяем
	current_track = track
	music_player.stream = track
	music_player.play()

func stop_music():
	music_player.stop()
	current_track = null

func is_playing(track: AudioStream) -> bool:
	return current_track == track and music_player.playing
