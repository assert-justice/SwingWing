extends Node

export (PackedScene) var game_scene
export (PackedScene) var player_scene
var speed_options = ["Slow (no points)", "Normal", "Fast (points x 1.5)"]
#control_options = ["none", "wasd", "ijkl", "joy0", "joy1"]
var control_options = ["none", "wasd", "arrow", "joy0", "joy1"]
var jam_options = ["Random", "Disco Void", "Glimmers", "Together", "None"]
var game = null
var players = []
var dead_players = 0
export (int) var player_count setget , pc
var focus_queued = null
var settings = {}
var player_entry = null
var player_rating = 0

onready var bindings = {
	"speed": [1, $Menu/Difficulty/GameSpeed],
	"p1_controls": [1, $Menu/Main/P1Controls],
	"p2_controls": [0, $Menu/Main/P2Controls],
	"credits": [2, $Menu/Difficulty/Credits],
	"lives": [2, $Menu/Difficulty/Lives],
	"jam_idx": [0, $Menu/Main/Jams],
	"best_score": [0, null],
	"best_combo": [0, null],
	"name": ["AAA", null],
	"last_score": [0, null]
}

var leaderboard = []

func pc():
	return len(players)

func load_settings():
	settings = load_json("data")
	for key in bindings:
		var default = bindings[key][0]
		var binding = bindings[key][1]
		if not key in settings:
			settings[key] = default
		if binding != null:
			var setting = settings[key]
			binding.select(setting)

func save_settings():
	for key in bindings:
		var binding = bindings[key][1]
		if binding:
			settings[key] = binding.selected
	save_json(settings, "data")

func _ready():
	randomize()
	for op in speed_options:
		$Menu/Difficulty/GameSpeed.add_item(op)
	for c in range(0, 6):
		var text = str(c)
		if c > 2:
			text += " (no points)"
		$Menu/Difficulty/Credits.add_item(text)
	for c in range(0, 6):
		var text = str(c)
		if c > 3:
			text += " (no points)"
		$Menu/Difficulty/Lives.add_item(text)
	for op in control_options:
		$Menu/Main/P1Controls.add_item(op)
	for op in control_options:
		$Menu/Main/P2Controls.add_item(op)
	for op in jam_options:
		$Menu/Main/Jams.add_item(op)
	load_settings()
	for c in get_children():
		c.pause_mode = PAUSE_MODE_PROCESS
	main_menu()
	
func _process(delta):
	if Input.is_action_just_pressed("pause") and game:
		pause_toggle()
	if focus_queued and not Input.is_action_pressed("ui_accept"):
		focus_queued.grab_focus()
		focus_queued = null
	if $Menu/GameOver.visible and player_entry:
		pass

func player_death():
	dead_players += 1
	if dead_players >= len(players):
		dead_players = 0
		settings["credits"] -= 1
		if settings["credits"] < 0:
			game_over()
		else:
			for player in players:
				player.ressurect()

func focus(elem):
	if Input.is_action_pressed("ui_accept"):
		focus_queued = elem
	else:
		elem.grab_focus()

func pause_toggle():
	if $Menu/GameOver.visible:
		return
	var paused = not get_tree().paused
	get_tree().paused = paused
	$Menu/Pause.visible = paused
	if paused:
		focus($Menu/Pause/Resume)
		#.grab_focus()

func hide_menus():
	for child in $Menu.get_children():
		if child != game:
			child.visible = false

func main_menu():
	hide_menus()
	get_tree().paused = false
	$Menu/Main.visible = true
	focus($Menu/Main/Launch)
	if game:
		game.queue_free()
		game = null

