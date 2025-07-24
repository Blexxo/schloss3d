extends CharacterBody3D

@export var gravity: float = 10
var freezed = false
@onready var timer: Timer = $Timer

func _physics_process(delta: float) -> void:
	#print(velocity.y)
	if not is_on_floor() and not freezed:
		velocity.y -= gravity * delta
	
	if freezed:
		velocity.y = 0

	
	move_and_slide()
