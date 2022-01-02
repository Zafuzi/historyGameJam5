extends KinematicBody

enum {
	IDLE
	SHOOTING
	RECOIL
	COVERING
}
var state = IDLE
const TURN_SPEED = 10
onready var player = get_tree().get_nodes_in_group("player")[0]
export (PackedScene) var bullet
signal was_shot
var shotTimerReady = false
var sightRange = 30

var path = []
var path_node = 0

const MOVE_SPEED = 10
const COVER_SPEED_MULTIPLIER = 2
var isSprinting = 1

onready var nav = get_tree().get_nodes_in_group("navigation")[0]

func _ready():
	pass
	
func _on_ShotTimer_timeout():
	shotTimerReady = true
	
func _on_GenericEnemy_was_shot():
	queue_free()

func _on_SightRange_body_entered(body):
	if body.is_in_group("player"):
		state = COVERING

func _on_SightRange_body_exited(body):
	state = IDLE
	
	
func shoot():
	if shotTimerReady:
		state = RECOIL
		shotTimerReady = false
		$ShotTimer.start()
		$GunShotSound.play()
		
		var b = bullet.instance()
		owner.add_child(b)
		b.transform = $Gun/Muzzle.global_transform
		b.velocity = -b.transform.basis.z * b.muzzle_velocity
		
func move_to(pos):
	path = nav.get_simple_path(global_transform.origin, pos)
	path_node = 0
	
func find_nearest_cover():
	var potential_covers = get_tree().get_nodes_in_group("cover")
	var MAX_DISTANCE = 1000
	var nearest_cover = null
	for cover in potential_covers:
		var distance = global_transform.origin.distance_to(cover.global_transform.origin)
		if distance < MAX_DISTANCE:
			nearest_cover = cover
	return nearest_cover
	
func _on_MoveTimer_timeout():
	match state:
		IDLE:
			move_to(player.global_transform.origin)
			#print("HUNTING!")
		SHOOTING:
			isSprinting = 1
			move_to(global_transform.origin)
			#print("SHOOTING!")
		COVERING: 
			isSprinting = 2
			var distance = global_transform.origin.distance_to(player.global_transform.origin)
			if distance < 40:
				var nearest_cover = find_nearest_cover()
				if nearest_cover:
					move_to(nearest_cover.global_transform.origin)
					#print("TAKE COVER!")
					
func _process(delta):
	match state:
		SHOOTING:
			shoot()
		RECOIL:
			$AnimationPlayer.play("RECOIL")
			
	$Eyes.look_at(player.global_transform.origin, Vector3.UP)
	rotate_y(deg2rad($Eyes.rotation.y) * TURN_SPEED)
	
	if state != COVERING:
		if $Eyes/RayCast.is_colliding():
			var hit = $Eyes/RayCast.get_collider()
			if hit.is_in_group("player"):
				state = SHOOTING
			else:
				state = IDLE

func _physics_process(delta):
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < 1:
			path_node += 1
		else:
			move_and_slide(direction.normalized() * MOVE_SPEED * (isSprinting * COVER_SPEED_MULTIPLIER), Vector3.UP)

