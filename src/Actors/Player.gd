extends Actor

export(PackedScene) var foot_step
export var stomp_impulse = 1000.0

onready var _animatedSprite = $AnimatedSprite


func _ready() -> void:
	_animatedSprite.play("idle")


func _on_EnemyDetector_area_entered(area: Area2D) -> void:
	_velocity = calculate_stomp_velocity(_velocity, stomp_impulse)
	

func _on_EnemyDetector_body_entered(body: PhysicsBody2D) -> void:
	queue_free()
	

func _physics_process(delta: float) -> void:
	var is_jump_interrupted: = Input.is_action_just_released("jump") and _velocity.y < 0
	var direction: = get_direction()


	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	_velocity = move_and_slide(_velocity, FLOOR_NORMAL)
	set_animation_state(_velocity, is_jump_interrupted)
	var format_string = "_velocity: [%f, %f]"
	$RichTextLabel.text = format_string % [_velocity.x, _velocity.y]
	
	handle_player_particles()


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
		out.y = 0.0;
	return out


func calculate_stomp_velocity(linear_velocity: Vector2, impulse: float) -> Vector2:
	var out: = linear_velocity
	out.y = -impulse
	return out

func set_animation_state(velocity: Vector2, is_jump_interrupted: bool) -> void:
	if velocity.y < 0:
		_animatedSprite.animation = "jump"
		if Input.is_action_just_pressed("jump"): 
			$AudioPlayer.play()
	elif velocity.y > 0:
		_animatedSprite.animation = "fall"
	elif velocity.x > 0:
		_animatedSprite.flip_h = false
		_animatedSprite.animation = "run"
	elif velocity.x < 0:
		_animatedSprite.flip_h = true
		_animatedSprite.animation = "run"
	else:
		_animatedSprite.animation = "idle"
	
		
func handle_player_particles():
	if _animatedSprite.animation == "run":
		if _animatedSprite.frame == 0 or _animatedSprite.frame == 4:
			var footstep = foot_step.instance()
			footstep.emitting = true
			footstep.global_position = Vector2(self.position.x, self.position.y+3)
			get_parent().add_child(footstep)
