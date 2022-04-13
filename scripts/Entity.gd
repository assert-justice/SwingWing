extends Node2D

class_name Entity

var pool = null
var awake = true
var origin = null
export var points = 0

export (Vector2) var velocity
export var health = 1.0

func set_origin(origin):
	self.origin = origin

func damage(dam, damage_origin):
	if not awake:
		return
	var mess = 0
	health -= dam
	if health <= 0:
		mess = points
		sleep()
	if damage_origin:
		damage_origin.register(mess)

func set_pool(pool):
	self.pool = pool

func wake():
	visible = true
	awake = true
	#$AnimatedSprite/Area2D/CollisionShape2D.disabled = false
	visible = true

func sleep():
	visible = false
	#$AnimatedSprite/Area2D/CollisionShape2D.disabled = true
	if pool:
		pool.sleep(self)
	awake = false
	translate(Vector2.LEFT * 1000)

func _physics_process(delta):
	if awake:
		translate(velocity * delta)
