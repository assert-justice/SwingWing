extends Node

export (PackedScene) var game_scene
export (PackedScene) var player_scene

var speed_options = []
var control_options = []
var jam_options = []
var speed = "Normal"
var p1_controls = "mk"
var p2_controls = "none"
var game = null
export var credits = 2
export var lives = 2
var jam_idx = 0
var players = []
var dead_players = 0
export (int) var player_count setget , pc

func pc():
	return len(players)

func _ready():
	randomize()
	speed_options = ["Slow", "Normal", "Fast"]
	control_options = ["none", "mk", "joy0", "joy1"]
	jam_options = ["Random", "Disco Void", "Glimmers", "None"]
	for op in speed_options:
		$Menu/Difficulty/GameSpeed.add_item(op)
	for c in range(0, 6):
		$Menu/Difficulty/Credits.add_item(str(c))
	for c in range(0, 6):
		$Menu/Difficulty/Lives.add_item(str(c))
	for op in control_options:
		$Menu/Main/P1Controls.add_item(op)
	for op in control_options:
		$Menu/Main/P2Controls.add_item(op)
	for op in jam_options:
		$Menu/Main/Jams.add_item(op)
	$Menu/Difficulty/GameSpeed.select(speed_options.find(speed))
	$Menu/Difficulty/Credits.select(credits)
	$Menu/Difficulty/Lives.select(lives)
	for c in get_children():
		c.pause_mode = PAUSE_MODE_PROCESS
	main_menu()
	
func _process(delta):
	if Input.is_action_just_pressed("pause") and game:
		pause_toggle()

func player_death():
	dead_players += 1
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
	$Menu/Main/P1Controls.select(control_options.find(p1_controls))
	$Menu/Main/P2Controls.select(control_options.find(p2_controls))
	$Menu/Main/Jams.select(jam_idx)
func game_over():
	hide_menus()
	$Menu/GameOver.visible = true
	$Menu/GameOver/Main.grab_focus()
	var best = load_int("score")
	var best_combo = load_int("combo")
	var beat_score = false
	var beat_combo = false
	var current_best = 0
	var current_best_combo = 0
	for player in players:
		if player.score > current_best:
			current_best = player.score
		if player.best_chain > current_best_combo:
			current_best_combo = player.best_chain
	if current_best > best:
		beat_score = true
		best = current_best
		save_int(best, "score")
	if current_best_combo > best_combo:
		beat_combo = true
		best_combo = current_best_combo
		save_int(best_combo, "combo")
	var idx = 1
	var display = $Menu/GameOver/RichTextLabel
	display.text = "\t\tGame Over"
	for player in players:
		display.text += "\nPlayer " + str(idx) + " Score: " + str(player.score)
		if player.score == best:
			display.text += "\nNew Best Score!"
		display.text += "\nPlayer " + str(idx) + " Max Combo: " + str(player.best_chain)
		if player.best_chain == best_combo:
			display.text += "\nNew Best Combo!"
		if idx != len(players):
			display.text += "\n"
		idx += 1
	if not beat_score:
		display.text += "\nBest Score: " + str(best)
	if not beat_combo:
		display.text += "\nBest Max Combo: " + str(best_combo)

func save_int(val, file, path = "res"):
	var save_path = path + "://" + file + ".json"
	var save_file = File.new()
	save_file.open(save_path, File.WRITE)
	save_file.store_64(val)
	save_file.close()

func load_int(file, empty = 0, path = "res"):
	var save_path = path + "://" + file + ".json"
	var save_file = File.new()
	if not save_file.file_exists(save_path):
		return empty
	save_file.open(save_path, File.READ)
	var val = save_file.get_64()
	save_file.close()
	return val

func launch():
	var speed_lookup = {
		"Slow": 0.5,
		"Normal": 1.0,
		"Fast": 1.5
	}
	speed = speed_options[$Menu/Difficulty/GameSpeed.selected]
	credits = $Menu/Difficulty/Credits.selected
	lives = $Menu/Difficulty/Lives.selected
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
	jam_idx = $Menu/Main/Jams.selected
	var music_players = get_tree().get_nodes_in_group("Music")
	var temp_jam
	if jam_idx != 3:
		if jam_idx == 0:
			var temp = randf() * 2
			temp_jam = floor(temp)
		else:
			temp_jam = jam_idx - 1
		music_players[temp_jam].play()
	for player in players:
		game.add_child(player)
		player.set_mode(player.mode, true)
		player.lives = lives
	hide_menus()

func _on_Quit_button_up():
	get_tree().quit()

func _on_Main_button_up():
	main_menu()


func _on_Launch_button_up():
	launch()

func _on_Resume_button_up():
	pause_toggle()


func _on_Difficulty_button_up():
	hide_menus()
	$Menu/Difficulty.visible = true
	$Menu/Difficulty/Main.grab_focus()
	$Menu/Difficulty/GameSpeed.select(speed_options.find(speed))
	$Menu/Difficulty/Credits.select(credits)
	$Menu/Difficulty/Lives.select(lives)
	p1_controls = control_options[$Menu/Main/P1Controls.selected]
	p2_controls = control_options[$Menu/Main/P2Controls.selected]
	jam_idx = $Menu/Main/Jams.selected


func _on_Reset_Scores_button_up():
	save_int(0, "score")
	save_int(0, "combo")
