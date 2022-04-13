extends Entity

var mode = 0
var dam
var hit = false
var hit_origin

func _ready():
	$AnimationPlayer.play("Move")
	
func _physics_process(delta):
	._physics_process(delta)
	if position.y > 500:
		sleep()

func damage(dam, origin = null):
	if hit:
		return
	hit = true
	$AnimatedSprite/DieSfx.play()
	$AnimatedSprite/DieVfx.emitting = true
	$AnimatedSprite/DieVfx.visible = true
	$AnimatedSprite/Timer.start()
	$AnimatedSprite.play("default")
	$AnimationPlayer.stop()
	var colors = [Color(1, 0, 0), Color(0, 0, 1), Color(0, 1, 0), Color(0.8, 0, 1)]
	$AnimatedSprite/DieVfx.color = colors[mode]
	velocity = Vector2.ZERO
	self.dam = dam
	self.hit_origin = origin
	if origin.mode == mode:
	#if true:
		for i in range(-1, 2):
			var bul = $AnimatedSprite/Emitter.fire()
			bul.velocity.x += i * 50
			bul.velocity = bul.velocity.normalized()
			bul.velocity *= 100
			
	#print("enemy damaged", health, awake)

func sleep():
	.sleep()
	$AnimationPlayer.stop()
	$AnimatedSprite/Emitter.enabled = false

func wake():
	.wake()
	$AnimationPlayer.play("Move")
	$AnimatedSprite/Emitter.enabled = true
	hit = false

func set_mode(mode):
	self.mode = mode
	$AnimatedSprite.frame = mode
	$AnimatedSprite/Emitter.mode = mode


func _on_Timer_timeout():
	$AnimatedSprite/DieVfx.visible = false
	$AnimatedSprite.stop()
	.damage(dam, hit_origin)
