extends Entity

class_name EnemyWheel

var path_idx = 0
var path = [0,1,2,3]
var path_loop = true

var last_pos : Vector2
var next_pos : Vector2

var last_facing = 0.0
var next_facing = 0.0
var facing = 0.0

var mode = 0
export var speed = 100
export var ang_speed = 1

export var ease_mode = 1.0

var emitters = []

var flicker_clock = 0
var flicker_time = 0.02
var flicker_count = 0
var alive = true
export var max_health = 10.0
#func damage(damage, origin):
	#print(damage)

func _ready():
	set_mode(0)
	for em in $Body/Emitters.get_children():
		emitters.push_back(em)
	wake()

func _physics_process(delta):
	if not alive:
		return
	$Body.position = lerp(next_pos, last_pos, $PathTimer.time_left / $PathTimer.wait_time)
	$Body.rotation = lerp_angle(next_facing, last_facing, $FacingTimer.time_left / $FacingTimer.wait_time)
	if flicker_count > 0:
		if flicker_clock > 0:
			flicker_clock -= delta
		else:
			flicker_count -= 1
			flicker_clock = flicker_time
			if flicker_count % 3 == 1:
				$Body/AnimatedSprite.frame = 4
			else:
				$Body/AnimatedSprite.frame = mode

func set_emitter_enabled(status):
	for em in emitters:
		em.enabled = status

func set_emitter_mode(mode):
	for em in emitters:
		em.mode = mode

func find_emmiters():
	pass

func path_update():
	var index = path[path_idx]
	path_idx += 1
	last_pos = $Body.position
	last_facing = $Body.rotation
	if path_idx == len(path):
		path_idx = 0
	index = floor(rand_range(0, len(path)))
	if index == 0:
		next_pos = Vector2(50, 50)
		#next_facing = Vector2.UP
		next_facing = deg2rad(270)
	elif index == 1:
		next_pos = Vector2(400, 50)
		#next_facing = Vector2.RIGHT
		next_facing = deg2rad(90)
	elif index == 2:
		next_pos = Vector2(400, 200)
		#next_facing = Vector2.DOWN
		next_facing = deg2rad(90)
		pass
	elif index == 3:
		next_pos = Vector2(50, 200)
		#next_facing = Vector2.LEFT
		next_facing = deg2rad(270)
		pass
	$PathTimer.wait_time = (last_pos - next_pos).length() / speed
	$PathTimer.start()
	$FacingTimer.wait_time = 0.5
	$FacingTimer.start()

func wake():
	.wake()
	alive = true
	path_update()
	set_emitter_enabled(true)
	$Body.position = Vector2.ZERO
	$Body.rotation = 0
	health = max_health

func sleep():
	if not alive:
		return
	print("sleep")
	$DieTimer.start()
	$DieSfx.play()
	$Body/DieParticle.restart()
	alive = false
	$Body/DamageParticle.emitting = false
	set_emitter_enabled(false)

func damage(dam, damage_origin):
	.damage(dam, damage_origin)
	$Body/DamageParticle.restart()
	$Body/DamageParticle.amount = 100 - health * 10
	flicker_count = 3

func set_mode(mode):
	self.mode = mode
	$Body/AnimatedSprite.frame = mode
	var smode = mode
	if mode % 2 == 0:
		smode += 1
	else:
		smode -= 1
	$Body/AnimatedSprite/Shield.set_mode(smode)
	set_emitter_mode(mode)
	var colors = [Color(1, 0, 0), Color(0, 0, 1), Color(0, 1, 0), Color(0.8, 0, 1)]
	$Body/DamageParticle.color = colors[mode]
	$Body/DieParticle.color = colors[mode]


func _on_PathTimer_timeout():
	path_update()


func _on_DieTimer_timeout():
	.sleep()
	$Body.position = Vector2.ZERO
	$Body.rotation = 0
	$Body/DieParticle.emitting = false
	health = max_health
