extends AudioStreamPlayer

export (Array, AudioStreamOGGVorbis) var in_game_music : Array
export (Array, AudioStreamOGGVorbis) var menu_music : Array

func play_menu_music():
	$"/root/BackgroundMusic".stream = menu_music[0]
	$"/root/BackgroundMusic".play(1.8)
	$"/root/BackgroundMusic".pause_mode = false
	pass

#just to avoid the annoying repeating sounds on the html version
func pause_music():
	$"/root/BackgroundMusic".pause_mode = true
	
