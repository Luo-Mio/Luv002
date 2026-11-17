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

# 直观噪波大小调节 (像素尺寸): 拉大斑块变大，拉小斑块变碎！
@export_range(16.0, 1024.0, 4.0, "suffix:px") var dark_patch_size: float = 200.0:
	set(val):
		dark_patch_size = val
		if dark_patch_noise != null and val > 0.0:
			dark_patch_noise.frequency = 1.0 / val
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

# 直观噪波大小调节 (像素尺寸): 拉大斑块变大，拉小斑块变碎！
@export_range(16.0, 1024.0, 4.0, "suffix:px") var light_patch_size: float = 120.0:
	set(val):
		light_patch_size = val
		if light_patch_noise != null and val > 0.0:
			light_patch_noise.frequency = 1.0 / val
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

# 微观扰动褶皱大小 (像素尺寸)
@export_range(8.0, 256.0, 2.0, "suffix:px") var warp_scale: float = 40.0:
	set(val):
		warp_scale = val
		if warp_noise != null and val > 0.0:
			warp_noise.frequency = 1.0 / val
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
# 微观像素颗粒感 (增强 2D/2.5D 手绘颗粒感)
# =========================================================
@export_group("Micro Grain (像素颗粒感)")
@export var enable_micro_grain: bool = true:
	set(val):
		enable_micro_grain = val
		_apply_parameters_to_material()

@export_range(0.0, 0.2, 0.01) var grain_strength: float = 0.04:
	set(val):
		grain_strength = val
		_apply_parameters_to_material()

# =========================================================
# 模式 1 兼容: 等高阶梯分级 (Contour Bands)
# =========================================================
@export_group("Mode 1: Contour Bands (等高阶梯分级参数)")
@export_range(16.0, 2048.0, 4.0, "suffix:px") var base_noise_size: float = 160.0:
	set(val):
		base_noise_size = val
		if base_noise != null and val > 0.0:
			base_noise.frequency = 1.0 / val
		_apply_parameters_to_material()

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
		nd.frequency = 1.0 / dark_patch_size
		nd.fractal_type = FastNoiseLite.FRACTAL_FBM
		nd.fractal_octaves = 3
		dark_patch_noise = nd

	if light_patch_noise == null:
		var nl = FastNoiseLite.new()
		nl.seed = 5678
		nl.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		nl.frequency = 1.0 / light_patch_size
		nl.fractal_type = FastNoiseLite.FRACTAL_FBM
		nl.fractal_octaves = 3
		light_patch_noise = nl

	if warp_noise == null:
		var nw = FastNoiseLite.new()
		nw.seed = 9999
		nw.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		nw.frequency = 1.0 / warp_scale
		nw.fractal_type = FastNoiseLite.FRACTAL_FBM
		nw.fractal_octaves = 2
		warp_noise = nw

	if base_noise == null:
		var nb = FastNoiseLite.new()
		nb.seed = 3333
		nb.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		nb.frequency = 1.0 / base_noise_size
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

	_material.set_shader_parameter("enable_micro_grain", enable_micro_grain)
	_material.set_shader_parameter("grain_strength", grain_strength)

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

	mat.set_shader_parameter("grass_enable_micro_grain", enable_micro_grain)
	mat.set_shader_parameter("grass_grain_strength", grain_strength)
