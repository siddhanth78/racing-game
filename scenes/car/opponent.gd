extends CharacterBody2D

@export var acceleration := 150.0
@export var friction := 300.0
@export var brake_strength := 400.0
@export var max_speed := 500.0
@export var steer_strength := 6.0
@export var min_steer_factor := 0.5

const WAYPOINTS = [
	{"pos": Vector2(362.804992675781, 271.377777099609), "type": "corner"},
	{"pos": Vector2(381.580749511719, 268.703582763672), "type": "corner"},
	{"pos": Vector2(391.826904296875, 256.802551269531), "type": "corner"},
	{"pos": Vector2(391.234924316406, 217.768356323242), "type": "road"},
	{"pos": Vector2(393.590881347656, 169.112182617188), "type": "road"},
	{"pos": Vector2(391.419128417969, 155.769378662109), "type": "corner"},
	{"pos": Vector2(385.429443359375, 142.070129394531), "type": "corner"},
	{"pos": Vector2(373.606994628906, 135.575286865234), "type": "corner"},
	{"pos": Vector2(328.147979736328, 136.315139770508), "type": "road"},
	{"pos": Vector2(253.002166748047, 137.284072875977), "type": "road"},
	{"pos": Vector2(208.825744628906, 135.621704101562), "type": "corner"},
	{"pos": Vector2(193.865463256836, 144.645904541016), "type": "corner"},
	{"pos": Vector2(190.004180908203, 161.404251098633), "type": "corner"},
	{"pos": Vector2(187.741439819336, 196.979019165039), "type": "road"},
	{"pos": Vector2(192.757278442383, 234.125106811523), "type": "road"},
	{"pos": Vector2(190.821228027344, 249.943634033203), "type": "corner"},
	{"pos": Vector2(192.670883178711, 263.547698974609), "type": "corner"},
	{"pos": Vector2(209.744720458984, 273.665710449219), "type": "corner"},
	{"pos": Vector2(241.217330932617, 271.417205810547), "type": "road"},
	{"pos": Vector2(312.322387695312, 269.853546142578), "type": "road"},
]

@export var SLOW_RADIUS := 50.0
const ARRIVE_RADIUS := 25.0
@export var SLOW_SPEED := 50.0

var _velocity := 0.0
var current_waypoint: int = 0

var _wobble_timer: float = 0.0
var _wobble_interval: float = 0.0
var _wobble_offset: float = 0.0

func _ready() -> void:
	_velocity = 0.0
	position = Vector2(301.0, 273.0)
	_wobble_interval = randf_range(1.0, 3.0)
	var atlas = AtlasTexture.new()
	atlas.atlas = preload("res://assets/cars.png")
	atlas.region = Rect2(2, 56, 12, 25)
	$Sprite2D.texture = atlas

func _physics_process(delta: float) -> void:
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
