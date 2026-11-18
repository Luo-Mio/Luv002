@tool
class_name GrassTerrainNode
extends BaseTerrainType

# =========================================================
# 着色模式切换: 0 = 补丁遮罩模式 (推荐), 1 = 等高阶梯分级模式
# =========================================================
@export_enum("Patch Overlay (大底色+斑块遮罩)", "Contour Bands (等高阶梯分级)") var color_mode: int = 0:
	set(val):
		color_mode = val
		_apply_parameters_to_material()

# =========================================================
# 图案等比几何缩放 (纯粹放大/缩小现有图案形状，不改变噪波内部形态)
# =========================================================
@export_group("Pattern Zoom (图案等比缩放)")
@export_range(0.1, 5.0, 0.05) var patch_zoom: float = 1.0:
	set(val):
		patch_zoom = val
		_apply_parameters_to_material()

# =========================================================
# 模式 0: 主草地大底色 (占 ~75% 面积)
# =========================================================
@export_group("Mode 0: Base Grass (主草地大底色)")
@export var base_color: Color = Color("3a7d44"): # 丰茂中绿
	set(val):
		base_color = val
		_apply_parameters_to_material()

# =========================================================
# 模式 0: 深色草斑补丁 (Dark Patch)
# =========================================================
@export_group("Mode 0: Dark Grass Patch (深色草斑补丁)")
@export var enable_dark_patch: bool = true:
	set(val):
		enable_dark_patch = val
		_apply_parameters_to_material()

@export var dark_patch_color: Color = Color("214e2b"): # 阴影深绿
	set(val):
		dark_patch_color = val
		_apply_parameters_to_material()

@export_range(0.0, 1.0, 0.01) var dark_patch_threshold: float = 0.58:
	set(val):
		dark_patch_threshold = val
		_apply_parameters_to_material()

@export var dark_patch_noise: FastNoiseLite:
	set(val):
		if dark_patch_noise != null and dark_patch_noise.changed.is_connected(_on_noise_changed):
			dark_patch_noise.changed.disconnect(_on_noise_changed)
		dark_patch_noise = val
		if dark_patch_noise != null:
			dark_patch_noise.changed.connect(_on_noise_changed)
		_setup_noise_textures()

# =========================================================
# 模式 0: 浅色草斑补丁 (Light Patch)
# =========================================================
@export_group("Mode 0: Light Grass Patch (浅色草斑补丁)")
@export var enable_light_patch: bool = true:
	set(val):
		enable_light_patch = val
		_apply_parameters_to_material()

@export var light_patch_color: Color = Color("6cb83e"): # 鲜亮嫩芽绿
	set(val):
		light_patch_color = val
		_apply_parameters_to_material()

@export_range(0.0, 1.0, 0.01) var light_patch_threshold: float = 0.62:
	set(val):
		light_patch_threshold = val
		_apply_parameters_to_material()

@export var light_patch_noise: FastNoiseLite:
	set(val):
		if light_patch_noise != null and light_patch_noise.changed.is_connected(_on_noise_changed):
			light_patch_noise.changed.disconnect(_on_noise_changed)
		light_patch_noise = val
		if light_patch_noise != null:
			light_patch_noise.changed.connect(_on_noise_changed)
		_setup_noise_textures()

# =========================================================
# 领域扭曲: 无理数黄金角自扰动场 (赋予斑块手绘苔藓有机边缘)
# =========================================================
@export_group("Domain Warp Math (无理数自扰动场)")
@export var enable_warp: bool = true:
	set(val):
		enable_warp = val
		_apply_parameters_to_material()

@export_range(0.0, 100.0, 0.5) var warp_strength: float = 25.0:
	set(val):
		warp_strength = val
		_apply_parameters_to_material()

@export_range(0.0, 6.28318, 0.01) var irrational_rot: float = 2.399963: # 黄金角 137.5°
	set(val):
		irrational_rot = val
		_apply_parameters_to_material()

@export var warp_noise: FastNoiseLite:
	set(val):
		if warp_noise != null and warp_noise.changed.is_connected(_on_noise_changed):
			warp_noise.changed.disconnect(_on_noise_changed)
		warp_noise = val
		if warp_noise != null:
			warp_noise.changed.connect(_on_noise_changed)
		_setup_noise_textures()

# =========================================================
# 模式 1 兼容: 等高阶梯分级 (Contour Bands)
# =========================================================
@export_group("Mode 1: Contour Bands (等高阶梯分级参数)")
@export var base_noise: FastNoiseLite:
	set(val):
		if base_noise != null and base_noise.changed.is_connected(_on_noise_changed):
			base_noise.changed.disconnect(_on_noise_changed)
		base_noise = val
		if base_noise != null:
			base_noise.changed.connect(_on_noise_changed)
		_setup_noise_textures()

