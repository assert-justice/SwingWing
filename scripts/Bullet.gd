extends Entity

class_name Bullet

export var damage = 1

export var team = 0

# collision masks
# 1-4 player hulls
# 5-8 enemy hulls
# 9 player bullet hulls
# 10 enemy bullet hulls

func _physics_process(delta):
	._physics_process(delta)
	if position.x < 0 or position.x > 480 or position.y < 0 or position.y > 270:
		sleep()


func _on_Area2D_area_entered(area):
	area.get_parent().get_parent().damage(damage)
