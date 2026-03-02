extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Car.scale.x = 0.25
	$Car.scale.y = 0.25
	$Car.position.x = 301.0
	$Car.position.y = 262.0
	$Car.min_zoom = 6.0
	$Car.max_zoom = 8.0
	$Car.speed_zoom = 4.0
	
	$Opponent.scale.x = 0.25
	$Opponent.scale.y = 0.25
	$Opponent.position.x = 301.0
	$Opponent.position.y = 273.0
	$Opponent.SLOW_SPEED = 100.0
	$Opponent.SLOW_RADIUS = 75.0
	$Opponent.max_speed = 300.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
