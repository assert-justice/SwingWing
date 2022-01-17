extends Entity

class_name Player

export var speed = 200
export var speed_co = 0.75
export var mode = 0
export var lives = 2
export var invuln_time = 1.0
export var invuln_clock = 0.0
onready var display = get_tree().get_nodes_in_group("Display" + str(mode))[0]
var frame = 1
var chain_length = 0
var best_chain = 0
var score = 0
export var chain_time = 1.0
var chain_clock = 0.0
export var credits = 0
onready var spawn_point = position
var root = null

var controller : Controller

func register(points):
	if points > 0:
		chain_length += 1
		if chain_length > best_chain:
			best_chain = chain_length
	score += chain_length * points
	display_update()
	chain_clock = chain_time

func set_start_position(pos : Vector2):
	position = pos
	spawn_point = position

func die():
	lives = 0
	visible = false
	awake = false
	$Emitter.enabled = false
	display_update()
	root.player_death()

func damage(dam, origin = null):
	if not awake:
		return
	$DieSfx.play()
	$DieVfx.emitting = true
	if invuln_clock > 0:
		return
	chain_length = 0
	invuln_clock = invuln_time
	lives -= 1
	if lives > -1:
		display_update()
		return
	die()

func ressurect():
	position = spawn_point
	$AnimationPlayer.play("enter")
	lives = root.lives
	visible = true
	awake = true
	invuln_clock = invuln_time
	display_update()

func display_update():
	display.text = "Lives: " + str(lives) + "\nCredits: " + str(credits) + "\nScore: " + str(score) + " x" + str(chain_length)

func set_controller(type):
	controller = Controller.new(type)

func _ready():
	#controller = Controller.new("mk")
	set_mode(mode)
	display_update()
	$AnimationPlayer.play("enter")
	$Emitter.set_origin(self)
	root = get_tree().root.get_child(0)
	#Engine.time_scale = 0.3

func _physics_process(delta):
	if not awake:
		return
	var game_credits = root.credits
	if credits != game_credits:
		credits = game_credits
		display_update()
	frame += 1
	if invuln_clock > 0:
		visible = frame % 6 < 3
		invuln_clock -= delta
	else:
		visible = true
	if chain_clock > 0:
		chain_clock -= delta
	else:
		chain_length = 0
		display_update()
	controller.update(delta)
	velocity = controller.move * speed * delta
	$Emitter.enabled = controller.fire_button > 0
	if $Emitter.enabled:
		if not $ShootSfx.playing:
			$ShootSfx.play()
		velocity *= speed_co
	if controller.spin_button > 0:
		spin()
	translate(velocity)
	if position.x < 0:
		position.x = 0
	if position.y < 0:
		position.y = 0
	if position.x > 480:
		position.x = 480
	if position.y > 272:
		position.y = 272

func spin():
	if mode == 0:
		set_mode(1)
	elif mode == 1:
		set_mode(0)
	elif mode == 2:
		set_mode(3)
	else:
		set_mode(2)

func set_mode(mode, quick = false):
	self.mode = mode
	var colors = [Color(1, 0, 0), Color(0, 0, 1), Color(0, 1, 0), Color(0.8, 0, 1)]
	$DieVfx.color = colors[mode]
	if quick:
		$AnimatedSprite.frame = mode
	else:
		$AnimationPlayer.play(str(mode))
	$AnimatedSprite/Area2D.collision_layer = 15 - pow(2, mode)
	$Emitter.mode = mode
