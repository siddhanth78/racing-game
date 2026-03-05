extends Node2D

const sigs = {
	"sig0": Rect2(4.0, 4.0, 17.0, 33.0),
	"sig1": Rect2(25.0, 4.0, 17.0, 33.0),
	"sig2": Rect2(46.0, 4.0, 17.0, 33.0),
	"sig3": Rect2(67.0, 4.0, 17.0, 33.0),
	"sig_go": Rect2(88.0, 4.0, 17.0, 33.0)
}

func _ready() -> void:
	self.show()
	var atlas = AtlasTexture.new()
	atlas.atlas = preload("res://assets/sigs.png")
	atlas.region = sigs["sig0"]
	$sig/Sprite2D.texture = atlas
	$sig2/Sprite2D.texture = atlas
	$sig3/Sprite2D.texture = atlas
	await get_tree().create_timer(1.5).timeout
	atlas.region = sigs["sig1"]
	$sig/Sprite2D.texture = atlas
	$sig2/Sprite2D.texture = atlas
	$sig3/Sprite2D.texture = atlas
	$AudioStreamPlayer2.play()
	await get_tree().create_timer(1.5).timeout
	atlas.region = sigs["sig2"]
	$sig/Sprite2D.texture = atlas
	$sig2/Sprite2D.texture = atlas
	$sig3/Sprite2D.texture = atlas
	$AudioStreamPlayer2.play()
	await get_tree().create_timer(1.5).timeout
	atlas.region = sigs["sig3"]
	$sig/Sprite2D.texture = atlas
	$sig2/Sprite2D.texture = atlas
	$sig3/Sprite2D.texture = atlas
	$AudioStreamPlayer2.play()
	await get_tree().create_timer(2.0).timeout
	atlas.region = sigs["sig_go"]
	$sig/Sprite2D.texture = atlas
	$sig2/Sprite2D.texture = atlas
	$sig3/Sprite2D.texture = atlas
	$AudioStreamPlayer2.play()
	$AudioStreamPlayer.play()
	await get_tree().create_timer(1.0).timeout
	self.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
