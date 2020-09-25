extends Node2D

var _player = preload("res://src/Actors/Player.tscn")
var _enemy = preload("res://src/Actors/EnemyBee.tscn")

var player
var highscore = 0

var level = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$HUD.hide()

func new_game():
	level = 1
	player = _player.instance()
	player.position = $StartPosition.position
	add_child(player)
	player.connect("died", self, "_on_Player_died")
	player.connect("health_changed", $HUD, "_on_Player_health_changed")
	$HUD.show()
	spawn_enemy()

func spawn_enemy():
	var enemy = _enemy.instance()
	enemy.position = $StartPosition.position
	enemy.position.x += 200
	add_child(enemy)

func _on_Player_died():
	$HUD.hide()
	$Scenes.game_over();
