extends Node2D

class_name Entity

var pool

export (Vector2) var velocity

func set_pool(pool):
	self.pool = pool

func wake():
	print("wake")
	pause_mode = PAUSE_MODE_INHERIT
	visible = true

func sleep():
	pause_mode = PAUSE_MODE_STOP
	visible = false
	pool.sleep(self)

func _physics_process(delta):
	translate(velocity * delta)
