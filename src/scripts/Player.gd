extends Actor

export(PackedScene) var foot_step


onready var _animated_sprite = $AnimatedSprite
onready var _audio_player = $AudioPlayer

var MIN_VELOCITY = -200
var MAX_VELOCITY = 200


func _ready() -> void:
	_animated_sprite.play("idle")
	_audio_player.set_volume_db(-10)


func _physics_process(delta: float) -> void:
	var is_jump_interrupted: = Input.is_action_just_released("jump") and _velocity.y < 0
	var direction: = get_direction()

	if knockback:
		_velocity = handle_knockback(_velocity, knockback_direction, knockback_impulse)
	else:
		_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)
	
	$RichTextLabel.text = "Velocity: %f, %f" % [_velocity.x, _velocity.y]
	
	handle_player_particles()


func _process(delta: float) -> void:
	handle_animation_state(_velocity)


func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1.0 if Input.is_action_just_pressed("jump") and is_on_floor() else 1.0
	) 


func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		speed: Vector2,
		is_jump_interrupted: bool
	) -> Vector2:
	var out: = linear_velocity
	out.x = speed.x * direction.x
	out.y += gravity * get_physics_process_delta_time()
	if direction.y == -1.0:
		out.y = speed.y * direction.y
	if is_jump_interrupted:
		out.y *= 0.6;
	out.y = clamp(out.y, MIN_VELOCITY, MAX_VELOCITY)
	out.x = clamp(out.x, MIN_VELOCITY, MAX_VELOCITY)
	return out


func handle_animation_state(velocity: Vector2) -> void:
	if velocity.y < 0:
		_animated_sprite.animation = "jump"
		if Input.is_action_just_pressed("jump"): 
			play_audio_from_resource("res://Assets/Audio/audio_jump.wav")
	elif velocity.y > 0:
		_animated_sprite.animation = "fall"
	elif velocity.x > 0 and knockback == 0:
		_animated_sprite.flip_h = false
		_animated_sprite.animation = "run"
	elif velocity.x < 0 and knockback == 0:
		_animated_sprite.flip_h = true
		_animated_sprite.animation = "run"
	else:
		_animated_sprite.animation = "idle"


func handle_player_particles():
	if _animated_sprite.animation == "run":
		if _animated_sprite.frame == 0 or _animated_sprite.frame == 4:
			var footstep = foot_step.instance()
			footstep.emitting = true
			footstep.global_position = Vector2(self.position.x, self.position.y+3)
			get_parent().add_child(footstep)
			play_audio_from_resource("res://Assets/Audio/audio_footstep.wav")


func play_audio_from_resource(name: String):
	var tmp_stream = load(name)
	_audio_player.set_stream(tmp_stream)
	_audio_player.play()


func _on_Player_body_entered(body):
	if body.is_in_group("enemies"):
		play_audio_from_resource("res://Assets/Audio/audio_player_hit.wav")
		knockback = 10
		knockback_direction = global_position.direction_to(body.global_position)


