extends Node2D

var index = -1

var interps = []
var emitters = []
var audio_player: AudioStreamPlayer = null
var player_count

func _ready():
	pass
	#inc()
	for em in $Emitters.get_children():
		emitters.push_back(em)
	player_count = get_tree().root.get_child(0).player_count

func _process(delta):
	for interp in interps:
		interp[0].position = lerp(interp[1], interp[2], 1.0 - $Timer.time_left / $Timer.wait_time)
	if not audio_player:
		var aplayers = get_tree().get_nodes_in_group("Music")
		for ap in aplayers:
			if ap.playing:
				audio_player = ap
	if audio_player and not audio_player.playing:
		 audio_player.play()

func help(em, mode, pool, x = 0, delay = 0, time = 3):
	em.enable()
	em.position.x = x
	em.set_mode(mode)
	em.set_pool(pool)
	em.set_delay(delay)
	em.fire_time = time

func inc():
	index += 1
	interps = []
	var lx = 100
	var hx = 233
	for em in emitters:
		em.enabled = false
	$Timer.wait_time = 16
	if index == 0:
		# gentle intro
		help(emitters[0], 0, "enemy_basic", 170)
		help(emitters[1], 1, "enemy_basic", 170, 1.5)
		if player_count == 2:
			help(emitters[2], 2, "enemy_basic",  170, 0.7)
		pass
	elif index == 1:
		# ramp up with flankers
		help(emitters[0], 0, "enemy_flanker")
		help(emitters[1], 1, "enemy_flanker", 0, 1.5)
		if player_count == 2:
			help(emitters[3], 3, "enemy_flanker",  170, 0.7)
		pass
	elif index == 2:
		# ace enemy
		help(emitters[0], 0, "enemy_wheel", 0, 0, 5)
		#help(emitters[1], 1, "enemy_flanker", 170, 1.5)
		if player_count == 2:
			help(emitters[2], 2, "enemy_wheel",  0, 0.15, 5)
		pass
	elif index == 3:
		# boxes!
		var first = randi()%2
		help(emitters[0], first, "enemy_box", 0, 0, 9)
		help(emitters[1], 1-first, "enemy_box", 0, 2.5, 9)
		if player_count == 2:
			help(emitters[2], randi()%2 + 2, "enemy_box",0,0,9)
		pass
	elif index == 4:
		$Timer.wait_time = 5
		pass
	elif index == 5:
		# the miniboss
		help(emitters[0], 0, "enemy_miniboss")
		if player_count == 2:
			help(emitters[0], randi()%2 + 2, "enemy_miniboss",0,0,5)
		pass
		pass
	elif index == 6:
		# random onslaught
		index = 5
		var probs = ["basic","basic","basic","flanker","flanker","wheel","box","miniboss"]
		var modes = [0,1]
		if player_count == 2:
			modes = [[0,1,2],[0,1,3],[0,2,3],[1,2,3]][randi()%4]
		for m in modes:
			var enem = "enemy_" + probs[randi()%8]
			var x = 0
			var time = 3
			if enem == "enemy_basic":
				x += rand_range(0, 233)
			elif enem == "enemy_wheel":
				time = 7
			elif enem == "enemy_box":
				time = 5
			elif enem == "enemy_miniboss":
				time = 10
			help(emitters[m], m, enem, x, rand_range(0, time/2), time)
		$Timer.wait_time = rand_range(5, 20)
		pass
	$Timer.start()
	

func _on_Timer_timeout():
	inc()
