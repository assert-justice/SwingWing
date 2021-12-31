extends Node2D

export var pool_name = ""

export var fire_time = 1
var fire_clock = 0
export var enabled = true

var pool : Pool

func _ready():
	var pool_system : PoolSystem = get_tree().get_nodes_in_group("PoolSystem")[0]
	pool = pool_system.get_pool(pool_name)

func _process(delta):
	if not enabled:
		return
	if fire_clock > 0:
		fire_clock -= delta
	else:
		fire_clock = fire_time
		fire()

func fire():
	var ent : Entity = pool.get_entity()
	ent.position = 
