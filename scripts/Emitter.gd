extends Node2D

export var pool_name = "bullet"

export var fire_time = 1.0
export var fire_delay = 0.0
var fire_clock = 0
export var enabled = true
export (Vector2) var direction = Vector2.RIGHT
export var speed = 400
export var once = false
export var mode = 0
export var player_flag = -1 # 0: any, 1: 1 player, 2: 2 player
#export var relative = false
var origin = null
var root = null

var pool : Pool

func set_pool(pool_name):
	self.pool_name = pool_name
	var pool_system : PoolSystem = get_tree().get_nodes_in_group("PoolSystem")[0]
	pool = pool_system.get_pool(pool_name)

func enable():
	if player_flag == -1 or player_flag == root.player_count:
		enabled = true
	else:
		enabled = false

func _ready():
	set_pool(pool_name)
	root = get_tree().root.get_child(0)
	if player_flag == -1 or player_flag == root.player_count:
		pass
	else:
		enabled = false
	wake()

func set_origin(origin):
	self.origin = origin

func wake():
	fire_clock = fire_delay

func _physics_process(delta):
	if fire_clock > 0:
		fire_clock -= delta
	else:
		fire_clock = fire_time
		if enabled or once:
			if once:
				enabled = false
				once = false
			fire()

func fire():
	var ent : Entity = pool.get_entity()
	if not ent:
		return
	ent.position = global_position
	ent.rotation = global_rotation
	var facing = direction.rotated(global_rotation)
	ent.velocity = facing.normalized() * speed
	ent.set_origin(origin)
	if ent.has_method("set_mode"):
		ent.set_mode(mode)
	return ent
