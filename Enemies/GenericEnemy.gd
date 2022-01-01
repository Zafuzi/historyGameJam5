extends KinematicBody

var path = []
var path_node = 0

var speed = 20

export(NodePath) var PlayerNodePath
onready var nav = get_parent()

var player = null

signal was_shot

func _ready():
	if PlayerNodePath:
		player = get_node(PlayerNodePath)
		
	add_to_group("enemies")

func _physics_process(delta):
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < 1:
			path_node += 1
		else:
			var distance = global_transform.origin.distance_to(player.global_transform.origin)
			if distance <= 10:
				# todo start shooting!
				pass
			else:
				move_and_slide(direction.normalized() * speed, Vector3.UP)

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func _on_GenericEnemy_was_shot():
	queue_free()

func _on_Timer_timeout():
	if player:
		move_to(player.global_transform.origin)
