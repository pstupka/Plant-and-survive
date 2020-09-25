extends Node2D

var _player = preload("res://src/Actors/Player.tscn")
var _enemy = preload("res://src/Actors/EnemyBee.tscn")
var _item_crate = preload("res://src/Items/Crate.tscn")

var player
var crates_collected = 0
var plants01_collected = 0

var level = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$HUD.hide()

func new_game():
	randomize()
	level = 1
	player = _player.instance()
	player.position = $StartPosition.position
	add_child(player)
	player.connect("died", self, "_on_Player_died")
	player.connect("health_changed", $HUD, "_on_Player_health_changed")
	$HUD.show()
	spawn_enemy()
	
	spawn_items(10)

# Function to spawn items inthe world
func spawn_items(count):
	for i in 10:
		var item = _item_crate.instance()
		item.position = Vector2(i*100,80)
		add_child(item)
		item.connect("picked", self, "_on_item_picked", [item])
		
	# Auto generated items
	var items = get_tree().get_nodes_in_group("items")
	for item in items:
		item.connect("picked", self, "_on_item_picked", [item])

func spawn_enemy():
	var enemy = _enemy.instance()
	enemy.position = $StartPosition.position
	enemy.position.x += 200
	add_child(enemy)

func _on_Player_died():
	$HUD.hide()
	$Scenes.game_over();

func _on_item_picked(item):
	match item.type:
		"crate":
			crates_collected += 1
			$HUD/CratesLabel.text = "x  %d" % [crates_collected]
		"plant01":
			plants01_collected += 1
			$HUD/Plant01Label.text = "x  %d" % [plants01_collected]
