extends EnemyBase

func wake():
	.wake()
	# randomize body's starting position
	$Body.position.x = rand_range(50, 400)
	$Body.position.y = -50
	last_pos = $Body.position
	#next_pos = $Body.position
	path_update(randi() % 4)

func path_update(index = null):
	if index:
		path_idx = index
	else:
		index = path_idx
		# should the enemy switch sides?
		if randf() < 0.3:
			index = int(rand_range(0,2))
			if path_idx < 2:
				index += 2
		else:
			if index % 2 == 0:
				index += 1
			else:
				index -= 1
		# should the enemy toggle modes?
		if randf() < 0.2:
			mode_toggle()
	path_idx = index
	last_pos = $Body.position
	last_facing = $Body.rotation
	if index == 0:
		next_pos = Vector2(50, 50)
		#next_facing = Vector2.UP
		next_facing = deg2rad(270)
	elif index == 1:
		next_pos = Vector2(50, 200)
		#next_facing = Vector2.LEFT
		next_facing = deg2rad(270)
	elif index == 2:
		next_pos = Vector2(400, 200)
		#next_facing = Vector2.DOWN
		next_facing = deg2rad(90)
		pass
	elif index == 3:
		next_pos = Vector2(400, 50)
		#next_facing = Vector2.RIGHT
		next_facing = deg2rad(90)
	$PathTimer.wait_time = (last_pos - next_pos).length() / speed
	$PathTimer.start()
	$FacingTimer.wait_time = 0.5
	$FacingTimer.start()
