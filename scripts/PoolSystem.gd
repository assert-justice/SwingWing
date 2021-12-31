extends Node

class_name PoolSystem

export (PackedScene) var bullet_scene
export (PackedScene) var enemy_basic_scene
export (PackedScene) var enemy_flanker_scene
export (PackedScene) var enemy_miniboss_scene
export (PackedScene) var enemy_boss_scene

var pools : Dictionary

func _ready():
	pools = {
		"bullet" : Pool.new(bullet_scene),
		"enemy_basic" : Pool.new(enemy_basic_scene),
		"enemy_flanker" : Pool.new(enemy_flanker_scene),
		"enemy_miniboss" : Pool.new(enemy_miniboss_scene),
		"enemy_boss" : Pool.new(enemy_boss_scene),
	}

func get_pool(pool_name):
	return pools[pool_name]
