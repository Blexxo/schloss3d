extends Node3D
@onready var pin_1: PackedScene = preload("res://scenes/pin_1.tscn")
@onready var pin_2: PackedScene = preload("res://scenes/pin_2.tscn")
@onready var pin_3: PackedScene = preload("res://scenes/pin_3.tscn")
@onready var pin_4: PackedScene = preload("res://scenes/pin_4.tscn")
@onready var pins: Node3D = $Pins
@onready var animation_player: AnimationPlayer = $Schloss/AnimationPlayer

var mapping = {}

var sol_pos : Dictionary = {}

func _ready() -> void:
	randomize_pins()
	sol_pos = {
		pin_1:Vector2(-0.10, -0.04),
		pin_2:Vector2(-0.12, -0.06),
		pin_3:Vector2(-0.14, -0.08),
		pin_4:Vector2(-0.16, -0.1)
		}
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("check_solved"):
		check_solved()

func check_solved():
	var liste = pins.get_children(true)
	var not_solved = []
	for l in liste:
		var y = l.get_child(0).position.y
		var rangeVec = sol_pos[mapping[l]]
		if y < rangeVec[0]:
			not_solved.append(l.get_child(0))
			l.get_child(0).freezed = false
		if y > rangeVec[1] and l.get_child(0):
			not_solved.append(l.get_child(0))
			l.get_child(0).freezed = false
	if not_solved.size() > 0:
		animation_player.play("still_closed")
		return
	animation_player.play("schloss_open")
	for l in liste:
		l.get_child(0).position.y = sol_pos[mapping[l]][0] + 0.01


func randomize_pins():
	var pin_scenes = [pin_1, pin_2, pin_3, pin_4]
	var pin_positions = [
		Vector3(-0.2, 0.25, 0.0),
		Vector3(-0.02, 0.25, 0.0),
		Vector3(0.16, 0.25, 0.0),
		Vector3(0.34, 0.25, 0.0),
		Vector3(0.52, 0.25, 0.0),
		Vector3(0.7, 0.25, 0.0)
	]

	randomize()
	
	for i in range(pin_positions.size()):
		var random_scene = pin_scenes[randi_range(0, pin_scenes.size() - 1)]
		var pin_instance = random_scene.instantiate()
		mapping[pin_instance] = random_scene
		pin_instance.position = pin_positions[i]
		pins.add_child(pin_instance)
