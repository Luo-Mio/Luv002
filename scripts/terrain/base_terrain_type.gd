@tool
class_name BaseTerrainType
extends Node

signal properties_changed

@export var terrain_id: int = 0:
	set(val):
		terrain_id = val
		properties_changed.emit()

@export var terrain_name: String = "BaseTerrain":
	set(val):
		terrain_name = val
		properties_changed.emit()

# Virtual: returns the ShaderMaterial used for real-time 512x512 preview
func get_preview_material() -> ShaderMaterial:
	return null

# Virtual: generates or samples the tile ID / color for a specific coordinate
func sample_cell(_x: int, _y: int) -> int:
	return terrain_id
