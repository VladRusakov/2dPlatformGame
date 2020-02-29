extends KinematicBody2D

class_name Player


const GRAVITY_VEC = Vector2(0, 700)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 25.0
const WALK_SPEED = 250 # pixels/sec
const JUMP_SPEED = 600
const SIDING_CHANGE_SPEED = 10
const BULLET_VELOCITY = 1000
const SHOOT_TIME_SHOW_WEAPON = 0.2

var linear_vel = Vector2(0, -0)
var shoot_time = 99999 # time since last shot
var score = 3
var deadline_y = 800

var anim = ""

# cache the sprite here for fast access (we will set scale to flip it often)
onready var sprite = $Sprite
# cache bullet for fast access
var Bullet = preload("res://player/Bullet.tscn")


func _physics_process(delta):
	self.get_node("UI").get_node("Score").text = str(self.score)
	# Increment counters
	if self.position.y > deadline_y:
		die()
	
	shoot_time += delta

	### MOVEMENT ###

	# Apply gravity
	linear_vel += delta * GRAVITY_VEC
	# Move and slide
	linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
	# Detect if we are on floor - only works if called *after* move_and_slide
	var on_floor = is_on_floor()
	### CONTROL ###

	# Horizontal movement
	var target_speed = 0
	if Input.is_action_pressed("move_left"):
		target_speed -= 1
	if Input.is_action_pressed("move_right"):
		target_speed += 1

	target_speed *= WALK_SPEED
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)

	# Jumping
	if on_floor and Input.is_action_just_pressed("jump"):
		linear_vel.y = -JUMP_SPEED
		($SoundJump as AudioStreamPlayer2D).play()

	# Shooting
	if Input.is_action_just_pressed("shoot") and self.score > 0:
		var bullet = Bullet.instance()
		self.score -= 1
		bullet.position = ($Sprite/BulletShoot as Position2D).global_position # use node for shoot position
		bullet.linear_velocity = Vector2(sprite.scale.x * BULLET_VELOCITY, 0)
		bullet.add_collision_exception_with(self) # don't want player to collide with bullet
		get_parent().add_child(bullet) # don't want bullet to move with me, so add it as child of parent
		($SoundShoot as AudioStreamPlayer2D).play()
		shoot_time = 0

	### ANIMATION ###

	var new_anim = "idle"
	
	get_node("CollisionShape2D").disabled = false
	
	if Input.is_action_pressed("move_down"):
			get_node("CollisionShape2D").disabled = true
			linear_vel.y = JUMP_SPEED
			new_anim = "falling"
	
	elif Input.is_action_pressed("jump"):
		get_node("CollisionShape2D").disabled = true
		new_anim = ""

	elif on_floor:
		if linear_vel.x < -SIDING_CHANGE_SPEED:
			sprite.scale.x = -1
			new_anim = "run"

		if linear_vel.x > SIDING_CHANGE_SPEED:
			sprite.scale.x = 1
			new_anim = "run"
	else:
		if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			sprite.scale.x = -1
		if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			sprite.scale.x = 1

	if not on_floor:
		if linear_vel.y < 0:
			new_anim = "jumping"
		else:
			new_anim = "falling"

	if shoot_time < SHOOT_TIME_SHOW_WEAPON:
		new_anim += "_weapon"

	if new_anim != anim:
		anim = new_anim
		($Anim as AnimationPlayer).play(anim)


func die():
	self.position.y = 0
	alert("Your Score is : " + str(self.score) + '\nRestart?', "Game over")
	pass
	
func _on_EnemyCollider_body_entered(body):
	if body is Enemy:
		self.die()

func alert(text: String, title: String='Message') -> void:
	var dialog = AcceptDialog.new()
	dialog.dialog_text = text
	dialog.window_title = title
	dialog.connect('modal_closed', dialog, 'queue_free')
	self.get_node('UI').add_child(dialog)
	dialog.connect("hide", self, '_on_restart')
	get_tree().set_pause(true)
	dialog.popup_centered_minsize()
	dialog.set_pause_mode(Node.PAUSE_MODE_PROCESS)
	
	
func _on_restart():
	get_tree().set_pause(false)
	get_tree().reload_current_scene()
	
