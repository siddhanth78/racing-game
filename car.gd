extends Area2D

@export var acceleration := 150.0
@export var rev_acceleration := 75.0
@export var friction := 300.0
@export var max_speed := 400.0
@export var steer_strength := 6.0
@export var min_steer_factor := 0.5

var min_clamp := 0.0
var max_clamp := 0.0

var _throttle := 0.0
var _velocity := 0.0
var _steer := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_throttle = Input.get_action_strength("accelerate") - Input.get_action_strength("deccelerate")
	_steer = Input.get_axis("steer_left", "steer_right")
	
func _physics_process(delta: float) -> void:
	apply_throttle(delta)
	if _velocity != 0.0:
		apply_rotation(delta)
	position += transform.x * delta * _velocity
	
func apply_throttle(delta: float) -> void:
	if _throttle > 0.0 and _velocity >= 0:
		_velocity += acceleration * delta
		min_clamp = 0.0
		max_clamp = max_speed
	elif _throttle < 0.0 and _velocity <= 0:
		_velocity -= rev_acceleration * delta
		min_clamp = -max_speed
		max_clamp = 0.0
	else:
		if _velocity < 0.0:
			_velocity += friction * delta
			_velocity = minf(_velocity, 0.0)
		else:
			_velocity -= friction * delta
			_velocity = maxf(_velocity, 0.0)
		
	_velocity = clampf(_velocity, min_clamp, max_clamp)
	
func get_steer_factor() -> float:
	return clampf(
		1.0 - pow(_velocity / max_speed, 2.0),
		min_steer_factor,
		1.0
	) * steer_strength
	
func apply_rotation(delta: float) -> void:
	if _steer == 0.0:
		return
	rotate(get_steer_factor() * delta * _steer * sign(_velocity))
