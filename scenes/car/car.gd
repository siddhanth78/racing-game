extends CharacterBody2D

@export var acceleration := 150.0
@export var rev_acceleration := 75.0
@export var friction := 300.0
@export var max_speed := 400.0
@export var steer_strength := 6.0
@export var min_steer_factor := 0.5

@export var min_zoom := 6.0
@export var max_zoom := 8.0
@export var zoom_damp := 2.0
@export var szoom_damp := 0.5
@export var speed_zoom := 4.0

var min_clamp := 0.0
var max_clamp := 0.0

var _throttle := 0.0
var _velocity := 0.0
var _steer := 0.0

var curr_zoom := 0.0
var _bounce_tween: Tween
var _bounce_target := Vector2.ZERO

var steering := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Camera2D.zoom.x = min_zoom
	$Camera2D.zoom.y = min_zoom
	curr_zoom = min_zoom
	position.x = 242.0
	position.y = 268.0
	rotation = 0.0
	$EnginePlayer.play()
	
func reset() -> void:
	_velocity = 0.0
	velocity = Vector2.ZERO
	rotation = 0.0
	call_deferred("set_position", Vector2(242.0, 268.0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_throttle = Input.get_action_strength("accelerate") - Input.get_action_strength("deccelerate")
	_steer = Input.get_axis("steer_left", "steer_right")
	
func _physics_process(delta: float) -> void:
	var speed_ratio = clamp(_velocity / max_speed, 0.0, 1.0)
	$EnginePlayer.volume_db = linear_to_db(lerp(0.3, 1.0, speed_ratio))
	$EnginePlayer.pitch_scale = lerp(1.0, 1.5, speed_ratio)
	apply_throttle(delta)
	if _velocity != 0:
		apply_rotation(delta)
	position += transform.x * delta * _velocity
	if move_and_slide():
		set_physics_process(false)
		$CrashPlayer.volume_db = linear_to_db(lerp(0.3, 1.0, speed_ratio))
		$CrashPlayer.play()
		_velocity *= 0.5
		_bounce_target = position + (-transform.x * 10.0)
		if _bounce_tween and _bounce_tween.is_running():
			_bounce_tween.kill()
		rotation_degrees = fmod(rotation_degrees, 360.0)
		_bounce_tween = create_tween()
		_bounce_tween.set_parallel()
		_bounce_tween.tween_property(self, "position", _bounce_target, 0.8)
		_bounce_tween.tween_property(self, "rotation_degrees", rotation_degrees + 45.0, 0.8)
		_bounce_tween.set_parallel(false)
		_bounce_tween.finished.connect(bounce_complete)
	$ProgressBar.set_value_no_signal((absf(_velocity) / max_speed) * 100.0)
	
func bounce_complete():
	set_physics_process(true)
	await $CrashPlayer.finished
	$CrashPlayer.stop()

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
		curr_zoom += szoom_damp * delta
		curr_zoom = clampf(curr_zoom, speed_zoom, min_zoom)
			
	if _throttle != 0.0 and steering == false:
		curr_zoom -= szoom_damp * delta
		curr_zoom = clampf(curr_zoom, speed_zoom, min_zoom)
		
	$Camera2D.zoom.x = curr_zoom
	$Camera2D.zoom.y = curr_zoom
	_velocity = clampf(_velocity, min_clamp, max_clamp)
	
func get_steer_factor() -> float:
	return clampf(
		1.0 - pow(_velocity / max_speed, 2.0),
		min_steer_factor,
		1.0
	) * steer_strength
	
func apply_rotation(delta: float) -> void:
	if _steer == 0.0:
		if steering:
			curr_zoom -= zoom_damp * delta
			curr_zoom = clampf(curr_zoom, speed_zoom, max_zoom)
			$Camera2D.zoom.x = curr_zoom
			$Camera2D.zoom.y = curr_zoom
			if curr_zoom <= min_zoom:
				steering = false
		return
	steering = true
	curr_zoom += zoom_damp * delta
	curr_zoom = clampf(curr_zoom, speed_zoom, max_zoom)
	$Camera2D.zoom.x = curr_zoom
	$Camera2D.zoom.y = curr_zoom
	rotate(get_steer_factor() * delta * _steer * sign(_velocity))