@export_range(2, 6, 1) var num_bands: int = 4:
	set(val):
		num_bands = val
		_apply_parameters_to_material()

@export_range(0.5, 4.0, 0.05) var noise_contrast: float = 1.9:
	set(val):
		noise_contrast = val
		_apply_parameters_to_material()

@export_range(-0.5, 0.5, 0.02) var noise_offset: float = 0.0:
	set(val):
		noise_offset = val
		_apply_parameters_to_material()

@export var color_band_0: Color = Color("1c381f"):
	set(val):
		color_band_0 = val
		_apply_parameters_to_material()
@export var color_band_1: Color = Color("2e6131"):
	set(val):
		color_band_1 = val
		_apply_parameters_to_material()
@export var color_band_2: Color = Color("488f3f"):
	set(val):
		color_band_2 = val
		_apply_parameters_to_material()
@export var color_band_3: Color = Color("7bc244"):
	set(val):
		color_band_3 = val
		_apply_parameters_to_material()
@export var color_band_4: Color = Color("aee060"):
	set(val):
		color_band_4 = val
		_apply_parameters_to_material()
@export var color_band_5: Color = Color("e0f78d"):
	set(val):
		color_band_5 = val
		_apply_parameters_to_material()

@export var show_isolines: bool = false:
	set(val):
		show_isolines = val
		_apply_parameters_to_material()
@export var isoline_color: Color = Color("122114"):
	set(val):
		isoline_color = val
		_apply_parameters_to_material()

var _material: ShaderMaterial
var _base_tex: NoiseTexture2D
var _dark_tex: NoiseTexture2D
var _light_tex: NoiseTexture2D
var _warp_tex: NoiseTexture2D

func _init() -> void:
	terrain_id = 1
	terrain_name = "Grass (大底色+补丁草地)"
	_init_default_noises()

func _init_default_noises() -> void:
	if dark_patch_noise == null:
		var nd = FastNoiseLite.new()
		nd.seed = 1234
		nd.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		nd.frequency = 0.005
		nd.fractal_type = FastNoiseLite.FRACTAL_FBM
		nd.fractal_octaves = 3
		dark_patch_noise = nd

	if light_patch_noise == null:
		var nl = FastNoiseLite.new()
		nl.seed = 5678
		nl.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		nl.frequency = 0.008
		nl.fractal_type = FastNoiseLite.FRACTAL_FBM
		nl.fractal_octaves = 3
		light_patch_noise = nl

	if warp_noise == null:
		var nw = FastNoiseLite.new()
		nw.seed = 9999
		nw.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		nw.frequency = 0.018
		nw.fractal_type = FastNoiseLite.FRACTAL_FBM
		nw.fractal_octaves = 2
		warp_noise = nw

	if base_noise == null:
		var nb = FastNoiseLite.new()
		nb.seed = 3333
		nb.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		nb.frequency = 0.006
		nb.fractal_type = FastNoiseLite.FRACTAL_FBM
		nb.fractal_octaves = 3
		base_noise = nb

func _setup_noise_textures() -> void:
	if dark_patch_noise != null:
		if _dark_tex == null:
			_dark_tex = NoiseTexture2D.new()
			_dark_tex.width = 512
			_dark_tex.height = 512
			_dark_tex.seamless = true
			_dark_tex.generate_mipmaps = false
		_dark_tex.noise = dark_patch_noise

	if light_patch_noise != null:
		if _light_tex == null:
			_light_tex = NoiseTexture2D.new()
			_light_tex.width = 512
			_light_tex.height = 512
			_light_tex.seamless = true
			_light_tex.generate_mipmaps = false
		_light_tex.noise = light_patch_noise

	if warp_noise != null:
		if _warp_tex == null:
			_warp_tex = NoiseTexture2D.new()
			_warp_tex.width = 512
			_warp_tex.height = 512
			_warp_tex.seamless = true
			_warp_tex.generate_mipmaps = false
		_warp_tex.noise = warp_noise

	if base_noise != null:
		if _base_tex == null:
			_base_tex = NoiseTexture2D.new()
			_base_tex.width = 512
			_base_tex.height = 512
			_base_tex.seamless = true
			_base_tex.generate_mipmaps = false
		_base_tex.noise = base_noise

	_apply_parameters_to_material()

func _on_noise_changed() -> void:
	_apply_parameters_to_material()

func _ensure_material() -> void:
	if _material == null:
		_material = ShaderMaterial.new()
		_material.shader = preload("res://shaders/grass_contour.gdshader")
		_setup_noise_textures()
	_apply_parameters_to_material()

func get_preview_material() -> ShaderMaterial:
	_ensure_material()
	return _material

