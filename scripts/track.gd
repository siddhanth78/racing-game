extends Node2D

var lap := 1
var pos := 0

const sigs = {
	"sig0": Rect2(4.0, 4.0, 17.0, 33.0),
	"sig1": Rect2(25.0, 4.0, 17.0, 33.0),
	"sig2": Rect2(46.0, 4.0, 17.0, 33.0),
	"sig3": Rect2(67.0, 4.0, 17.0, 33.0),
	"sig_go": Rect2(88.0, 4.0, 17.0, 33.0)
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.show()
	$sig.show()
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
	$sig.hide()
	$sig2.hide()
	$sig3.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_cp_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("car") and body.cp_ == 0:
		body.cp_ = 1
		body.last_cpx = $cp1.global_position.x
		body.last_cpy = $cp1.global_position.y
		body.last_cprot = body.rotation

func _on_cp_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("car") and body.cp_ == 1:
		body.cp_ = 2
		body.last_cpx = $cp2.global_position.x
		body.last_cpy = $cp2.global_position.y
		body.last_cprot = body.rotation

func _on_cp_3_body_entered(body: Node2D) -> void:
	if body.is_in_group("car") and body.cp_ == 2:
		body.cp_ = 3
		body.last_cpx = $cp3.global_position.x
		body.last_cpy = $cp3.global_position.y
		body.last_cprot = body.rotation

func _on_cp_4_body_entered(body: Node2D) -> void:
	if body.is_in_group("car") and body.cp_ == 3:
		body.cp_ = 4
		body.last_cpx = $cp4.global_position.x
		body.last_cpy = $cp4.global_position.y
		body.last_cprot = body.rotation

func _on_race_line_body_entered(body: Node2D) -> void:
	if body.is_in_group("car"):
		if body.cp_ == 4:
			body.lap_ += 1
			if body.is_in_group("player"):
				lap += 1
				if lap > 3:
					$Label.hide()
				$Label.text = "Lap "+str(lap)
		body.cp_ = 0
		body.last_cpx = $race_line.global_position.x
		body.last_cpy = $race_line.global_position.y
		body.last_cprot = body.rotation
		if body.lap_ > 3:
			pos += 1
			body.pos_ = pos
