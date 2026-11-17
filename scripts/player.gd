class_name Player
extends CharacterBody3D

@export var walk_speed: float = 120.0
@export var sprint_speed: float = 220.0

@onready var anim_sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var col_shape: CollisionShape3D = $CollisionShape3D

enum Direction {
	DOWN,
	UP,
	LEFT,
	RIGHT
}

var current_direction: Direction = Direction.DOWN
var is_moving: bool = false

func _ready() -> void:
	add_to_group("player")
	_update_animation(true)

func _physics_process(_delta: float) -> void:
	var input_vec = _get_input_vector()
	var speed = sprint_speed if Input.is_key_pressed(KEY_SHIFT) else walk_speed

	# 2:1 Top-Down View (Yaw = 0°):
	# X is Left/Right (-X / +X)
	# Z is Up/Down (-Z / +Z)
	var move_dir = Vector3(input_vec.x, 0.0, input_vec.y).normalized()

	velocity.x = move_dir.x * speed
	velocity.z = move_dir.z * speed
	velocity.y = 0.0

	is_moving = input_vec.length_squared() > 0.01

	if is_moving:
		# 核心需求：左右斜向移动时，依然采用左右方向的动画！
		# 只要水平方向有分量 (|input_vec.x| > 0)，左右动画的优先级高于上下动画
		if abs(input_vec.x) > 0.01:
			if input_vec.x > 0.0:
				current_direction = Direction.RIGHT
			else:
				current_direction = Direction.LEFT
		else:
			# 纯上下移动（无左右偏向）
			if input_vec.y > 0.0:
				current_direction = Direction.DOWN
			elif input_vec.y < 0.0:
				current_direction = Direction.UP

	move_and_slide()
	_update_animation()

func _get_input_vector() -> Vector2:
	var x: float = 0.0
	var y: float = 0.0

	# 1. Check WASD keys
	if Input.is_key_pressed(KEY_A) or Input.is_action_pressed("ui_left"):
		x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_action_pressed("ui_right"):
		x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_action_pressed("ui_up"):
		y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_action_pressed("ui_down"):
		y += 1.0

	return Vector2(x, y).normalized()

func _update_animation(force: bool = false) -> void:
	if anim_sprite == null or anim_sprite.sprite_frames == null:
		return

	var dir_suffix = "down"
	match current_direction:
		Direction.DOWN:
			dir_suffix = "down"
		Direction.UP:
			dir_suffix = "up"
		Direction.LEFT:
			dir_suffix = "left"
		Direction.RIGHT:
			dir_suffix = "right"

	var target_anim = ""
	if is_moving:
		target_anim = "walk_empty_" + dir_suffix
	else:
		# 兼顾 "idel_empty_*" 与 "idle_empty_*" 命名
		if anim_sprite.sprite_frames.has_animation("idel_empty_" + dir_suffix):
			target_anim = "idel_empty_" + dir_suffix
		elif anim_sprite.sprite_frames.has_animation("idle_empty_" + dir_suffix):
			target_anim = "idle_empty_" + dir_suffix
		else:
			target_anim = "default"

	if anim_sprite.sprite_frames.has_animation(target_anim):
		if force or anim_sprite.animation != target_anim:
			anim_sprite.play(target_anim)