func _apply_parameters_to_material() -> void:
	if _material == null:
		return

	_material.set_shader_parameter("color_mode", color_mode)
	_material.set_shader_parameter("patch_zoom", patch_zoom)
	_material.set_shader_parameter("base_color", base_color)
	_material.set_shader_parameter("enable_dark_patch", enable_dark_patch)
	_material.set_shader_parameter("dark_patch_color", dark_patch_color)
	_material.set_shader_parameter("dark_patch_threshold", dark_patch_threshold)
	if _dark_tex != null:
		_material.set_shader_parameter("dark_patch_noise_tex", _dark_tex)

	_material.set_shader_parameter("enable_light_patch", enable_light_patch)
	_material.set_shader_parameter("light_patch_color", light_patch_color)
	_material.set_shader_parameter("light_patch_threshold", light_patch_threshold)
	if _light_tex != null:
		_material.set_shader_parameter("light_patch_noise_tex", _light_tex)

	_material.set_shader_parameter("enable_warp", enable_warp)
	_material.set_shader_parameter("warp_strength", warp_strength)
	_material.set_shader_parameter("irrational_rot", irrational_rot)
	if _warp_tex != null:
		_material.set_shader_parameter("warp_noise_tex", _warp_tex)

	# Mode 1
	if _base_tex != null:
		_material.set_shader_parameter("base_noise_tex", _base_tex)
	_material.set_shader_parameter("noise_contrast", noise_contrast)
	_material.set_shader_parameter("noise_offset", noise_offset)
	_material.set_shader_parameter("num_bands", num_bands)
	_material.set_shader_parameter("color_band_0", color_band_0)
	_material.set_shader_parameter("color_band_1", color_band_1)
	_material.set_shader_parameter("color_band_2", color_band_2)
	_material.set_shader_parameter("color_band_3", color_band_3)
	_material.set_shader_parameter("color_band_4", color_band_4)
	_material.set_shader_parameter("color_band_5", color_band_5)
	_material.set_shader_parameter("show_isolines", show_isolines)
	_material.set_shader_parameter("isoline_color", isoline_color)

	properties_changed.emit()

# 将草地 Shader 参数同步给 3D 区块着色材质
func apply_to_chunk_material(mat: ShaderMaterial) -> void:
	if mat == null:
		return
	_setup_noise_textures()
	mat.set_shader_parameter("grass_patch_zoom", patch_zoom)
	mat.set_shader_parameter("grass_base_color", base_color)
	mat.set_shader_parameter("grass_enable_dark_patch", enable_dark_patch)
	mat.set_shader_parameter("grass_dark_patch_color", dark_patch_color)
	mat.set_shader_parameter("grass_dark_threshold", dark_patch_threshold)
	if _dark_tex != null:
		mat.set_shader_parameter("grass_dark_noise_tex", _dark_tex)

	mat.set_shader_parameter("grass_enable_light_patch", enable_light_patch)
	mat.set_shader_parameter("grass_light_patch_color", light_patch_color)
	mat.set_shader_parameter("grass_light_threshold", light_patch_threshold)
	if _light_tex != null:
		mat.set_shader_parameter("grass_light_noise_tex", _light_tex)

	mat.set_shader_parameter("grass_enable_warp", enable_warp)
	mat.set_shader_parameter("grass_warp_strength", warp_strength)
	mat.set_shader_parameter("grass_irrational_rot", irrational_rot)
	if _warp_tex != null:
		mat.set_shader_parameter("grass_warp_noise_tex", _warp_tex)

# =========================================================
# 方案 B 核心: 提前烘焙 512x256 静态像素艺术贴图 (像广告牌贴在地面上)
# 彻底消除每帧计算带来的亚像素边缘抖动，点对点精准匹配 2:1 投影的屏幕像素！
# =========================================================
const BAKE_WIDTH: int = 512
const BAKE_HEIGHT: int = 256 # 512x256: 完美点对点契合 2:1 俯视正交投影的 512x256 屏幕像素！

