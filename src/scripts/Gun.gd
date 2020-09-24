extends Node2D


export(PackedScene) var _bullet


const speed = 100
var mouse_position


func _process(delta):
	mouse_position = get_local_mouse_position()
	rotation += mouse_position.angle()

func _unhandled_input(event):
	if Input.is_action_just_pressed("shoot"):
		var bullet = _bullet.instance()
		bullet.set_shoot_direction((get_global_mouse_position() - global_position).normalized())
		bullet.position = global_position
		get_tree().current_scene.add_child(bullet)
