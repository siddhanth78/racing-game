extends Node

const scenes = {
	"race1": ["res://scenes/races/race_1.tscn",
				"res://waypoints/track1.json",
				Rect2(2, 56, 12, 25)],
	"main": ["res://scenes/overworld.tscn",
				"",
				Rect2(0,0,0,0)]
}

var px = 0.0
var py = 0.0

var waypoints := ""
var opp := Rect2(0,0,0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func load_scene(scene_name: String):
	waypoints = scenes[scene_name][1]
	opp = scenes[scene_name][2]
	get_tree().change_scene_to_file(scenes[scene_name][0])
