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

# 当底片发生瓦片变更时，重新烘焙该区块贴图
func _on_chunk_tile_changed(chunk_coord: Vector2i, _local_pos: Vector2i, _tile_id: int) -> void:
	var chunk_data = terrain_manager.get_chunk(chunk_coord)
	if chunk_data != null and grass_terrain != null:
		var baked_img = grass_terrain.bake_chunk_image(chunk_coord, chunk_data.mask_image)
		chunk_data.set_baked_image(baked_img)
		var tex = chunk_data.get_or_create_baked_texture()
		if chunk_meshes.has(chunk_coord):
			var mesh_inst = chunk_meshes[chunk_coord]
			if mesh_inst != null and mesh_inst.material_override is ShaderMaterial:
				mesh_inst.material_override.set_shader_parameter("baked_chunk_texture", tex)

# 当草地生成器参数改变时，重新烘焙所有当前活动可见区块
func _on_grass_properties_changed() -> void:
	for c in chunk_meshes.keys():
		var chunk_data = terrain_manager.get_chunk(c)
		if chunk_data != null and grass_terrain != null:
			var baked_img = grass_terrain.bake_chunk_image(c, chunk_data.mask_image)
			chunk_data.set_baked_image(baked_img)
			var tex = chunk_data.get_or_create_baked_texture()
			var mesh_inst = chunk_meshes[c]
			if mesh_inst != null and mesh_inst.material_override is ShaderMaterial:
				mesh_inst.material_override.set_shader_parameter("baked_chunk_texture", tex)

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

	# PlaneMesh 512x512 (像广告牌一样贴在地面 XZ 平面上)
	var plane = PlaneMesh.new()
	plane.size = Vector2(TerrainChunk.CHUNK_SIZE, TerrainChunk.CHUNK_SIZE)
	mesh_inst.mesh = plane

	# Set local position to chunk world center
	var center = chunk_system.chunk_to_world_center(c)
	mesh_inst.position = center

	# 方案 B: 赋给材质提前烘焙好的静态 512x512 像素艺术贴图
	var chunk_data = terrain_manager.get_chunk(c)
	if chunk_data != null:
		var mat = ShaderMaterial.new()
		mat.shader = chunk_material_shader

		# 如果尚未烘焙，则执行一次烘焙
		if chunk_data.baked_image == null and grass_terrain != null:
			var baked_img = grass_terrain.bake_chunk_image(c, chunk_data.mask_image)
			chunk_data.set_baked_image(baked_img)

		var tex = chunk_data.get_or_create_baked_texture()
		mat.set_shader_parameter("baked_chunk_texture", tex)
		mat.set_shader_parameter("use_baked_texture", true)
		mesh_inst.material_override = mat

	return mesh_inst
