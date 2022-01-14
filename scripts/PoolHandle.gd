extends Node

class_name PoolHandle
var pool : Pool = null setget , get_pool

func _init(pool_name, parent):
	var pool_system : PoolSystem = parent.get_tree().get_nodes_in_group("PoolSystem")[0]
	pool = pool_system.get_pool(pool_name)

func get_pool():
	return pool

