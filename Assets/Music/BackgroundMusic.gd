extends AudioStreamPlayer

export (Array, AudioStreamOGGVorbis) var in_game_music : Array
export (Array, AudioStreamOGGVorbis) var menu_music : Array

var next_song = 0

func play_menu_music():
	$"/root/BackgroundMusic".stream = menu_music[next_song]
	$"/root/BackgroundMusic".play()
	$"/root/BackgroundMusic".stream_paused = false

#just to avoid the glichy sounds on the html version when loading a  scene
func pause_music():
	$"/root/BackgroundMusic".stream_paused = true
	
func _on_BackgroundMusic_finished():
	pause_music()
	next_song += 1
	if next_song > menu_music.size():
		next_song = 0
	play_menu_music()
