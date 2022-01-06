extends Node

class_name Controller

export (Vector2) var move

export var fire_button = 0
export var spin_button = 0

export (String) var input_name

func _init(input_name):
	self.input_name = input_name

func ip(string):
	return input_name + "_" + string

func update(delta):
	if Input.is_action_pressed(ip("fire")):
		fire_button += delta
	else:
		fire_button = 0
	if Input.is_action_just_pressed(ip("spin")):
		spin_button += delta
	else:
		spin_button = 0
	var move_vec = Input.get_vector(ip("left"), ip("right"), ip("up"), ip("down"))
	move = move_vec
