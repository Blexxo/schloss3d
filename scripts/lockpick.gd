extends CharacterBody3D
@onready var timer: Timer = $Timer

@onready var camera: Camera3D = $"../Camera3D"

const MAX_SPEED = 120
const STOP_DISTANCE = 0.0

var intended_velocity: Vector3 = Vector3.ZERO
var direction: Vector3 = Vector3.ZERO
var connected: Array[CharacterBody3D] = []
var real_velo = get_real_velocity()
var colliding = false

func _physics_process(delta: float) -> void:
	#print(velocity.y)
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)

	if ray_direction.z != 0.0:
		var t = -ray_origin.z / ray_direction.z
		var target_position = ray_origin + ray_direction * t

		var to_mouse = target_position - global_transform.origin + Vector3(0.4, 0, 0)
		to_mouse.z = 0  # Nur XY-Bewegung
		var distance = to_mouse.length()

		if Input.is_action_pressed("Left_Click") and distance > STOP_DISTANCE:
			direction = to_mouse.normalized()
			var speed = MAX_SPEED * clamp(distance / 10.0, 0.0, 1.0)
			intended_velocity = direction * speed
			velocity = intended_velocity
		else:
			intended_velocity = Vector3.ZERO
			velocity = Vector3.ZERO

		if Input.is_action_just_released("Left_Click"):
			global_transform.origin = Vector3(2.25, -0.5, global_transform.origin.z)

	if velocity.y < 0.12 and velocity.y > -0.12 and timer.is_stopped():
		timer.start(0.5)
		
	if velocity.y >= 0.12 or velocity.y <= -0.12:
		timer.stop()
	
	'for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		print(collider.name)
		if collider.name == "Schloss_smooth_without":
			colliding = true
		else:
			colliding = false'
	move_and_slide()

	if connected != []:
		for c in connected:
			if intended_velocity.y >= 0.0 and real_velo.y >= 0.0 and velocity.y >= 0.0:
				if colliding:
						print("colliding")
						c.velocity.y = 0
						c.gravity = 0
				else:
						c.gravity = 0
						c.velocity.y = intended_velocity.y
			else:
				c.gravity = 10
				c.velocity.y = 0

# Wenn Lockpick den Pin berührt
func _on_area_3d_body_entered(body: Node3D) -> void:
	#print(body.name)
	if body is CharacterBody3D and body not in connected:
		connected.append(body)
		body.freezed = false
	if body.name == "Schloss_smooth_without":
		colliding = true

# Wenn Lockpick den Pin verlässt
func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		body.gravity = 10
		connected.erase(body)
	if body.name == "Schloss_smooth_without":
		colliding = false

func _on_timer_timeout() -> void:
	for c in connected:
		c.freezed = true