func bake_chunk_image(chunk_coord: Vector2i, mask: Image = null) -> Image:
	var img = Image.create(BAKE_WIDTH, BAKE_HEIGHT, false, Image.FORMAT_RGBA8)
	var byte_data = PackedByteArray()
	byte_data.resize(BAKE_WIDTH * BAKE_HEIGHT * 4)

	# 预先提取颜色分量 (0~255)
	var bc_r = int(clamp(base_color.r, 0.0, 1.0) * 255.0)
	var bc_g = int(clamp(base_color.g, 0.0, 1.0) * 255.0)
	var bc_b = int(clamp(base_color.b, 0.0, 1.0) * 255.0)

	var dc_r = int(clamp(dark_patch_color.r, 0.0, 1.0) * 255.0)
	var dc_g = int(clamp(dark_patch_color.g, 0.0, 1.0) * 255.0)
	var dc_b = int(clamp(dark_patch_color.b, 0.0, 1.0) * 255.0)

	var lc_r = int(clamp(light_patch_color.r, 0.0, 1.0) * 255.0)
	var lc_g = int(clamp(light_patch_color.g, 0.0, 1.0) * 255.0)
	var lc_b = int(clamp(light_patch_color.b, 0.0, 1.0) * 255.0)

	# 空地背景颜色 (暗色 32x16 棋盘格，投影后为 32x32 世界单位)
	var empty_base_r = int(0.12 * 255.0)
	var empty_base_g = int(0.15 * 255.0)
	var empty_base_b = int(0.18 * 255.0)
	var empty_alt_r = int(0.14 * 255.0)
	var empty_alt_g = int(0.17 * 255.0)
	var empty_alt_b = int(0.20 * 255.0)

	# 边框金黄色 (1 像素标示区块边界)
	var border_r = int(0.9 * 255.0)
	var border_g = int(0.75 * 255.0)
	var border_b = int(0.2 * 255.0)

	var cos_a = cos(irrational_rot)
	var sin_a = sin(irrational_rot)
	var zoom_factor = max(patch_zoom, 0.001)

	var world_origin_x = float(chunk_coord.x * 512)
	var world_origin_y = float(chunk_coord.y * 512)

	var idx = 0
	for ly in range(BAKE_HEIGHT):
		# 256 行精准对应地面深度 512 世界单位 (每行跨度 2.0)
		var mask_y = ly * 2
		var wy = world_origin_y + float(mask_y)

		for lx in range(BAKE_WIDTH):
			# 检查底片 R 通道 (地皮类型)
			var tile_id = 1
			if mask != null:
				var m_col = mask.get_pixel(lx, mask_y)
				tile_id = int(round(m_col.r * 255.0))

			if tile_id == 0:
				# 虚空/空地 (32x16 棋盘格)
				var cx = (lx / 32) % 2
				var cy = (ly / 16) % 2
				var is_alt = (cx + cy) % 2 == 1
				byte_data[idx] = empty_alt_r if is_alt else empty_base_r
				byte_data[idx + 1] = empty_alt_g if is_alt else empty_base_g
				byte_data[idx + 2] = empty_alt_b if is_alt else empty_base_b
				byte_data[idx + 3] = 255
			else:
				# 草地 (ID = 1): 使用世界坐标无缝采样
				var wx = world_origin_x + float(lx)

				# 1. 无理数自扰动场 (Domain Warp)
				var coord_x = wx
				var coord_y = wy
				if enable_warp and warp_noise != null:
					var warp_uv_x = coord_x / 512.0
					var warp_uv_y = coord_y / 512.0
					var sub_x = (cos_a * warp_uv_x - sin_a * warp_uv_y) * 1.6180339887
					var sub_y = (sin_a * warp_uv_x + cos_a * warp_uv_y) * 1.6180339887
					var nx = (warp_noise.get_noise_2d(warp_uv_x * 512.0, warp_uv_y * 512.0) + 1.0) * 0.5 * 2.0 - 1.0
					var ny = (warp_noise.get_noise_2d(sub_x * 512.0, sub_y * 512.0) + 1.0) * 0.5 * 2.0 - 1.0
					coord_x += nx * warp_strength
					coord_y += ny * warp_strength

				# 2. 图案等比缩放
				var sx = coord_x / zoom_factor
				var sy = coord_y / zoom_factor

				# 3. 基础底色
				var pr = bc_r
				var pg = bc_g
				var pb = bc_b

				# 4. 深色斑块
				if enable_dark_patch and dark_patch_noise != null:
					var nd = (dark_patch_noise.get_noise_2d(sx, sy) + 1.0) * 0.5
					if nd > dark_patch_threshold:
						pr = dc_r
						pg = dc_g
						pb = dc_b

				# 5. 浅色斑块 (叠加上层)
				if enable_light_patch and light_patch_noise != null:
					var nl = (light_patch_noise.get_noise_2d(sx, sy) + 1.0) * 0.5
					if nl > light_patch_threshold:
						pr = lc_r
						pg = lc_g
						pb = lc_b

				byte_data[idx] = pr
				byte_data[idx + 1] = pg
				byte_data[idx + 2] = pb
				byte_data[idx + 3] = 255

			# 区块 1 像素外框
			if lx == 0 or lx == (BAKE_WIDTH - 1) or ly == 0 or ly == (BAKE_HEIGHT - 1):
				byte_data[idx] = border_r
				byte_data[idx + 1] = border_g
				byte_data[idx + 2] = border_b
				byte_data[idx + 3] = 255

			idx += 4

	img.set_data(BAKE_WIDTH, BAKE_HEIGHT, false, Image.FORMAT_RGBA8, byte_data)
	return img
