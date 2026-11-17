class_name TerrainChunkRenderer
extends Node3D

@export var terrain_manager: TerrainManager
@export var chunk_system: ChunkSystem
@export var grass_terrain: GrassTerrainNode

# Pool of 9 MeshInstance3D nodes for the 3x3 active chunks
var chunk_meshes: Dictionary = {} # Vector2i -> MeshInstance3D

var chunk_material_shader: Shader

func _ready() -> void:
	chunk_material_shader = preload("res://shaders/terrain_chunk_view.gdshader")

	if grass_terrain == null:
		grass_terrain = GrassTerrainNode.new()
		add_child(grass_terrain)

	if grass_terrain != null:
		grass_terrain.properties_changed.connect(_on_grass_properties_changed)

	if chunk_system != null:
		chunk_system.player_chunk_changed.connect(_on_player_chunk_changed)

	if terrain_manager != null:
		terrain_manager.chunk_tile_changed.connect(_on_chunk_tile_changed)

	call_deferred("_initial_setup")

func _initial_setup() -> void:
	if chunk_system != null:
		_update_visible_chunks(chunk_system.current_player_chunk)

func _on_player_chunk_changed(_old: Vector2i, new_chunk: Vector2i) -> void:
	_update_visible_chunks(new_chunk)

func _on_chunk_tile_changed(chunk_coord: Vector2i, _local_pos: Vector2i, _tile_id: int) -> void:
	if chunk_meshes.has(chunk_coord):
		var chunk_data = terrain_manager.get_chunk(chunk_coord)
		if chunk_data != null and chunk_data.is_dirty:
			chunk_data.get_or_create_texture()

func _on_grass_properties_changed() -> void:
	for c in chunk_meshes.keys():
		var mesh_inst = chunk_meshes[c]
		if mesh_inst != null and mesh_inst.material_override is ShaderMaterial:
			grass_terrain.apply_to_chunk_material(mesh_inst.material_override)

func _update_visible_chunks(center_chunk: Vector2i) -> void:
	if terrain_manager == null or center_chunk.x == 999999:
		return

	var needed_coords: Dictionary = {}

	# 3x3 grid around center chunk
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			var c = center_chunk + Vector2i(dx, dy)
			if terrain_manager.is_chunk_in_bounds(c):
				needed_coords[c] = true

	# Remove chunks no longer needed
	var to_remove: Array = []
	for c in chunk_meshes.keys():
		if not needed_coords.has(c):
			chunk_meshes[c].queue_free()
			to_remove.append(c)

	for c in to_remove:
		chunk_meshes.erase(c)

	# Add or update needed chunks
	for c in needed_coords.keys():
		if not chunk_meshes.has(c):
			var mesh_inst = _create_chunk_mesh(c)
			add_child(mesh_inst)
			chunk_meshes[c] = mesh_inst

func _create_chunk_mesh(c: Vector2i) -> MeshInstance3D:
	var mesh_inst = MeshInstance3D.new()
	mesh_inst.name = "ChunkMesh_%d_%d" % [c.x, c.y]

	# PlaneMesh 512x512
	var plane = PlaneMesh.new()
	plane.size = Vector2(TerrainChunk.CHUNK_SIZE, TerrainChunk.CHUNK_SIZE)
	mesh_inst.mesh = plane

	# Set local position to chunk world center
	var center = chunk_system.chunk_to_world_center(c)
	mesh_inst.position = center

	# Assign shader material with chunk mask texture
	var chunk_data = terrain_manager.get_chunk(c)
	if chunk_data != null:
		var mat = ShaderMaterial.new()
		mat.shader = chunk_material_shader
		var tex = chunk_data.get_or_create_texture()
		mat.set_shader_parameter("chunk_mask", tex)
		if grass_terrain != null:
			grass_terrain.apply_to_chunk_material(mat)
		mesh_inst.material_override = mat

	return mesh_inst
