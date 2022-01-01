extends KinematicBody

export var speed = 10
export var acceleration = 5
export var gravity = 0.98

export (NodePath) var Player
var player_node = null

signal was_shot

func _ready():
	if Player:
		player_node = get_node(Player)
	add_to_group("enemies")
	
func _physics_process(delta):
	
	var velocity = Vector3()
	var direction = Vector3()
	
	if player_node:
		# todo fix this
		direction = player_node.transform.origin.normalized()
	
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	velocity.y -= gravity
	velocity = move_and_slide(velocity, Vector3.UP)
	pass

func _on_GenericEnemy_was_shot():
	queue_free()
