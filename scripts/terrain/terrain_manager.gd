class_name TerrainManager
extends Node

signal world_initialized(total_chunks: int, world_pixel_size: Vector2i)
signal chunk_tile_changed(chunk_coord: Vector2i, local_pos: Vector2i, new_tile_id: int)

# 15x15 Chunks centered at (0, 0): range from -7 to +7
const MAP_CHUNK_RADIUS: int = 7 # -7 to +7 -> 15 chunks
const MAP_CHUNKS_PER_AXIS: int = MAP_CHUNK_RADIUS * 2 + 1 # 15
const TOTAL_CHUNKS: int = MAP_CHUNKS_PER_AXIS * MAP_CHUNKS_PER_AXIS # 225

const CHUNK_SIZE: int = 512
const TOTAL_WORLD_PIXELS: int = MAP_CHUNKS_PER_AXIS * CHUNK_SIZE # 7680

# Half extent from center (0, 0): 7680 / 2 = 3840
const HALF_WORLD_PIXELS: int = TOTAL_WORLD_PIXELS / 2

# Dictionary storing all 225 chunk data: Vector2i -> TerrainChunk
var chunks: Dictionary = {}

func _ready() -> void:
	initialize_15x15_world()

# Initialize the 15x15 chunk world (225 chunks, all pixels set to 0 EMPTY)
func initialize_15x15_world() -> void:
	print("[TerrainManager] Initializing 15x15 chunks map (%dx%d game pixels)..." % [
		TOTAL_WORLD_PIXELS, TOTAL_WORLD_PIXELS
	])
	chunks.clear()

	var start_time = Time.get_ticks_msec()

	for cx in range(-MAP_CHUNK_RADIUS, MAP_CHUNK_RADIUS + 1):
		for cy in range(-MAP_CHUNK_RADIUS, MAP_CHUNK_RADIUS + 1):
			var coord = Vector2i(cx, cy)
			# Creates 512x512 RG8 chunk mask with R=0 (EMPTY) and G=0
			var chunk = TerrainChunk.new(coord)
			chunks[coord] = chunk

	var elapsed = Time.get_ticks_msec() - start_time
	print("[TerrainManager] Done! 225 Chunks initialized in %d ms." % elapsed)
	print("[TerrainManager] All %d pixels set to R=0 (EMPTY), G=0." % [TOTAL_WORLD_PIXELS * TOTAL_WORLD_PIXELS])
	world_initialized.emit(TOTAL_CHUNKS, Vector2i(TOTAL_WORLD_PIXELS, TOTAL_WORLD_PIXELS))

# Check if a chunk coordinate is within the 15x15 boundary [-7, 7]
func is_chunk_in_bounds(c: Vector2i) -> bool:
	return abs(c.x) <= MAP_CHUNK_RADIUS and abs(c.y) <= MAP_CHUNK_RADIUS

# Get chunk by coordinate
func get_chunk(c: Vector2i) -> TerrainChunk:
	return chunks.get(c, null)

# Convert global pixel coordinates (-3840 to +3839) to chunk coordinate and local pixel (0 to 511)
func global_pixel_to_chunk_and_local(gx: int, gy: int) -> Dictionary:
	var shifted_x = gx + 256
	var shifted_y = gy + 256
	var cx = int(floor(float(shifted_x) / float(CHUNK_SIZE)))
	var cy = int(floor(float(shifted_y) / float(CHUNK_SIZE)))
	var lx = posmod(shifted_x, CHUNK_SIZE)
	var ly = posmod(shifted_y, CHUNK_SIZE)
	return {
		"chunk": Vector2i(cx, cy),
		"local": Vector2i(lx, ly)
	}

# Get tile ID at global pixel coordinate
func get_global_tile(gx: int, gy: int) -> int:
	var loc = global_pixel_to_chunk_and_local(gx, gy)
	var chunk = get_chunk(loc["chunk"])
	if chunk != null:
		return chunk.get_tile(loc["local"].x, loc["local"].y)
	return TerrainTypes.ID.EMPTY

# Set tile ID at global pixel coordinate
func set_global_tile(gx: int, gy: int, tile_id: int) -> void:
	var loc = global_pixel_to_chunk_and_local(gx, gy)
	var chunk = get_chunk(loc["chunk"])
	if chunk != null:
		chunk.set_tile(loc["local"].x, loc["local"].y, tile_id)
		chunk_tile_changed.emit(loc["chunk"], loc["local"], tile_id)

# Export a single chunk mask as PNG for external tools (Photoshop/Aseprite)
func export_chunk_mask_png(chunk_coord: Vector2i, file_path: String) -> Error:
	var chunk = get_chunk(chunk_coord)
	if chunk == null:
		return ERR_DOES_NOT_EXIST
	return chunk.mask_image.save_png(file_path)

# Import an edited PNG into a chunk mask
func import_chunk_mask_png(chunk_coord: Vector2i, file_path: String) -> Error:
	var chunk = get_chunk(chunk_coord)
	if chunk == null:
		return ERR_DOES_NOT_EXIST
	var loaded_img = Image.load_from_file(file_path)
	if loaded_img == null or loaded_img.is_empty():
		return ERR_FILE_CORRUPT
	# Ensure RG8 format and 512x512 size
	if loaded_img.get_width() != CHUNK_SIZE or loaded_img.get_height() != CHUNK_SIZE:
		loaded_img.resize(CHUNK_SIZE, CHUNK_SIZE, Image.INTERPOLATE_NEAREST)
	loaded_img.convert(Image.FORMAT_RG8)
	chunk.mask_image = loaded_img
	chunk.is_dirty = true
	return OK
