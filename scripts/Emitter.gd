extends Node2D

export var pool_name = ""

export var fire_time = 1.0
var fire_clock = 0
export var enabled = true
export (Vector2) var direction
export var speed = 400

var pool : Pool

func _ready():
	var pool_system : PoolSystem = get_tree().get_nodes_in_group("PoolSystem")[0]
	pool = pool_system.get_pool(pool_name)

func _physics_process(delta):
	if fire_clock > 0:
		fire_clock -= delta
	else:
		fire_clock = fire_time
		if enabled:
			fire()

func fire():
	var ent : Entity = pool.get_entity()
	ent.position = global_position
	ent.rotation = global_rotation
	ent.velocity = direction.normalized() * speed
