extends Camera2D

var tile_size := 64.0
var padding := 3.0
var viewport_size := 200.0
var player: Node2D

func setup() -> void:
	var padding_px = padding * tile_size
	var z = viewport_size / (viewport_size + padding_px * 2.0)
	zoom = Vector2(z, z)
	player = get_tree().get_root().find_child("Car", true, false)

func _process(delta: float) -> void:
	if not is_instance_valid(player):
		return
	global_position = player.global_position
	global_rotation = player.global_rotation
