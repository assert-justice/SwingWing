extends Node

class_name Pool

var scene : PackedScene

var active : Array
var inactive : Array
export var debug = false
export var max_size = -1

func _init(scene):
	self.scene = scene
	active = []
	inactive = []

func new_ent():
	var ent : Entity = scene.instance()
	get_tree().get_nodes_in_group("Game")[0].add_child(ent)
	#get_tree().root.add_child(ent)
	return ent

func get_entity():
	var ent : Entity
	if len(inactive) > 0:
		ent = inactive.pop_back()
	elif max_size != -1 and len(active) >= max_size:
		# reuse oldest?
		#ent = active.pop_front()
		return null
	else:
		ent = new_ent()
		ent.set_pool(self)
	active.push_back(ent)
	ent.wake()
	if debug:
		print(len(active), " ", len(inactive))
	return ent

func sleep(ent):
	if ent in active:
		active.erase(ent)
		inactive.push_back(ent)
