extends CharacterBody2D

@export var acceleration := 60.0
@export var rev_acceleration := 50.0
@export var friction := 300.0
@export var max_speed := 600.0
@export var steer_strength := 2.0
@export var min_steer_factor := 0.5

@export var min_zoom := 6.0
@export var max_zoom := 8.0
@export var zoom_damp := 2.0
@export var szoom_damp := 0.5
@export var speed_zoom := 4.0

@export var last_cpx := 0.0
@export var last_cpy := 0.0
@export var last_cprot := 0.0
@export var lap_ := 1
@export var cp_ := -1
@export var pos_ := 1
@export var set_timer = false

var min_clamp := 0.0
var max_clamp := 0.0

var _throttle := 0.0
var _velocity := 0.0
var _steer := 0.0

var curr_zoom := 0.0
var _bounce_tween: Tween
var _bounce_target := Vector2.ZERO
var rot_factor := 0.0
var end_zoom := min_zoom

@export var gear_thresholds: Array[float] = [0.0, 150.0, 300.0, 450.0, 600]
@export var min_pitch := 1.0
@export var max_pitch := 2.2

var current_gear := 0
var last_gear := 0

var nearest_90 = 0.0

var can_input = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("car")
	add_to_group("player")
	end_zoom = min_zoom
	$Camera2D.zoom.x = min_zoom
	$Camera2D.zoom.y = min_zoom
	curr_zoom = min_zoom
	rotation = 0.0
	$EnginePlayer.play()
	
	var atlas = AtlasTexture.new()
	atlas.atlas = preload("res://assets/cars.png")
	atlas.region = Rect2(2,2,12,25)
	
	$Sprite2D.texture = atlas
	
	if set_timer == true:
		set_process(false)
		set_physics_process(false)
		await get_tree().create_timer(6.5).timeout
		set_process(true)
		set_physics_process(true)
	
func reset() -> void:
	_velocity = 0.0
	velocity = Vector2.ZERO
	rotation = 0.0
	call_deferred("set_position", Vector2(242.0, 268.0))

func update_engine_sound(delta: float) -> void:
	var abs_vel = abs(_velocity)

	var target_gear = 0
	for i in range(gear_thresholds.size() - 1):
		if abs_vel >= gear_thresholds[i]:
			target_gear = i
	
	current_gear = target_gear

	if current_gear != last_gear:
		if current_gear < last_gear:
			$EnginePlayer.pitch_scale = min_pitch 
			
		last_gear = current_gear

	var gear_start = gear_thresholds[current_gear]
	var gear_end = gear_thresholds[current_gear + 1]
	var gear_progress = clamp((abs_vel - gear_start) / (gear_end - gear_start), 0.0, 1.0)

	var target_pitch = lerp(min_pitch, max_pitch, gear_progress)
	if _throttle <= 0:
		target_pitch = lerp(min_pitch, max_pitch * 0.5, gear_progress)

	# Smooth the shift
	$EnginePlayer.pitch_scale = lerp($EnginePlayer.pitch_scale, target_pitch, 10.0 * delta)

	var target_vol = lerp(0.4, 1.0, gear_progress)
	$EnginePlayer.volume_db = linear_to_db(target_vol)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_input:
		_throttle = Input.get_action_strength("accelerate") - Input.get_action_strength("deccelerate")
		_steer = Input.get_axis("steer_left", "steer_right")
		
		if Input.is_action_just_pressed("reset_player") and cp_ != -1:
			position.x = last_cpx
			position.y = last_cpy
			rotation = last_cprot
	
func _physics_process(delta: float) -> void:
	if lap_ > 3:
		_velocity = 0.0
		_throttle = 0.0
		_steer = 0.0
		can_input = false
		$EnginePlayer.stop()
		$ProgressBar.set_value_no_signal(0.0)
		set_physics_process(false)
		set_process(false)
		return

	update_engine_sound(delta)
	apply_throttle(delta)
	
	if _velocity != 0:
		apply_rotation(delta)
	position += transform.x * delta * _velocity
	if move_and_slide():
		set_physics_process(false)
		$CrashPlayer.volume_db = linear_to_db(clampf(abs(_velocity) / max_speed, 0.2, 1.0))
		$CrashPlayer.play()
		_bounce_target = position + (-transform.x * 30.0 * sign(_velocity))
		_velocity = 0
		if _bounce_tween and _bounce_tween.is_running():
			_bounce_tween.kill()
		rotation_degrees = wrapf(rotation_degrees, 0.0, 360.0)
		_bounce_tween = create_tween()
		_bounce_tween.set_parallel()
		_bounce_tween.tween_property(self, "position", _bounce_target, 0.5)
		nearest_90 = round(rotation_degrees / 90.0) * 90.0
		rot_factor = nearest_90 - rotation_degrees
		_bounce_tween.tween_property(self, "rotation_degrees", rotation_degrees + rot_factor, 0.8)
		_bounce_tween.set_parallel(false)
		_bounce_tween.finished.connect(bounce_complete)
	$ProgressBar.set_value_no_signal((absf(_velocity) / max_speed) * 100.0)
	if Input.is_action_just_pressed("ui_accept"):
		print("Vector2(", global_position.x, ", ", global_position.y, ")")

func bounce_complete():
	await $CrashPlayer.finished
	$CrashPlayer.stop()
	set_physics_process(true)

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
			
		if curr_zoom > min_zoom and _steer == 0.0:
			curr_zoom -= szoom_damp * delta
		elif curr_zoom < min_zoom and _steer == 0.0:
			curr_zoom += szoom_damp * delta
			
		if curr_zoom > min_zoom:
			end_zoom = max_zoom
		else:
			end_zoom = min_zoom
		curr_zoom = clampf(curr_zoom, speed_zoom, end_zoom)
			
	if abs(_velocity) >= max_speed-50:
		curr_zoom -= szoom_damp * delta
		if curr_zoom > min_zoom:
			end_zoom = max_zoom
		else:
			end_zoom = min_zoom
		curr_zoom = clampf(curr_zoom, speed_zoom, end_zoom)
		
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
		curr_zoom -= szoom_damp * delta
		curr_zoom = clampf(curr_zoom, speed_zoom, max_zoom)
		$Camera2D.zoom.x = curr_zoom
		$Camera2D.zoom.y = curr_zoom
		if curr_zoom <= min_zoom:
			end_zoom = min_zoom
		return
	curr_zoom += zoom_damp * delta
	end_zoom = max_zoom
	curr_zoom = clampf(curr_zoom, speed_zoom, max_zoom)
	$Camera2D.zoom.x = curr_zoom
	$Camera2D.zoom.y = curr_zoom
	rotate(get_steer_factor() * delta * _steer * sign(_velocity))
