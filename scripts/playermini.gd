extends Sprite2D

func _ready() -> void:
	position = Vector2(140, 140)
	modulate.a = 0.5


func _on_area_2d_entered() -> void:
	modulate.a = 1.0

func _on_area_2d_exited() -> void:
	modulate.a = 0.5
