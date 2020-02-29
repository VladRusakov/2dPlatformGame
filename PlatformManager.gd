extends Node

# Declare member variables here. Examples:
var default_spawn_x = 1000
var height = 800
onready var parent = get_parent()
var random_generator = RandomNumberGenerator.new()

var MovingPlatform = preload("res://platform/MovingPlatform.tscn")
var Enemy = preload("res://enemy/enemy.tscn")
var Coin = preload("res://coin/coin.tscn")

func _init():
	random_generator.randomize()

func _ready():
	random_generator.randomize()

func generate_platform(x, y) -> MovingPlatform:
		var platform = MovingPlatform.instance()
		platform.position = Vector2(x, y)
		platform.scale.x = random_generator.randf_range(0.5, 1)
		platform.scale.y = random_generator.randf_range(0.5, 1)
		if random_generator.randi_range(0, 2) == 0:
			platform.rotation = random_generator.randf_range(-0.3, 0.3)
		parent.add_child(platform)
		return platform
	
func generate_enemy(x, y):
	var enemy = Enemy.instance()
	enemy.position.x = x
	enemy.position.y = y - 40
	parent.add_child(enemy)
	
func generate_coin(x: float, y: float, platform: MovingPlatform):
	var coin = Coin.instance()
	coin.anchor = platform
	parent.add_child(coin)

func generate_stuff():
	var platforms_count = self.random_generator.randi_range(3, 5)
	var height_part = self.height / platforms_count
	var prev_y = 0
	var part_y = height_part
	for i in range(platforms_count):
		var min_y = min((i+1) * height_part, prev_y)
		var max_y = max((i+1) * height_part, prev_y)
		var spawn_y = self.random_generator.randf_range(prev_y, (i+1) * height_part)
		prev_y = spawn_y + 50
		var spawn_x = self.default_spawn_x + self.random_generator.randi_range(-50, 60)
		
		var platform = self.generate_platform(spawn_x, spawn_y)
		
		if self.random_generator.randi_range(0, 1) == 0:
			self.generate_coin(spawn_x, spawn_y, platform)
			
		if self.random_generator.randi_range(0, 1) == 0:
			self.generate_enemy(spawn_x, spawn_y)
			

func _on_SpawnPlatformTimer_timeout():
	self.generate_stuff()
