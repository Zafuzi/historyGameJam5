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
const GUN_RANGE = 40
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
		state = COVERING

func _on_SightRange_body_exited(body):
	state = IDLE
	
func shoot():
	if $Eyes/RayCast.is_colliding():
		var hit = $Eyes/RayCast.get_collider()
		if hit.is_in_group("player"):
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
		
func calculate_move_to(pos):
	path = nav.get_simple_path(global_transform.origin, pos)
	path_node = 0
	
func find_nearest_cover():
	var potential_covers = get_tree().get_nodes_in_group("cover")
	var MAX_DISTANCE = 1000
	var nearest_cover = null
	for cover in potential_covers:
		var distance = global_transform.origin.distance_to(cover.global_transform.origin)
		if distance < MAX_DISTANCE:
			# check if cover is in sight range of player
			if playerRaycast.is_colliding():
				var hit = playerRaycast.get_collider()
				if hit.is_in_group("cover"):
					if hit != cover:
						nearest_cover = cover
	return nearest_cover
	
func _on_MoveTimer_timeout():
	match state:
		IDLE:
			calculate_move_to(player.global_transform.origin)
		RESTING:
			take_cover()
		MOVING:
			calculate_move_to(player.global_transform.origin)
			#print("HUNTING!")
		SHOOTING:
			isSprinting = 1
			calculate_move_to(global_transform.origin)
			#print("SHOOTING!")
		COVERING: 
			take_cover()
					
func take_cover():
	isSprinting = 2
	var nearest_cover = find_nearest_cover()
	if nearest_cover:
		target = nearest_cover
		match state:
			RESTING:
				calculate_move_to(nearest_cover.global_transform.origin)
				print("TAKE COVER! RESTING!")
			COVERING:
				# if the player is too close, TAKE COVER!
				var distance = global_transform.origin.distance_to(player.global_transform.origin)
				if distance < COVER_RANGE:
					calculate_move_to(nearest_cover.global_transform.origin)
					print("TAKE COVER!")
	
func move():
	if path_node < path.size():
		var direction = (path[path_node] - global_transform.origin)
		if direction.length() < 1:
			path_node += 1
			stop_walk_animation_if_possible()
		else:
			var x = move_and_slide(direction.normalized() * MOVE_SPEED * (isSprinting * COVER_SPEED_MULTIPLIER), Vector3.UP)
			if x:
				start_walking_animation_if_possible()
			else:
				stop_walk_animation_if_possible()

func _physics_process(delta):
	$Eyes.look_at(player.global_transform.origin, Vector3.UP)
	rotate_y(deg2rad($Eyes.rotation.y) * TURN_SPEED)
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
		MOVING:
			move()
		SHOOTING:
			move()
			shoot()
		COVERING:
			move()
			shoot()
		RESTING:
			move()
	
	$StatusLabel.play(str(state))

func stop_walk_animation_if_possible():
	if get_node_or_null("walkingAnimation"):
		$walkingAnimation.playback_speed = 2
		$walkingAnimation.play("RESET")
func start_walking_animation_if_possible():
	if get_node_or_null("walkingAnimation"):
		$walkingAnimation.playback_speed = 2
		$walkingAnimation.play("walking")
		
	
