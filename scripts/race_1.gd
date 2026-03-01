extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Car.position.x = 301.0
	$Car.position.y = 262.0
	
	$Opponent.position.x = 301.0
	$Opponent.position.y = 273.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
