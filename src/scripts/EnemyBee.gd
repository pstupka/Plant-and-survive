extends Actor


onready var _animated_sprite = $AnimatedSprite
var target = null
var start_position: Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("enemies")
	start_position = global_position
	_animated_sprite.play("idle")


func _physics_process(delta):
	if target:
		handle_flip()
		_velocity = global_position.direction_to(target.global_position)
		if knockback:
			_velocity = handle_knockback(_velocity, knockback_direction, knockback_impulse)
			_velocity = _velocity*0.02
		move_and_collide(_velocity * speed * delta)
	else:
		_velocity = global_position.direction_to(start_position)
		move_and_collide(_velocity * speed * 0.5 * delta)


func handle_flip():
	var direction_to_player = global_position.direction_to(target.global_position)
	if sign(direction_to_player.x) > 0:
		_animated_sprite.flip_h = false
	else:
		_animated_sprite.flip_h = true


func _on_DiscoverArea_body_entered(body):
	if body.name == "Player":
		target = body
		_animated_sprite.animation = "attack"


func _on_DiscoverArea_body_exited(body):
	if body.name == "Player":
		target = null
		_animated_sprite.animation = "idle"
		_animated_sprite.flip_h = !_animated_sprite.flip_h


func _on_Enemy_body_entered(body):
	if body.name == "Player":
		knockback = 10
		knockback_direction = global_position.direction_to(body.global_position)
