extends KinematicBody



const TURN_SPEED = 10
const GUN_RANGE = 150
const COVER_RANGE = 30
const SIGHT_RANGE = 60
export var health = 2

var player_inbound

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

onready var nav = get_tree().get_nodes_in_group("navigation")[0]

func _ready():
	pass
	
func _on_ShotTimer_timeout():
	shotTimerReady = true


	

func _on_SightRange_body_entered(body):
	if body.is_in_group("player"):
		player_inbound = true

func _on_SightRange_body_exited(body):
	if body.is_in_group("player"):
		player_inbound = false
	
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
		b.emit_group = "enemies"
		b.g *= 0
		

	

	

func turn_towards_player():
	$Eyes.look_at(player.global_transform.origin, Vector3.UP)
	$Eyes.look_at(player.global_transform.origin, Vector3.LEFT)
	rotate_y(deg2rad($Eyes.rotation.y) * TURN_SPEED)
	rotate_z(deg2rad($Eyes.rotation.x)* TURN_SPEED)
	

func _physics_process(delta):
	if player_inbound:
		turn_towards_player()
		shoot()



func _on_SniperEnemy_was_shot():
	health-=1
	if health<=0:
		queue_free()

