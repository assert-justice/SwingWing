extends Node

class_name PoolSystem

export (PackedScene) var bullet_scene
export (PackedScene) var enemy_bullet_scene
export (PackedScene) var enemy_basic_scene
export (PackedScene) var enemy_flanker_scene
export (PackedScene) var enemy_wheel_scene
export (PackedScene) var enemy_box_scene
export (PackedScene) var enemy_mine_scene
export (PackedScene) var enemy_miniboss_scene
export (PackedScene) var enemy_boss_scene

var pools : Dictionary

func _ready():
	pools = {
		"bullet" : Pool.new(bullet_scene),
		"enemy_bullet" : Pool.new(enemy_bullet_scene),
		"enemy_basic" : Pool.new(enemy_basic_scene),
		"enemy_flanker" : Pool.new(enemy_flanker_scene),
		"enemy_wheel" : Pool.new(enemy_wheel_scene),
		"enemy_box" : Pool.new(enemy_box_scene),
		"enemy_mine" : Pool.new(enemy_mine_scene),
		"enemy_miniboss" : Pool.new(enemy_miniboss_scene),
		"enemy_boss" : Pool.new(enemy_boss_scene),
	}
	pools["enemy_wheel"].max_size = 2
	pools["enemy_box"].max_size = 1
	pools["enemy_miniboss"].max_size = 1
	pools["enemy_basic"].max_size = 8
	pools["enemy_mine"].max_size = 8
	for pool in pools:
		add_child(pools[pool])
	#pools["enemy_bullet"].debug = true

func get_pool(pool_name):
	return pools[pool_name]
