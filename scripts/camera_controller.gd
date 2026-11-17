class_name IsometricCamera
extends Camera3D

@export var target: Node3D
@export var follow_speed: float = 10.0
@export var distance: float = 800.0

# Strict 2:1 Top-Down View:
# Pitch = -30.0 deg (sin(30°) = 0.5 -> 2:1 depth compression)
# Yaw = 0.0 deg (straight-on, horizontal is horizontal, no 45° rotation)
const PITCH_DEG: float = -30.0
const YAW_DEG: float = 0.0

# 960x540 viewport height
const VIEWPORT_HEIGHT: float = 540.0

func _ready() -> void:
	projection = Camera3D.PROJECTION_ORTHOGONAL
	# 1 world unit = 1 game pixel (540 units visible vertically)
	size = VIEWPORT_HEIGHT
	near = 1.0
	far = 2500.0

	rotation_degrees = Vector3(PITCH_DEG, YAW_DEG, 0.0)

	if target == null:
		target = get_tree().get_first_node_in_group("player")

	if target != null:
		global_position = _calculate_desired_position()

func _calculate_desired_position() -> Vector3:
	var rot_basis = Basis.from_euler(Vector3(deg_to_rad(PITCH_DEG), deg_to_rad(YAW_DEG), 0.0))
	var offset = rot_basis * Vector3(0.0, 0.0, distance)
	return target.global_position + offset

func _physics_process(delta: float) -> void:
	if target != null:
		var desired = _calculate_desired_position()
		global_position = global_position.lerp(desired, follow_speed * delta)