func game_over():
	hide_menus()
	$Menu/GameOver.visible = true
	focus($Menu/GameOver/Submit)
	var best = settings["best_score"]
	var best_combo = settings["best_combo"]
	var beat_score = false
	var beat_combo = false
	var current_best = 0
	var current_best_combo = 0
	var new_best = false
	for player in players:
		if player.score > current_best:
			current_best = player.score
		if player.best_chain > current_best_combo:
			current_best_combo = player.best_chain
	settings["last_score"] = current_best
	if current_best > best:
		beat_score = true
		best = current_best
		settings["best_score"] = best
	if current_best_combo > best_combo:
		beat_combo = true
		best_combo = current_best_combo
		settings["best_combo"] = best_combo
	save_settings()
	var idx = 1
	var display = $Menu/GameOver/Summary
	text_clear(display)
	for player in players:
		text_append(display, "P" + str(idx) + " Score: " + str(player.score))
		idx += 1
	$Menu/GameOver/Submit.disabled = true
	$Menu/GameOver/Submit.visible = false
	$Menu/GameOver/Buttons.visible = false
	text_clear($Menu/GameOver/Leaderboard)
	for node in get_tree().get_nodes_in_group("UI"):
		node.visible = false
	if settings["speed"] > 0 and settings["lives"] < 3 and settings["credits"] < 3:
		text_append($Menu/GameOver/Leaderboard, "LOADING...")
		$NetworkManager.load_leaderboard()
		$Menu/GameOver/Buttons.visible = true
		$Menu/GameOver/Submit.visible = true
	#set_leaderboard()

func text_append(parent, line):
	var rich = RichTextLabel.new()
	rich.bbcode_enabled = true
	text_set(rich, line)
	rich.fit_content_height = true
	parent.add_child(rich)
	return rich

func text_set(label, line):
	var text = "[code]" + line + "[/code]"
	label.bbcode_text = text

func text_clear(parent):
	for c in parent.get_children():
		c.queue_free()

func load_json(file, empty = {}, path = "res"):
	var save_path = path + "://" + file + ".json"
	var save_file = File.new()
	if not save_file.file_exists(save_path):
		return empty
	save_file.open(save_path, File.READ)
	var val = parse_json(save_file.get_as_text())
	save_file.close()
	return val

func save_json(data, file, path = "res"):
	var save_path = path + "://" + file + ".json"
	var save_file = File.new()
	save_file.open(save_path, File.WRITE)
	save_file.store_line(to_json(data))
	save_file.close()

func get_credits():
	return settings["credits"]

func get_lives():
	return settings["lives"]

func launch():
	save_settings()
	$Menu/Main/P1Controls.selected
	Engine.time_scale = [0.5, 1.0, 1.5][settings["speed"]]
	players = []
	if settings["p1_controls"] != 0:
		var p1 : Player = player_scene.instance()
		#p1.controller = settings["p1_controls"]
		p1.controller = control_options[settings["p1_controls"]]
		players.append(p1)
	if settings["p2_controls"] != 0:
		var p2 : Player = player_scene.instance()
		#p2.controller = settings["p2_controls"]
		p2.set_mode(2)
		players.append(p2)
	if len(players) == 0:
		return
	players[0].set_controller(control_options[settings["p1_controls"]])
	if len(players) == 1:
		players[0].set_start_position(Vector2(245, 257))
	else:
		players[1].set_controller(control_options[settings["p2_controls"]])
		players[0].set_start_position(Vector2(145, 257))
		players[1].set_start_position(Vector2(345, 257))
	if game:
		game.queue_free()
		game = null
	game = game_scene.instance()
	add_child(game)
	#jam_idx = $Menu/Main/Jams.selected
	var music_players = get_tree().get_nodes_in_group("Music")
	var temp_jam
	if settings["jam_idx"] < len(jam_options) - 1:
		if settings["jam_idx"] == 0:
			var temp = randf() * len(music_players)
			temp_jam = floor(temp)
		else:
			temp_jam = settings["jam_idx"] - 1
		music_players[temp_jam].play()
	for player in players:
		game.add_child(player)
		player.set_mode(player.mode, true)
		if settings["speed"] == 2:
			player.point_multiplier = 1.5
		player.lives = settings["lives"]
	hide_menus()

