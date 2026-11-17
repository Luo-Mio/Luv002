@tool
class_name TerrainStudioController
extends Control

@export var active_terrain: BaseTerrainType:
	set(val):
		if active_terrain != null and active_terrain.properties_changed.is_connected(_on_terrain_properties_changed):
			active_terrain.properties_changed.disconnect(_on_terrain_properties_changed)
		active_terrain = val
		if active_terrain != null:
			active_terrain.properties_changed.connect(_on_terrain_properties_changed)
		_setup_preview()

@onready var preview_rect: ColorRect = $CenterContainer/VBoxContainer/PreviewFrame/PreviewRect
@onready var info_label: Label = $CenterContainer/VBoxContainer/InfoLabel

func _ready() -> void:
	if active_terrain == null and has_node("TerrainTypes/GrassTerrain"):
		active_terrain = get_node("TerrainTypes/GrassTerrain")
	_setup_preview()

func _on_terrain_properties_changed() -> void:
	# Material shader parameters are already updated dynamically on GPU!
	# We only update the label text here.
	_update_label()

func _setup_preview() -> void:
	if preview_rect == null:
		preview_rect = get_node_or_null("CenterContainer/VBoxContainer/PreviewFrame/PreviewRect")
	if preview_rect != null and active_terrain != null:
		preview_rect.material = active_terrain.get_preview_material()
	_update_label()

func _update_label() -> void:
	if info_label == null:
		info_label = get_node_or_null("CenterContainer/VBoxContainer/InfoLabel")
	if info_label != null and active_terrain != null:
		info_label.text = "地皮编号 [%d] - %s | 512×512 区块 1:1 实时预览" % [
			active_terrain.terrain_id, active_terrain.terrain_name
		]
