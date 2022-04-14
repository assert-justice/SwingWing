extends EnemyBase

var players = []

func wake():
	.wake()
	players = get_tree().get_nodes_in_group("Player")
	set_emitter_enabled(false)
	var pos = position
	print(pos)
	position = Vector2.ZERO
	$Body.position = pos

func _physics_process(delta):
	._physics_process(delta)
	for p in players:
		if (p.position - $Body.global_position).length() < 60:
			#set_emitter_enabled(true)
			#sleep()
			#set_emitter_enabled(true)
			damage(1, self)

func damage(dam, damage_origin):
	if not alive:
		return false
	sleep()
	var pool_system : PoolSystem = get_tree().get_nodes_in_group("PoolSystem")[0]
	var pool : Pool = pool_system.get_pool("enemy_bullet")
	var dirs = [Vector2.LEFT, Vector2.UP, Vector2.RIGHT, Vector2.DOWN]
	for dir in dirs:
		var ent = pool.get_entity()
		ent.velocity = dir * 150
		ent.position = $Body.global_position
		ent.set_mode(mode)

func path_update(index = null):
	var min_y = 0
	var max_y = 200
	last_pos = $Body.position
	next_pos = Vector2($Body.position.x, rand_range(min_y, max_y))
	$PathTimer.wait_time = (last_pos - next_pos).length() / speed
	$PathTimer.start()
