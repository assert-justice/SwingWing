extends Entity

func _ready():
	$AnimationPlayer.play("Move")

func damage(dam):
	.damage(dam)
	print("enemy damaged")
