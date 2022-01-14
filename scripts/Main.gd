extends Node

export (PackedScene) var game_scene
export (PackedScene) var player_scene

var speed_options = []
var control_options = []
var speed = "Normal"
var p1_controls = "mk"
var p2_controls = "none"
var game = null
export var credits = 3
var players = []
var dead_players = 0
export (int) var player_count setget , pc

func pc():
	return len(players)

func _ready():
	speed_options = ["Slow", "Normal", "Fast"]
	control_options = ["none", "mk", "joy0", "joy1"]
	for op in speed_options:
		$Menu/Main/GameSpeed.add_item(op)
	for c in range(0, 6):
		$Menu/Main/Credits.add_item(str(c))
	#$Menu/Main/GameSpeed.select(1)
	for op in control_options:
		$Menu/Main/P1Controls.add_item(op)
	for op in control_options:
		$Menu/Main/P2Controls.add_item(op)
	for c in get_children():
		c.pause_mode = PAUSE_MODE_PROCESS
	main_menu()
	
func _process(delta):
	if Input.is_action_just_pressed("pause") and game:
		pause_toggle()

func player_death():
	dead_players += 1
	print("got here")
	if dead_players >= len(players):
		print(len(players))
		dead_players = 0
		credits -= 1
		if credits < 0:
			pass
			# game over
			game_over()
		else:
			for player in players:
				player.ressurect()
func pause_toggle():
	if $Menu/GameOver.visible:
		return
	var paused = not get_tree().paused
	get_tree().paused = paused
	$Menu/Pause.visible = paused
	if paused:
		$Menu/Pause/Resume.grab_focus()

func hide_menus():
	for child in $Menu.get_children():
		if child != game:
			child.visible = false

func main_menu():
	hide_menus()
	get_tree().paused = false
	$Menu/Main.visible = true
	$Menu/Main/Launch.grab_focus()
	if game:
		game.queue_free()
		game = null
	$Menu/Main/GameSpeed.select(speed_options.find(speed))
	$Menu/Main/Credits.select(credits)
	$Menu/Main/P1Controls.select(control_options.find(p1_controls))
	$Menu/Main/P2Controls.select(control_options.find(p2_controls))

func game_over():
	#get_tree().paused = true
	#game.queue_free()
	#print("got here")
	hide_menus()
	$Menu/GameOver.visible = true
	$Menu/GameOver/Main.grab_focus()

func launch():
	var speed_lookup = {
		"Slow": 0.5,
		"Normal": 1.0,
		"Fast": 1.5
	}
	speed = speed_options[$Menu/Main/GameSpeed.selected]
	credits = $Menu/Main/Credits.selected
	p1_controls = control_options[$Menu/Main/P1Controls.selected]
	p2_controls = control_options[$Menu/Main/P2Controls.selected]
	Engine.time_scale = speed_lookup[speed]
	players = []
	if p1_controls != "none":
		var p1 : Player = player_scene.instance()
		p1.controller = p1_controls
		players.append(p1)
	if p2_controls != "none":
		var p2 : Player = player_scene.instance()
		p2.controller = p2_controls
		p2.set_mode(2)
		players.append(p2)
	if len(players) == 0:
		return
	players[0].set_controller(p1_controls)
	if len(players) == 1:
		players[0].set_start_position(Vector2(245, 257))
	else:
		players[1].set_controller(p2_controls)
		players[0].set_start_position(Vector2(145, 257))
		players[1].set_start_position(Vector2(345, 257))
	if game:
		game.queue_free()
		game = null
	game = game_scene.instance()
	add_child(game)
	for player in players:
		game.add_child(player)
		player.set_mode(player.mode, true)
	hide_menus()

func _on_Quit_button_up():
	get_tree().quit()

func _on_Main_button_up():
	main_menu()


func _on_Launch_button_up():
	launch()

func _on_Resume_button_up():
	pause_toggle()
