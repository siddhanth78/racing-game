extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Car.scale.x = 0.5
	$Car.scale.y = 0.5
	$Car.set_timer = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
