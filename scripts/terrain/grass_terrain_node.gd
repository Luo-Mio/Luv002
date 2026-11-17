@tool
class_name GrassTerrainNode
extends BaseTerrainType

# =========================================================
# 完整噪波生成器 1: 宏观基础形状 (Base Noise Generator)
# =========================================================
@export_group("Noise 1: Macro Base (完整宏观噪波生成器)")
@export var base_noise: FastNoiseLite:
	set(val):
		if base_noise != null and base_noise.changed.is_connected(_on_noise_changed):
			base_noise.changed.disconnect(_on_noise_changed)
		base_noise = val
		if base_noise != null:
			base_noise.changed.connect(_on_noise_changed)
		_setup_noise_textures()

# =========================================================
# 完整噪波生成器 2: 微观扰动场 (Warp Noise Generator)
# =========================================================
@export_group("Noise 2: Domain Warp (完整微观噪波生成器)")
@export var warp_noise: FastNoiseLite:
	set(val):
		if warp_noise != null and warp_noise.changed.is_connected(_on_noise_changed):
			warp_noise.changed.disconnect(_on_noise_changed)
		warp_noise = val
		if warp_noise != null:
			warp_noise.changed.connect(_on_noise_changed)
		_setup_noise_textures()

# =========================================================
# 领域扭曲与无理数采样参数
# =========================================================
@export_group("Domain Warp Math (无理数自扰动)")
@export_range(0.0, 100.0, 0.5) var warp_strength: float = 30.0:
	set(val):
		warp_strength = val
		_apply_parameters_to_material()

@export_range(0.0, 6.28318, 0.01) var irrational_rot: float = 2.399963: # 黄金角 137.5°
	set(val):
		irrational_rot = val
		_apply_parameters_to_material()

# =========================================================
# 阶梯色斑与直方图拉伸 (解决颜色聚集在中间两档的核心功能)
# =========================================================
@export_group("Contours & Histogram (阶梯色斑与直方图扩展)")
@export_range(2, 6, 1) var num_bands: int = 4:
	set(val):
		num_bands = val
		_apply_parameters_to_material()

# 对比度：将聚集在 0.4~0.6 的钟形正态分布向两端拉伸，使得各阶颜色均等铺开！
@export_range(0.5, 4.0, 0.05) var noise_contrast: float = 1.9:
	set(val):
		noise_contrast = val
		_apply_parameters_to_material()

@export_range(-0.5, 0.5, 0.02) var noise_offset: float = 0.0:
	set(val):
		noise_offset = val
		_apply_parameters_to_material()

@export var color_band_0: Color = Color("1c381f"): # 极深暗绿
	set(val):
		color_band_0 = val
		_apply_parameters_to_material()

@export var color_band_1: Color = Color("2e6131"): # 基础草绿
	set(val):
		color_band_1 = val
		_apply_parameters_to_material()

@export var color_band_2: Color = Color("488f3f"): # 丰茂中绿
	set(val):
		color_band_2 = val
		_apply_parameters_to_material()

@export var color_band_3: Color = Color("7bc244"): # 鲜亮嫩绿
	set(val):
		color_band_3 = val
		_apply_parameters_to_material()

@export var color_band_4: Color = Color("aee060"): # 阳光黄绿
	set(val):
		color_band_4 = val
		_apply_parameters_to_material()

@export var color_band_5: Color = Color("e0f78d"): # 浅浅高光
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
var _warp_tex: NoiseTexture2D

func _init() -> void:
	terrain_id = 1
	terrain_name = "Grass (等高线草地)"
	_init_default_noises()

func _init_default_noises() -> void:
	if base_noise == null:
		var n1 = FastNoiseLite.new()
		n1.seed = 1234
		n1.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		n1.frequency = 0.008
		n1.fractal_type = FastNoiseLite.FRACTAL_FBM
		n1.fractal_octaves = 3
		base_noise = n1 # setter will handle connection

	if warp_noise == null:
		var n2 = FastNoiseLite.new()
		n2.seed = 5678
		n2.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
		n2.frequency = 0.02
		n2.fractal_type = FastNoiseLite.FRACTAL_FBM
		n2.fractal_octaves = 2
		warp_noise = n2 # setter will handle connection

func _setup_noise_textures() -> void:
	if base_noise != null:
		if _base_tex == null:
			_base_tex = NoiseTexture2D.new()
			_base_tex.width = 512
			_base_tex.height = 512
			_base_tex.seamless = false
			_base_tex.generate_mipmaps = false
		_base_tex.noise = base_noise

	if warp_noise != null:
		if _warp_tex == null:
			_warp_tex = NoiseTexture2D.new()
			_warp_tex.width = 512
			_warp_tex.height = 512
			_warp_tex.seamless = false
			_warp_tex.generate_mipmaps = false
		_warp_tex.noise = warp_noise

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

	if _base_tex != null:
		_material.set_shader_parameter("base_noise_tex", _base_tex)
	if _warp_tex != null:
		_material.set_shader_parameter("warp_noise_tex", _warp_tex)

	_material.set_shader_parameter("warp_strength", warp_strength)
	_material.set_shader_parameter("irrational_rot", irrational_rot)
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
