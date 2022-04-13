extends Area2D

export var radius = 32

var colors = [Color.red, Color.blue, Color.green, Color.purple]

var color = Color.red

func _draw():
	#draw_circle(position, radius, color)
	draw_circle_arc(position, radius, 0, 360, color)

func set_mode(mode):
	color = colors[mode]
	update()
	collision_layer = 240 - pow(2, mode + 4)

func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color, 2)
