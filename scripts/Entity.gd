extends Node2D

class_name Entity

var pool
var awake = true

export (Vector2) var velocity
export var health = 1.0

func damage(dam):
	health -= dam
	#if health <= 0:
		#sleep()

func set_pool(pool):
	self.pool = pool

func wake():
	visible = true
	awake = true

func sleep():
	#visible = false
	#$AnimatedSprited/Area2D/CollisionShape2D.disabled = true
	$AnimatedSprite/Area2D/CollisionShape2D.disabled = true
	pool.sleep(self)
	awake = false

func _physics_process(delta):
	if awake:
		translate(velocity * delta)
