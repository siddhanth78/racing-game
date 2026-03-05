extends CanvasLayer

@export var tile_size := 64.0
@export var padding := 3.0
@export var viewport_size := 300.0

var map_ = false

func _ready() -> void:
	# Parent _ready runs AFTER children, so this is safe
	var cam = $SubViewport/Camera2D
	cam.tile_size = tile_size
	cam.padding = padding
	cam.viewport_size = viewport_size
	$Area2D.hide()
	$Sprite2D2.hide()
	$SubViewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	cam.setup()
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("map_toggle"):
		if map_ == true:
			map_ = false
			$Area2D.hide()
			$Sprite2D2.hide()
			$SubViewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
		else:
			map_ = true
			$Area2D.show()
			$Sprite2D2.show()
			$SubViewport.render_target_update_mode = SubViewport.UPDATE_WHEN_VISIBLE
