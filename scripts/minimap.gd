extends CanvasLayer

@export var tile_size := 64.0
@export var padding := 3.0
@export var viewport_size := 200.0

func _ready() -> void:
	# Parent _ready runs AFTER children, so this is safe
	var cam = $SubViewport/Camera2D
	cam.tile_size = tile_size
	cam.padding = padding
	cam.viewport_size = viewport_size
	cam.setup()
