extends Node2D

signal start_game

var current_screen

func _ready():
	register_buttons()
	change_screen($TitleScreen)

func _on_button_pressed(button):
	match button.name:
		"Play":
			change_screen(null)
			yield(get_tree().create_timer(0.5), "timeout")
			emit_signal("start_game")
		"MainMenu":
			get_tree().reload_current_scene()
		"Credits":
			change_screen($CreditsScreen)
			yield(get_tree().create_timer(0.5), "timeout")

func register_buttons():
	var buttons = get_tree().get_nodes_in_group("buttons")
	for button in buttons:
		button.connect("pressed", self, "_on_button_pressed", [button])

func change_screen(new_screen):
	if current_screen:
		current_screen.disappear()
		yield(current_screen.tween, "tween_completed")
	current_screen = new_screen
	if new_screen:
		current_screen.appear()
		yield(current_screen.tween, "tween_completed")

func game_over():
	yield(get_tree().create_timer(2), "timeout")
	change_screen($GameOverScreen)
