extends Control

onready var loading_scene = preload("res://Assets/LoadingScreen.tscn")

func _ready():
	# dont show quit button in html version of the game
	var os = OS.get_name()
	if os == "HTML5":
		$VBoxContainer/QuitButton.hide()

func _on_PlayButton_pressed():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().change_scene_to(loading_scene)

func _on_OptionsButton_pressed():
	pass # Replace with function body.

func _on_QuitButton_pressed():
	get_tree().quit()
