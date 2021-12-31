extends Node

class_name Pool

var scene : PackedScene

var active : Array
var inactive : Array

func _init(scene):
	self.scene = scene
	active = []
	inactive = []

func new_ent():
	var ent : Entity = scene.instance()
	get_tree().root.add_child(ent)
	return ent

func get_entity():
	var ent : Entity
	if len(inactive) > 0:
		ent = inactive.pop_back()
	else:
		ent = new_ent()
	active.push_back(ent)
	ent.wake()

func sleep(ent):
	active.erase(ent)
	inactive.push_back(ent)
