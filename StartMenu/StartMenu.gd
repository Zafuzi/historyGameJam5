extends Control

func _ready():
	# dont show quit button in html version of the game
	var os = OS.get_name()
	if os == "HTML5":
		$CenterContainer/VBoxContainer2/QuitButton.hide()

func _on_PlayButton_pressed():
	get_tree().change_scene_to(Globals.g_next_level)
	pass # Replace with function body.

func _on_OptionsButton_pressed():
	pass # Replace with function body.

func _on_QuitButton_pressed():
	get_tree().quit()
	pass # Replace with function body.
