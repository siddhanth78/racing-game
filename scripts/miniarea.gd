extends Area2D

signal entered
signal exited

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.modulate.a = 0.5


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _mouse_enter() -> void:
	$Sprite2D.modulate.a = 1.0
	entered.emit()
	
func _mouse_exit() -> void:
	$Sprite2D.modulate.a = 0.5
	exited.emit()
