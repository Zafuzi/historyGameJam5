extends KinematicBody

export var speed = 10
export var sprint_speed = 20
export var acceleration = 5
export var gravity = 0.98
export var jump_power = 30
export var mouse_sensitivity = 0.3
export var recoil = 2
export var health = 3
signal was_shot

var rng = RandomNumberGenerator.new()

onready var head = $Head
onready var camera = $Head/Camera
onready var raycast = $Head/Camera/BulletCast


onready var Bullet = preload("res://Assets/Bullet/PhysicalBullet.tscn")

var velocity = Vector3()
var camera_x_rotation = 0
var head_basis = Vector3()
var direction = Vector3()

var shotTimerReady = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#rng.randomize()

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))

		var x_delta = event.relative.y * mouse_sensitivity
		if camera_x_rotation + x_delta > -90 and camera_x_rotation + x_delta < 90: 
			camera.rotate_x(deg2rad(-x_delta))
			$Gun.rotate_x(deg2rad(-x_delta))
			camera_x_rotation += x_delta
	
func find_nearest_completion_area():
	var potential_covers = get_tree().get_nodes_in_group("completion_area")
	var MAX_DISTANCE = 1000
	var nearest_completion_area = null
	for cover in potential_covers:
		var distance = global_transform.origin.distance_to(cover.global_transform.origin)
		if distance < MAX_DISTANCE:
			nearest_completion_area = cover
	return nearest_completion_area
		
func _process(delta):
	if shotTimerReady:
		$Head/Camera/CanvasLayer/Control/TextureRect.visible = true
	else:
		$Head/Camera/CanvasLayer/Control/TextureRect.visible = false
		
	if Input.is_action_just_pressed("shoot"):
		if shotTimerReady:
			shotTimerReady = false
			$ShotTimer.start()
			$GunShotSound.play()
			
			var b = Bullet.instance()
			owner.add_child(b)
			b.transform = $Gun/Muzzle.global_transform
			b.velocity = -b.transform.basis.z * b.muzzle_velocity
			
			add_player_recoil()
	
	match health:
		3:
			$Head/Camera/CanvasLayer/Control/Heart0.animation = "full"
			$Head/Camera/CanvasLayer/Control/Heart1.animation = "full"
			$Head/Camera/CanvasLayer/Control/Heart2.animation = "full"
		2:
			$Head/Camera/CanvasLayer/Control/Heart0.animation = "empty"
			$Head/Camera/CanvasLayer/Control/Heart1.animation = "full"
			$Head/Camera/CanvasLayer/Control/Heart2.animation = "full"
		1:
			$Head/Camera/CanvasLayer/Control/Heart0.animation = "empty"
			$Head/Camera/CanvasLayer/Control/Heart1.animation = "empty"
			$Head/Camera/CanvasLayer/Control/Heart2.animation = "full"
		0:
			$Head/Camera/CanvasLayer/Control/Heart0.animation = "empty"
			$Head/Camera/CanvasLayer/Control/Heart1.animation = "empty"
			$Head/Camera/CanvasLayer/Control/Heart2.animation = "empty"
			get_tree().reload_current_scene() 
			pass
	
	var nearest_completion_area = find_nearest_completion_area()
	if nearest_completion_area:
		var target_pos = nearest_completion_area.global_transform.origin
		$Head/Camera/compass.look_at(target_pos * PI/2, Vector3.UP)


func _physics_process(delta):
	head_basis = head.get_global_transform().basis
	
	direction = Vector3()
	if Input.is_action_pressed("move_forward"):
		direction -= head_basis.z
	elif Input.is_action_pressed("move_backward"):
		direction += head_basis.z
	
	if Input.is_action_pressed("move_left"):
		direction -= head_basis.x
	elif Input.is_action_pressed("move_right"):
		direction += head_basis.x
	
	direction = direction.normalized()
	
	var move_speed = speed
	if Input.is_action_pressed("sprint"):
		move_speed = sprint_speed
		
	velocity = velocity.linear_interpolate(direction * move_speed + velocity.y*Vector3.UP, acceleration * delta)
	velocity.y -= gravity
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += jump_power
	
	velocity = move_and_slide(velocity, Vector3.UP)


func _on_ShotTimer_timeout():
	shotTimerReady = true
	pass # Replace with function body.


func add_player_recoil():
	rotate_y(deg2rad(rng.randi_range(-recoil,recoil)))

	var x_delta = -recoil
	if camera_x_rotation + x_delta > -90 and camera_x_rotation + x_delta < 90: 
		camera.rotate_x(deg2rad(-x_delta))
		$Gun.rotate_x(deg2rad(-x_delta))
		camera_x_rotation += x_delta

func _on_Player_was_shot():
	health -= 1
	$HitSound.play()
	$OuchSound.play()
