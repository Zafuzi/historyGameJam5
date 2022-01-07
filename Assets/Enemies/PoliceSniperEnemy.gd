extends KinematicBody

enum {
	IDLE
	MOVING
	SHOOTING
	COVERING
	RESTING
}
var state = IDLE
const TURN_SPEED = 10
const GUN_RANGE = 150
const COVER_RANGE = 30
const SIGHT_RANGE = 60
export var gun_shot_randomness = 5 
export var health = 2


onready var player = get_tree().get_nodes_in_group("player")[0]
onready var playerRaycast = player.get_node("RayCast")

export (PackedScene) var bullet
signal was_shot
var shotTimerReady = false

var path = []
var path_node = 0

const MOVE_SPEED = 3
const COVER_SPEED_MULTIPLIER = 1.2
var isSprinting = 1

var distance_to_player = 0

onready var target = player

var rng = RandomNumberGenerator.new()

onready var nav = get_tree().get_nodes_in_group("navigation")[0]

func _ready():
	pass
	
func _on_ShotTimer_timeout():
	shotTimerReady = true

func _on_RestTimer_timeout():
	match state:
		RESTING:
			#print("moving")
			state = MOVING
		IDLE:
			#print("resting")
			state = RESTING
		SHOOTING:
			#print("resting")
			state = RESTING
		COVERING:
			#print("resting")
			state = RESTING
	
func _on_GenericEnemy_was_shot():
	health-=1
	if health<=0:
		queue_free()


func _on_SightRange_body_entered(body):
	if body.is_in_group("player"):
		state = SHOOTING

func _on_SightRange_body_exited(body):
	state = IDLE
	
func shoot():
	var hit = player
	if shotTimerReady:
		$AnimationPlayer.play("RECOIL")
		shotTimerReady = false
		$ShotTimer.start()
		$GunShotSound.play()
		
		var b = bullet.instance()
		owner.add_child(b)
		b.transform = $Gun/Muzzle.global_transform
		b.velocity = -b.transform.basis.z * b.muzzle_velocity
		b.velocity += Vector3.ONE*rng.randi_range(-gun_shot_randomness,gun_shot_randomness)
		b.emit_group = "enemies"
		b.g *= 0
		
func calculate_move_to(pos):
	path = nav.get_simple_path(global_transform.origin, pos)
	path_node = 0
	

	
func _on_MoveTimer_timeout():
	match state:
		SHOOTING:
			isSprinting = 1
			calculate_move_to(global_transform.origin)
			#print("SHOOTING!")
					


func _physics_process(delta):
	$Eyes.look_at(player.global_transform.origin, Vector3.UP)
	$Eyes.look_at(player.global_transform.origin, Vector3.LEFT)
	rotate_y(deg2rad($Eyes.rotation.y) * TURN_SPEED)
	rotate_z(deg2rad($Eyes.rotation.x)* TURN_SPEED)
	distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)
	# if the player is not within sight range, hunt them down
	# if the player is within gun range, shoot them
	# if the player is within cover range, take cover
	# if i am resting... REST
	
	if state != RESTING:
		if distance_to_player > SIGHT_RANGE:
			state = MOVING
		elif distance_to_player <= GUN_RANGE:
			if distance_to_player <= COVER_RANGE:
				state = COVERING
			else:
				state = SHOOTING
		
	match state:
		SHOOTING:
			shoot()
		COVERING:
			shoot()
	
	$StatusLabel.play(str(state))



func _on_SniperEnemy_was_shot():
	health-=1
	if health<=0:
		queue_free()

