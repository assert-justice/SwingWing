extends EnemyBase

func wake():
	.wake()
	# randomize body's starting position
	$Body.position.x = rand_range(50, 400)
	$Body.position.y = -50
	last_pos = $Body.position
	#next_pos = $Body.position
	path_update(randi() % 3)
	var delay = 0
	for em in emitters:
		em.speed = 100
		em.fire_time = 2
		#em.fire_delay = delay
		#em.set_delay(delay)
		#delay += 0.25

func path_update(index = null):
	if not index:
		index = randi() % 3
	path_idx = index
	last_pos = $Body.position
	last_facing = $Body.rotation
	next_facing = deg2rad(randi() % 8 * 45)
	var next_y = 125
	if randf() < 0.5:
		next_y += 50
	else:
		next_y -= 50
	if index == 0:
		next_pos = Vector2(50, next_y)
	elif index == 1:
		next_pos = Vector2(225, next_y)
	elif index == 2:
		next_pos = Vector2(400, next_y)
	
	$PathTimer.wait_time = (last_pos - next_pos).length() / speed
	$PathTimer.start()
	$FacingTimer.wait_time = 0.5
	$FacingTimer.start()
