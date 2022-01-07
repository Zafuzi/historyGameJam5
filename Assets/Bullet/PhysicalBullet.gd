extends Area

signal exploded

export var emit_group = "player"
export var muzzle_velocity = 60
export var g = Vector3.DOWN * 40

onready var BulletImpact = preload("res://Assets/Bullet/BulletImpact.tscn")
onready var blood = preload("res://Assets/Bullet/blood effect.tscn")

var velocity = Vector3.ZERO

func _physics_process(delta):
	velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta

func _on_PhysicalBullet_body_entered(body):
	if emit_group == "enemies":
		if  body.is_in_group("player"):
			body.emit_signal("was_shot")
			print("player was shot")
			draw_blood()
		else:
			print("the thing that was shot was: " + body.name)
	else:
		if body.is_in_group("enemies"):
			body.emit_signal("was_shot")
			print("enemy was shot")
			draw_blood()
		
	emit_signal("exploded")

func _on_PhysicalBullet_exploded():
	var b = BulletImpact.instance()
	b.transform = transform
	get_tree().get_root().add_child(b)
	queue_free()

func draw_blood():
	var b = blood.instance()
	b.transform = transform
	get_tree().get_root().add_child(b)
	
