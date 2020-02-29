extends Node2D

class_name MovingPlatform

onready var sprite = $Sprite
# Member variables

func _physics_process(delta):
	
	if (self.position.x) > -400:
		self.position.x -= 2
	else:
		self.queue_free()
