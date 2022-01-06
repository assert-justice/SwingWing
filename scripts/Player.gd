extends Node2D

export var speed = 200
export var speed_co = 1.0
export var mode = 0

var controller : Controller
var velocity = Vector2()

func _ready():
	controller = Controller.new("mk")

func _physics_process(delta):
	controller.update(delta)
	velocity = controller.move * speed * delta
	$Emitter.enabled = controller.fire_button > 0
	if $Emitter.enabled:
		velocity *= speed_co
	if controller.spin_button > 0:
		spin()
	print(position)
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

func set_mode(mode):
	self.mode = mode
	$AnimationPlayer.play(str(mode))
	
