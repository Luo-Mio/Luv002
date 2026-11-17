class_name IsometricCamera
extends Camera3D

@export var target: Node3D
@export var follow_speed: float = 10.0
@export var distance: float = 800.0
@export var pixel_snap: bool = true # 整像素对齐，彻底消除相机浮点平移时的亚像素抖动

# Strict 2:1 Top-Down View:
# Pitch = -30.0 deg (sin(30°) = 0.5 -> 2:1 depth compression)
# Yaw = 0.0 deg (straight-on, horizontal is horizontal, no 45° rotation)
const PITCH_DEG: float = -30.0
const YAW_DEG: float = 0.0

# 960x540 viewport height
const VIEWPORT_HEIGHT: float = 540.0

var _smooth_position: Vector3 = Vector3.ZERO

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
		_smooth_position = _calculate_desired_position()
		global_position = _apply_pixel_snap(_smooth_position) if pixel_snap else _smooth_position

func _calculate_desired_position() -> Vector3:
	var rot_basis = Basis.from_euler(Vector3(deg_to_rad(PITCH_DEG), deg_to_rad(YAW_DEG), 0.0))
	var offset = rot_basis * Vector3(0.0, 0.0, distance)
	return target.global_position + offset

func _physics_process(delta: float) -> void:
	if target != null:
		var desired = _calculate_desired_position()
		_smooth_position = _smooth_position.lerp(desired, follow_speed * delta)
		if pixel_snap:
			global_position = _apply_pixel_snap(_smooth_position)
		else:
			global_position = _smooth_position

# 2:1 俯视正交投影下的像素对齐:
# 水平轴 X: 1 个世界单位 = 1 个视口像素
# 地面深度轴 Z: sin(30°) = 0.5，所以 2 个 Z 世界单位 = 1 个垂直视口像素
func _apply_pixel_snap(pos: Vector3) -> Vector3:
	var snap_x = round(pos.x)
	var snap_z = round(pos.z * 0.5) * 2.0
	return Vector3(snap_x, pos.y, snap_z)
