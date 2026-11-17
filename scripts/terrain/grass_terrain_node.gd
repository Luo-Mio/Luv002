@tool
class_name GrassTerrainNode
extends BaseTerrainType

# --- Noise 1: Macro Base ---
@export_group("Noise 1: Macro Base (宏观形状)")
@export_range(0.002, 0.08, 0.001) var base_freq: float = 0.012:
	set(val):
		base_freq = val
		_update_material()

@export_range(1, 5) var base_octaves: int = 3:
	set(val):
		base_octaves = val
		_update_material()

# --- Noise 2: Domain Warp (Irrational sampling) ---
@export_group("Noise 2: Domain Warp (无理数扰动)")
@export_range(0.005, 0.15, 0.001) var warp_freq: float = 0.028:
	set(val):
		warp_freq = val
		_update_material()

@export_range(0.0, 80.0, 0.5) var warp_strength: float = 35.0:
	set(val):
		warp_strength = val
		_update_material()

@export_range(0.0, 6.28318, 0.01) var irrational_rot: float = 2.399963: # 黄金角
	set(val):
		irrational_rot = val
		_update_material()

# --- Contour & Stepping Bands ---
@export_group("Contours & Color Bands (阶梯色斑)")
@export_range(2, 6) var num_bands: int = 4:
	set(val):
		num_bands = val
		_update_material()

@export var color_band_0: Color = Color("1f3824"):
	set(val):
		color_band_0 = val
		_update_material()

@export var color_band_1: Color = Color("2e6133"):
	set(val):
		color_band_1 = val
		_update_material()

@export var color_band_2: Color = Color("4d9442"):
	set(val):
		color_band_2 = val
		_update_material()

@export var color_band_3: Color = Color("85c752"):
	set(val):
		color_band_3 = val
		_update_material()

@export var color_band_4: Color = Color("b8e073"):
	set(val):
		color_band_4 = val
		_update_material()

@export var color_band_5: Color = Color("e0f299"):
	set(val):
		color_band_5 = val
		_update_material()

@export var show_isolines: bool = false:
	set(val):
		show_isolines = val
		_update_material()

@export var isoline_color: Color = Color("142617"):
	set(val):
		isoline_color = val
		_update_material()

var _material: ShaderMaterial

func _init() -> void:
	terrain_id = 1
	terrain_name = "Grass (等高线草地)"

func _ensure_material() -> void:
	if _material == null:
		_material = ShaderMaterial.new()
		_material.shader = preload("res://shaders/grass_contour.gdshader")
		_apply_parameters_to_material()

func get_preview_material() -> ShaderMaterial:
	_ensure_material()
	return _material

func _update_material() -> void:
	if _material == null:
		return
	_apply_parameters_to_material()
	properties_changed.emit()

func _apply_parameters_to_material() -> void:
	if _material == null:
		return
	_material.set_shader_parameter("base_freq", base_freq)
	_material.set_shader_parameter("base_octaves", base_octaves)
	_material.set_shader_parameter("warp_freq", warp_freq)
	_material.set_shader_parameter("warp_strength", warp_strength)
	_material.set_shader_parameter("irrational_rot", irrational_rot)
	_material.set_shader_parameter("num_bands", num_bands)
	_material.set_shader_parameter("color_band_0", color_band_0)
	_material.set_shader_parameter("color_band_1", color_band_1)
	_material.set_shader_parameter("color_band_2", color_band_2)
	_material.set_shader_parameter("color_band_3", color_band_3)
	_material.set_shader_parameter("color_band_4", color_band_4)
	_material.set_shader_parameter("color_band_5", color_band_5)
	_material.set_shader_parameter("show_isolines", show_isolines)
	_material.set_shader_parameter("isoline_color", isoline_color)