func _on_Quit_button_up():
	save_settings()
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
	focus($Menu/Difficulty/Main)

func _on_Reset_Scores_button_up():
	settings["best_score"] = 0
	settings["best_combo"] = 0
	save_settings()

func _on_NetworkManager_get_completed(data):
	leaderboard = data
	set_leaderboard()

func _on_Leaderboard_button_up():
	hide_menus()
	$Menu/Leaderboard.visible = true
	focus($Menu/Leaderboard)
	$NetworkManager.load_leaderboard()

func set_leaderboard():
	if $Menu/Leaderboard.visible:
		focus($Menu/Leaderboard/Refresh)
		text_clear($Menu/Leaderboard/Container)
		var rank = 1
		for entry in leaderboard:
			var text = "  \t#%s\t%s\t%s" % [rank, entry["name"], entry["score"]]
			text_append($Menu/Leaderboard/Container, text)
			rank += 1
			if rank > 5:
				break
	elif $Menu/GameOver.visible:
		$Menu/GameOver/Submit.disabled = false
		text_clear($Menu/GameOver/Leaderboard)
		var last_score = settings["last_score"]
		# REMOVE, for debugging
		#leaderboard = [
			#{"name":"AAG", "score":40},
			#{"name":"AAF", "score":30},
			#{"name":"AAE", "score":20},
			#{"name":"AAD", "score":20},
			#{"name":"AAC", "score":10},
			#{"name":"AAB", "score":0}
		#]
		#last_score = 25
		var window = 5
		if len(players):
			window = 4
		var score_idx = 0 # index where new entry should be
		for i in range(len(leaderboard)):
			if leaderboard[i]["score"] < last_score:
				break
			score_idx += 1
		var start = score_idx - window / 2 # clamp(score_idx - window / 2, 0, len(leaderboard) - window)
		if start > len(leaderboard) - window + 1:
			start = len(leaderboard) - window + 1
		if start < 0:
			start = 0
		start = int(start)
		var i = 0
		var adj = 0
		while i < window:
			var idx = i + start
			var name = ""
			var score = 0
			if idx == score_idx:
				name = settings["name"]
				score = last_score
				adj = -1
				var text = "<\t#%s\t%s\t%s" % [idx + 1, name, score]
				player_entry = text_append($Menu/GameOver/Leaderboard, text)
			else:
				if idx + adj >= len(leaderboard):
					break
				name = leaderboard[idx + adj]["name"]
				score = leaderboard[idx + adj]["score"]
				player_rating = idx + 1
				var text = "  \t#%s\t%s\t%s" % [idx + 1, name, score]
				text_append($Menu/GameOver/Leaderboard, text)
			#var text = ">" + "#" + str(idx + 1) + " " + name + " " + str(score)
			i += 1
	else:
		# unreachable
		pass

func name_edit(place, dir):
	var name = settings["name"]
	var alpha = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	var code = alpha.find(name[place]) + dir
	if code < 0:
		code += 26
	elif code > 25:
		code -= 26
	var new_name = ""
	for i in len(name):
		if i == place:
			new_name += alpha[code]
		else:
			new_name += name[i]
	settings["name"] = new_name
	save_settings()
	if player_entry:
		text_set(player_entry, "<\t#%s\t%s\t%s" % [player_rating, new_name, settings["last_score"]])

func _on_Submit_button_down():
	$NetworkManager.post_score(settings["name"], settings["last_score"])
	main_menu()

func _on_tb1_button_down():
	name_edit(0, -1)

func _on_tb2_button_down():
	name_edit(1, -1)

func _on_tb3_button_down():
	name_edit(2, -1)

func _on_bb1_button_down():
	name_edit(0, 1)

func _on_bb2_button_down():
	name_edit(1, 1)

func _on_bb3_button_down():
	name_edit(2, 1)


func _on_Refresh_button_down():
	$NetworkManager.load_leaderboard()
