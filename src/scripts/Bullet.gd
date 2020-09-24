extends KinematicBody2D


const VELOCITY = 100
var _direction: Vector2 


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("bullets")


func _physics_process(delta):
	var collision = move_and_collide(_direction * VELOCITY * delta)
	if collision:
		print(collision)
		queue_free()


func set_shoot_direction(direction: Vector2):
	_direction = direction


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
