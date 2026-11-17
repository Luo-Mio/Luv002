class_name TerrainChunk
extends RefCounted

const CHUNK_SIZE: int = 512

var coord: Vector2i
var mask_image: Image
var gpu_texture: ImageTexture
var is_dirty: bool = false

func _init(p_coord: Vector2i) -> void:
	coord = p_coord
	_initialize_empty_mask()

# Initialize a 512x512 RG8 mask, filling all pixels with R=0 (EMPTY) and G=0 (NO FLAGS)
func _initialize_empty_mask() -> void:
	mask_image = Image.create(CHUNK_SIZE, CHUNK_SIZE, false, Image.FORMAT_RG8)
	mask_image.fill(Color(0.0, 0.0, 0.0, 0.0))
	is_dirty = true

# Fill entire 512x512 mask with a specific terrain ID and optional flags
func fill_chunk(type_id: int, flags: int = 0) -> void:
	var col = Color(float(type_id) / 255.0, float(flags) / 255.0, 0.0, 1.0)
	mask_image.fill(col)
	is_dirty = true

# Get terrain ID at local coordinate (0 to 511)
func get_tile(local_x: int, local_y: int) -> int:
	if local_x < 0 or local_x >= CHUNK_SIZE or local_y < 0 or local_y >= CHUNK_SIZE:
		return TerrainTypes.ID.EMPTY
	var col = mask_image.get_pixel(local_x, local_y)
	return int(round(col.r * 255.0))

# Set terrain ID at local coordinate
func set_tile(local_x: int, local_y: int, type_id: int) -> void:
	if local_x < 0 or local_x >= CHUNK_SIZE or local_y < 0 or local_y >= CHUNK_SIZE:
		return
	var col = mask_image.get_pixel(local_x, local_y)
	col.r = float(type_id) / 255.0
	mask_image.set_pixel(local_x, local_y, col)
	is_dirty = true

# Get G channel flags at local coordinate
func get_flags(local_x: int, local_y: int) -> int:
	if local_x < 0 or local_x >= CHUNK_SIZE or local_y < 0 or local_y >= CHUNK_SIZE:
		return 0
	var col = mask_image.get_pixel(local_x, local_y)
	return int(round(col.g * 255.0))

# Set or clear a specific flag on the G channel
func set_flag(local_x: int, local_y: int, flag: int, enabled: bool) -> void:
	if local_x < 0 or local_x >= CHUNK_SIZE or local_y < 0 or local_y >= CHUNK_SIZE:
		return
	var col = mask_image.get_pixel(local_x, local_y)
	var current_flags = int(round(col.g * 255.0))
	if enabled:
		current_flags = TerrainTypes.set_flag(current_flags, flag)
	else:
		current_flags = TerrainTypes.clear_flag(current_flags, flag)
	col.g = float(current_flags) / 255.0
	mask_image.set_pixel(local_x, local_y, col)
	is_dirty = true

# Create or update GPU ImageTexture
func get_or_create_texture() -> ImageTexture:
	if gpu_texture == null:
		gpu_texture = ImageTexture.create_from_image(mask_image)
		is_dirty = false
	elif is_dirty:
		gpu_texture.update(mask_image)
		is_dirty = false
	return gpu_texture
