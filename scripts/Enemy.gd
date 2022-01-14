extends Entity

var mode

func _ready():
	$AnimationPlayer.play("Move")
	
func _physics_process(delta):
	._physics_process(delta)
	if position.y > 500:
		sleep()

func damage(dam, origin = null):
	if origin.mode == mode:
	#if true:
		for i in range(-1, 2):
			var bul = $AnimatedSprite/Emitter.fire()
			bul.velocity.x += i * 50
			bul.velocity = bul.velocity.normalized()
			bul.velocity *= 100
			
	.damage(dam, origin)
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
	self.mode = mode
	$AnimatedSprite.frame = mode
	$AnimatedSprite/Emitter.mode = mode
