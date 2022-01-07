extends Entity

class_name Bullet

func _physics_process(delta):
	._physics_process(delta)
	if position.x < 0 or position.x > 480 or position.y < 0 or position.y > 270:
		sleep()
