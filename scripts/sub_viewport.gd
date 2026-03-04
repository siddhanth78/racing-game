# attach to SubViewport
extends SubViewport

func _ready() -> void:
	world_2d = get_parent().get_viewport().world_2d
	
