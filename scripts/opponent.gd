extends CharacterBody2D

@export var acceleration := 150.0
@export var friction := 300.0
@export var brake_strength := 400.0
@export var max_speed := 500.0
@export var steer_strength := 6.0
@export var min_steer_factor := 0.5

@export var SLOW_RADIUS := 50.0
const ARRIVE_RADIUS := 25.0
@export var SLOW_SPEED := 50.0

@export var last_cpx := 0.0
@export var last_cpy := 0.0
@export var last_cprot := 0.0
@export var lap_ := 1
@export var cp_ := 0
@export var pos_ := 1

var _velocity := 0.0
var current_waypoint: int = 0

var _wobble_timer: float = 0.0
var _wobble_interval: float = 0.0
var _wobble_offset: float = 0.0

var WAYPOINTS = []

func _ready() -> void:
	add_to_group("car")
	_velocity = 0.0
	WAYPOINTS = load_track_from_json("res://waypoints/track1.json")
	_wobble_interval = randf_range(1.0, 3.0)
	var atlas = AtlasTexture.new()
	atlas.atlas = preload("res://assets/cars.png")
	atlas.region = Rect2(2, 56, 12, 25)
	$Sprite2D.texture = atlas
	set_physics_process(false)
	await get_tree().create_timer(6.5).timeout
	set_physics_process(true)
	
func load_track_from_json(path) -> Array:
	if not FileAccess.file_exists(path):
		print("Track file not found: ", path)
		return []
	
	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	
	if not data:
		print("Failed to parse track JSON")
		return []
	
	var track_points = []
	for point in data:
		track_points.append({
			"pos": Vector2(point["pos"]["x"], point["pos"]["y"]),
			"type": point["type"]
		})
	
	return track_points

func _physics_process(delta: float) -> void:
	if lap_ > 3:
		print("STOPPING")
		_velocity = 0.0
		velocity = Vector2.ZERO
		set_physics_process(false)
		set_process(false)
		return
		
	var target = WAYPOINTS[current_waypoint]["pos"]
	var to_target = target - global_position
	var dist = to_target.length()

	if dist < ARRIVE_RADIUS:
		current_waypoint = (current_waypoint + 1) % WAYPOINTS.size()

	# wobble
	_wobble_timer += delta
	if _wobble_timer >= _wobble_interval:
		_wobble_timer = 0.0
		_wobble_interval = randf_range(1.0, 3.0)
		_wobble_offset = randf_range(-0.08, 0.08)

	var desired_dir = to_target.normalized().rotated(_wobble_offset)
	var current_dir = Vector2.RIGHT.rotated(rotation)
	var alignment = current_dir.dot(desired_dir)

	if alignment < 0.8:
		_velocity = move_toward(_velocity, 0.0, brake_strength * delta)

	_apply_steering(delta, desired_dir)
	_apply_throttle(delta, dist, desired_dir)

	position += transform.x * delta * _velocity
	if move_and_slide():
		_velocity *= 0.3
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var normal = collision.get_normal()
			position += normal * 60.0 * delta

func _apply_throttle(delta: float, dist: float, desired_dir: Vector2) -> void:
	var current_dir = Vector2.RIGHT.rotated(rotation)
	var alignment = current_dir.dot(desired_dir)
	var is_corner = WAYPOINTS[current_waypoint]["type"] == "corner"

	var target_speed: float
	if is_corner and dist < SLOW_RADIUS:
		target_speed = SLOW_SPEED * clampf(alignment, 0.1, 1.0)
	else:
		target_speed = max_speed * clampf(alignment, 0.0, 1.0)

	var accel = brake_strength if target_speed < _velocity else acceleration
	_velocity = move_toward(_velocity, target_speed, accel * delta)
	_velocity = clampf(_velocity, 0.0, max_speed)

func _apply_steering(delta: float, desired_dir: Vector2) -> void:
	var current_dir = Vector2.RIGHT.rotated(rotation)
	var cross = current_dir.cross(desired_dir)
	var steer_factor = clampf(
		1.0 - pow(_velocity / max_speed, 2.0),
		min_steer_factor,
		1.0
	) * steer_strength
	rotate(steer_factor * delta * cross)
