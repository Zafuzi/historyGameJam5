extends CanvasLayer

func _input(event):
	if Input.is_action_just_pressed("mouse_release"):
		close()
		
func open():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	$CenterContainer/InGameMenu.popup_centered(Vector2.ZERO)

func close():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	queue_free()

func _on_InGameMenu_id_pressed(id):
	match id:
		0:
			close()
		1:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().paused = false
			get_tree().change_scene("res://Assets/StartMenu/StartMenu.tscn")
			queue_free()
		2:
			pass
		3:
			get_tree().quit()
