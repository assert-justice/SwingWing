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

var pool : Pool

func _ready():
	var pool_system : PoolSystem = get_tree().get_nodes_in_group("PoolSystem")[0]
	pool = pool_system.get_pool(pool_name)
	wake()

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
	ent.position = global_position
	ent.rotation = global_rotation
	ent.velocity = direction.normalized() * speed
	if ent.has_method("set_mode"):
		ent.set_mode(mode)
