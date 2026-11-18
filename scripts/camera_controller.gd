class_name IsometricCamera
extends Camera3D

@export var target: Node3D
@export var smooth_follow: bool = false # 默认硬锁定模式(像2D像素游戏一样零延迟)，角色停相机瞬停，消除停步后的微小像素蠕动
@export var follow_speed: float = 14.0
@export var distance: float = 800.0

# Strict 2:1 Top-Down View:
# Pitch = -30.0 deg (sin(30°) = 0.5 -> 2:1 depth compression)
# Yaw = 0.0 deg (straight-on, horizontal is horizontal, no 45° rotation)
const PITCH_DEG: float = -30.0
const YAW_DEG: float = 0.0

# 960x540 viewport height
const VIEWPORT_HEIGHT: float = 540.0

var _offset: Vector3 = Vector3.ZERO

func _ready() -> void:
	# 必须彻底关闭相机的物理插值！
	# 因为相机在 _process (渲染帧) 中直接实时跟随玩家插值后的渲染坐标，
	# 如果不关闭相机的物理插值，引擎会在渲染前根据物理拍子对相机再次插值，导致相机和角色位置产生微小的相位差争抢，
	# 在左右移动时造成角色像素列的反复跳动抖动！
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF

	projection = Camera3D.PROJECTION_ORTHOGONAL
	# 1 world unit = 1 game pixel (540 units visible vertically)
	size = VIEWPORT_HEIGHT
	near = 1.0
	far = 2500.0

	rotation_degrees = Vector3(PITCH_DEG, YAW_DEG, 0.0)

	var rot_basis = Basis.from_euler(Vector3(deg_to_rad(PITCH_DEG), deg_to_rad(YAW_DEG), 0.0))
	_offset = rot_basis * Vector3(0.0, 0.0, distance)

	if target == null:
		target = get_tree().get_first_node_in_group("player")

	if target != null:
		global_position = _calculate_desired_position()

func _calculate_desired_position() -> Vector3:
	var target_pos = target.global_position
	# 当目标支持物理插值时，在渲染帧获取平滑插值后的目标真实渲染坐标，消灭 60Hz 顿挫感
	if target.has_method("get_global_transform_interpolated"):
		target_pos = target.get_global_transform_interpolated().origin
	return target_pos + _offset

# 改在 _process (渲染帧) 更新：
# 配合物理插值，使相机在 60Hz/144Hz/165Hz 高刷显示器上的每一帧渲染中都丝滑平移，
# 彻底消除因物理时钟(60Hz)与渲染帧不同步导致的画面/地皮跳帧抖动！
func _process(delta: float) -> void:
	if target == null:
		return

	var desired = _calculate_desired_position()
	if smooth_follow:
		# 严格与帧率无关的指数阻尼平滑跟踪 (Exponential Smoothing)
		var t = 1.0 - exp(-follow_speed * delta)
		global_position = global_position.lerp(desired, t)
	else:
		# 硬锁定模式 (零延迟跟踪，传统 2D 像素游戏模式)
		global_position = desired
