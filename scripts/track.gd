extends Node2D

var lap := 1
var pos := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Label.show()


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
