extends Entity

class_name Bullet

export var damage = 1.0

# export var team = 0 infer from collision layer
# if collision layer == 256 it's a player bullet

var mode = 0

# collision masks
# 1-4 player hulls
# 5-8 enemy hulls
# 9 player bullet hulls
# 10 enemy bullet hulls

func _physics_process(delta):
	if not awake:
		return
	._physics_process(delta)
	if position.x < 0 or position.x > 480 or position.y < 0 or position.y > 270:
		sleep()
	$AnimatedSprite.rotation = velocity.angle_to(Vector2.LEFT)


func _on_Area2D_area_entered(area):
	if awake:
		area.get_parent().get_parent().damage(damage, origin)
		sleep()

func set_mode(mode):
	self.mode = mode
	$AnimatedSprite.frame = mode
	if $AnimatedSprite/Area2D.collision_layer == 512:
		# if enemy set mask
		$AnimatedSprite/Area2D.collision_mask = pow(2, mode)
