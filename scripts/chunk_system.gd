class_name ChunkSystem
extends Node

signal player_chunk_changed(old_chunk: Vector2i, new_chunk: Vector2i)
signal chunk_settlement_executed(chunk_coord: Vector2i, days_passed: int)

# Standard Chunk Size: 512x512 game pixels
# Projected on 2:1 camera (Pitch -30°, Yaw 0°), visually measures exactly 512x256 screen pixels!
const CHUNK_SIZE: int = 512
const UNIT_SIZE: float = 1.0 # 1 3D unit = 1 game pixel

const CHUNK_WORLD_SIZE: float = float(CHUNK_SIZE) * UNIT_SIZE # 512.0
const HALF_CHUNK_SIZE: float = CHUNK_WORLD_SIZE * 0.5         # 256.0

# 3x3 active chunks around player (center 1 + 8 neighbors)
@export var active_radius: int = 1
@export var target_node: Node3D
@export var time_system: TimeSystem

# Database of discovered chunks: Vector2i -> Dictionary
var chunk_table: Dictionary = {}
var active_chunks: Dictionary = {}
var current_player_chunk: Vector2i = Vector2i(999999, 999999)

func _ready() -> void:
	if time_system != null:
		time_system.day_ended.connect(_on_daily_settlement)

func _process(_delta: float) -> void:
	if target_node == null:
		target_node = get_tree().get_first_node_in_group("player")
	if target_node == null:
		return

	var p_chunk = world_to_chunk_coord(target_node.global_position)
	if p_chunk != current_player_chunk:
		var old = current_player_chunk
		current_player_chunk = p_chunk
		_update_active_chunks(p_chunk)
		player_chunk_changed.emit(old, current_player_chunk)

# Convert 3D world position (X, Z) into quadrant chunk coordinates
# Chunk (0, 0) is centered at (0, 0, 0), spanning [-256, +256] on X and Z
func world_to_chunk_coord(world_pos: Vector3) -> Vector2i:
	var cx = int(floor((world_pos.x + HALF_CHUNK_SIZE) / CHUNK_WORLD_SIZE))
	var cy = int(floor((world_pos.z + HALF_CHUNK_SIZE) / CHUNK_WORLD_SIZE))
	return Vector2i(cx, cy)

# Returns the center position of a given chunk in world space
func chunk_to_world_center(chunk_coord: Vector2i) -> Vector3:
	return Vector3(
		float(chunk_coord.x) * CHUNK_WORLD_SIZE,
		0.0,
		float(chunk_coord.y) * CHUNK_WORLD_SIZE
	)

# Returns the bounding box of a given chunk: Rect2(min_x, min_z, 512, 512)
func get_chunk_world_rect(chunk_coord: Vector2i) -> Rect2:
	var center = chunk_to_world_center(chunk_coord)
	return Rect2(center.x - HALF_CHUNK_SIZE, center.z - HALF_CHUNK_SIZE, CHUNK_WORLD_SIZE, CHUNK_WORLD_SIZE)

func _update_active_chunks(center_chunk: Vector2i) -> void:
	var current_day = time_system.current_day if time_system != null else 1
	var new_active: Dictionary = {}

	for dx in range(-active_radius, active_radius + 1):
		for dy in range(-active_radius, active_radius + 1):
			var c = center_chunk + Vector2i(dx, dy)
			new_active[c] = true

			if not chunk_table.has(c):
				chunk_table[c] = {
					"last_loaded_date": current_day,
					"created_day": current_day
				}
				print("[ChunkSystem] New 512x512 Chunk discovered: %s (Quadrant: %s) on Day %d" % [
					c, _get_quadrant_name(c), current_day
				])

	active_chunks = new_active

func _get_quadrant_name(c: Vector2i) -> String:
	if c.x >= 0 and c.y >= 0:
		return "Quadrant I (+,+)"
	elif c.x < 0 and c.y >= 0:
		return "Quadrant II (-,+)"
	elif c.x < 0 and c.y < 0:
		return "Quadrant III (-,-)"
	else:
		return "Quadrant IV (+,-)"

func _on_daily_settlement(day: int) -> void:
	print("[ChunkSystem] === Overnight Settlement for %d Active Chunks (3x3 grid) ===" % active_chunks.size())
	for c in active_chunks.keys():
		var info = chunk_table.get(c, null)
		if info != null:
			var last_date: int = info["last_loaded_date"]
			var days_passed: int = day - last_date
			info["last_loaded_date"] = day
			chunk_settlement_executed.emit(c, days_passed)
			print(" -> Chunk %s settled. Days elapsed: %d" % [c, days_passed])
