extends EnemyBase

var aim = 0
var last_aim = 0
var next_aim = 0
var mines = []

func set_emitter_mode(mode):
	if len(emitters) == 0:
		return
	var altmode
	if mode % 2 == 0:
		altmode = mode + 1
	else:
		altmode = mode - 1
	emitters[0].set_mode(mode)
	emitters[1].set_mode(altmode)
	$Body/MineEmitter.set_mode(mode)

func _physics_process(delta):
	._physics_process(delta)
	var ang = lerp(next_aim, last_aim, $AimTimer.time_left / $AimTimer.wait_time)
	for em in emitters:
		em.rotation = deg2rad(ang)

func path_update(index = null):
	if not index:
		# if path_idx is even
		#	then increment by 1
		#otherwise
		#	subtract 1, divide by 2
		#	roll a number from 0-2
		#	if that number is greater or equal to path_idx increment it
		#	multiply by 2, that's the new path idx
		index = path_idx
		if index % 2 == 0:
			path_idx += 1
		else:
			var temp = int(index / 2)
			var rand
			while true:
				rand = int(randf() * 5)
				if rand != temp:
					break
			#var rand = int(randf() * 3)
			#print(rand)
			#if rand >= temp:
			#	rand += 1
			path_idx = rand * 2
			if randf() < 0.25:
				mode_toggle()
			#print(path_idx)
		#path_idx += 1
		#if path_idx > 9:
		#	path_idx = 0
	else:
		path_idx = index
	last_pos = $Body.position
	last_aim = $Body/Emitters/Turret.rotation
	set_emitter_enabled(false)
	$Body/MineEmitter.enabled = false
	var min_x = 25
	var max_x = 450
	var min_y = 50
	var max_y = 250
	if index == 0:
		next_pos = Vector2(min_x, min_y)
		for mine in mines:
			if mine.alive:
				mine.sleep()
		mines = []
	elif index == 1:
		next_pos = Vector2(max_x, min_y)
		# emit mines
		$Body/MineEmitter.enabled = true
	if index == 2:
		next_pos = Vector2(max_x, min_y)
		for mine in mines:
			if mine.alive:
				mine.sleep()
		mines = []
	elif index == 3:
		next_pos = Vector2(min_x, min_y)
		# emit mines
		$Body/MineEmitter.enabled = true
	elif index == 4:
		next_pos = Vector2(min_x, max_y)
	elif index == 5:
		next_pos = Vector2(max_x, max_y)
		set_emitter_enabled(true)
		last_aim = 180
		next_aim = 180
	elif index == 6:
		next_pos = Vector2(max_x, max_y)
	elif index == 7:
		next_pos = Vector2(min_x, max_y)
		set_emitter_enabled(true)
		last_aim = 180
		next_aim = 180
	elif index == 8:
		next_pos = Vector2( (max_x + min_x) / 2, max_y)
	elif index == 9:
		last_aim = 80
		next_aim = 280
		$PathTimer.wait_time = 2
		$AimTimer.wait_time = 2
		$AimTimer.start()
		set_emitter_enabled(true)
	if index != 9:
		$PathTimer.wait_time = (last_pos - next_pos).length() / speed
	$PathTimer.start()

func wake():
	.wake()
	set_emitter_enabled(false)
	for em in emitters:
			em.fire_time = 0.2
			em.speed = 150
