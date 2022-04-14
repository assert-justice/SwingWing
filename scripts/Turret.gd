extends Emitter

func set_mode(mode):
	self.mode = mode
	$AnimatedSprite.frame = mode
