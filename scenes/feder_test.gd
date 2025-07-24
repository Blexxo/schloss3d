extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var anchor: StaticBody3D = $StaticBody3D
@onready var ball: RigidBody3D = $RigidBody3D

var rest_length := 2.0        # Abstand, ab dem keine Abstoßung mehr stattfindet
var stiffness := 50.0         # Stärke der Abstoßung
var damping := 5.0            # Dämpfung gegen Schwingen
var move_force := 80.0        # Stärke der Mausbewegung

func _physics_process(delta):
	# === 1. Federkraft nach außen berechnen ===
	var anchor_pos = anchor.global_transform.origin
	var ball_pos = ball.global_transform.origin

	var spring_vector = ball_pos - anchor_pos
	var current_length = spring_vector.length()
	var direction = spring_vector.normalized()

	if current_length < rest_length:
		var displacement = rest_length - current_length
		var velocity_along_spring = ball.linear_velocity.dot(direction)
		var repulsion_force = direction * (stiffness * displacement - damping * velocity_along_spring)
		ball.apply_central_force(repulsion_force)

	# === 2. Mausposition → Y-Richtung ziehen ===
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_dir = camera.project_ray_normal(mouse_pos)

	# Schnittpunkt des Mausstrahls mit Ebene Z = Ball.z
	if abs(ray_dir.z) > 0.0001:
		var t = (ball_pos.z - ray_origin.z) / ray_dir.z
		var target_pos = ray_origin + ray_dir * t

		if Input.is_action_pressed("Left_Click"):
			var y_diff = target_pos.y - ball_pos.y
			var mouse_force = Vector3(0, y_diff * move_force, 0)
			ball.apply_central_force(mouse_force)
