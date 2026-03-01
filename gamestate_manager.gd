extends Node

const scenes = {
	"race1": "res://scenes/races/race_1.tscn",
	"main": "res://scenes/overworld.tscn"
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func load_scene(scene_name: String):
	get_tree().change_scene_to_file(scenes[scene_name])
