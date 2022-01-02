extends Area

signal exploded

export var muzzle_velocity = 60
export var g = Vector3.DOWN * 40

onready var BulletImpact = preload("res://Bullet/BulletImpact.tscn")

var velocity = Vector3.ZERO

func _physics_process(delta):
	velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta

func _on_PhysicalBullet_body_entered(body):
	if body.is_in_group("enemies"):
		body.emit_signal("was_shot")
		
	emit_signal("exploded")

func _on_PhysicalBullet_exploded():
	var b = BulletImpact.instance()
	b.transform = transform
	get_tree().get_root().add_child(b)
	queue_free()
