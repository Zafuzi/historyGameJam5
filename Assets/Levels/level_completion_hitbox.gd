extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export (PackedScene) var next_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_level_completion_box_body_entered(body):
	if body.is_in_group("player"):
		print("NEW LEVEL TRIGGER")
		if next_scene:
			get_tree().change_scene_to(next_scene)
		else:
			print("SCENE NOT FOUND")
			
		
