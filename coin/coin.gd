extends Area2D

class_name Coin
var anchor = null
var taken = false

func _process(delta):
	if self.position.x < -100:
		self.queue_free()
	if self.anchor != null and self.position != null:
		self.position = self.anchor.position + Vector2(0, -30)

func _on_coin_body_enter(body):
	if not taken and body is Player:
		var player = (body as Player)
		($Anim as AnimationPlayer).play("taken")
		taken = true
		player.score += 1
