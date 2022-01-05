extends AudioStreamPlayer

export (Array, AudioStreamOGGVorbis) var in_game_music : Array
export (Array, AudioStreamOGGVorbis) var menu_music : Array

func play_menu_music():
	$"/root/BackgroundMusic".stream = menu_music[0]
	$"/root/BackgroundMusic".play(1.8)
	$"/root/BackgroundMusic".stream_paused = false

#just to avoid the glichy sounds on the html version when loading a  scene
func pause_music():
	$"/root/BackgroundMusic".stream_paused = true
	
