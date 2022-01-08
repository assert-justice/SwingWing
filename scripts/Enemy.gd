extends Entity

func _ready():
	$AnimationPlayer.play("Move")

func damage(dam):
	.damage(dam)
	#print("enemy damaged", health, awake)

func sleep():
	.sleep()
	$AnimationPlayer.stop()
	$AnimatedSprite/Emitter.enabled = false

func wake():
	.wake()
	$AnimationPlayer.play("Move")
	$AnimatedSprite/Emitter.enabled = true

func set_mode(mode):
	$AnimatedSprite.frame = mode
	$AnimatedSprite/Emitter.mode = mode
