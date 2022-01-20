extends Node2D

var index = -1

var interps = []
var audio_player: AudioStreamPlayer = null

func _ready():
	inc()

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

func inc():
	index += 1
	interps = []
	if index == 0:
		interps.append([$RedEmitter, Vector2($RedEmitter.position), Vector2($BlueEmitter.position)])
		interps.append([$BlueEmitter, Vector2($BlueEmitter.position), Vector2($RedEmitter.position)])
		interps.append([$GreenEmitter, Vector2($GreenEmitter.position), Vector2($BlueEmitter.position)])
		interps.append([$PurpleEmitter, Vector2($PurpleEmitter.position), Vector2($RedEmitter.position)])
		$Timer.wait_time = 16
	elif index == 1:
		$RedEmitter.fire_time = 1.5
		$BlueEmitter.fire_time = 1.5
		$GreenEmitter.fire_time = 1.5
		$PurpleEmitter.fire_time = 1.5
		$Timer.wait_time = 16
	elif index == 2:
		$RedEmitter.fire_time = 4
		$RedEmitter.position = Vector2.ZERO
		$RedEmitter.set_pool("enemy_flanker")
		$RedEmitter.fire_delay = 0
		$RedEmitter.wake()
		$BlueEmitter.fire_time = 4
		$BlueEmitter.set_pool("enemy_flanker")
		$BlueEmitter.fire_delay = 2
		$BlueEmitter.wake()
		$GreenEmitter.fire_time = 4
		$GreenEmitter.position = Vector2.ZERO
		$GreenEmitter.set_pool("enemy_flanker")
		$GreenEmitter.fire_delay = 1
		$GreenEmitter.wake()
		$PurpleEmitter.fire_time = 4
		$PurpleEmitter.set_pool("enemy_flanker")
		$PurpleEmitter.fire_delay = 3
		$PurpleEmitter.wake()
		$Timer.wait_time = 30
	elif index == 3:
		index = 2
		var ems = [$RedEmitter, $BlueEmitter, $GreenEmitter, $PurpleEmitter]
		for em in ems:
			em.fire_time = randf() * 2 + 1
			em.fire_delay = randf() * em.fire_time
			var type = floor(randf() * 2)
			if type == 0:
				em.set_pool("enemy_basic")
				var switch = randf() < 0.5
				if switch:
					if em.position.x < 100:
						interps.append([em, Vector2(em.position), Vector2(233, 0)])
					else:
						interps.append([em, Vector2(em.position), Vector2(0, 0)])
			else:
				em.set_pool("enemy_flanker")
		$Timer.wait_time = randf() * 20 + 10
	$Timer.start()
	

func _on_Timer_timeout():
	inc()
