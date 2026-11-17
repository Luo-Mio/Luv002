class_name TestPlayer
extends CharacterBody3D

# Speeds in game pixels / world units per second
@export var move_speed: float = 180.0
@export var sprint_speed: float = 400.0

func _physics_process(_delta: float) -> void:
	var input_x = Input.get_axis("ui_left", "ui_right")
	var input_z = Input.get_axis("ui_up", "ui_down")

	var current_speed = sprint_speed if Input.is_key_pressed(KEY_SHIFT) else move_speed

	# Straight 2:1 Top-Down View (Yaw = 0.0 deg):
	# Up on screen = -Z in 3D world
	# Down on screen = +Z in 3D world
	# Left on screen = -X in 3D world
	# Right on screen = +X in 3D world
	var dir = Vector3(input_x, 0.0, input_z).normalized()

	velocity.x = dir.x * current_speed
	velocity.z = dir.z * current_speed
	velocity.y = 0.0

	move_and_slide()
