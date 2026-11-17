shader_type spatial;
render_mode cull_disabled;

uniform vec4 bg_color : source_color = vec4(0.16, 0.24, 0.18, 1.0);
uniform vec4 cell_line_color : source_color = vec4(0.22, 0.32, 0.24, 1.0);
uniform vec4 chunk_border_color : source_color = vec4(0.9, 0.75, 0.25, 1.0);
uniform vec4 origin_axis_color : source_color = vec4(0.9, 0.3, 0.3, 1.0);

void fragment() {
	// World position in game pixel units
	vec2 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xz;

	// Sub-grid lines (every 64 pixels)
	vec2 cell_fract = fract(world_pos / 64.0);
	float cell_line = float(cell_fract.x < 0.03 || cell_fract.y < 0.03);

	// Chunk border lines (every 512 pixels, chunk (0,0) centered at origin [-256, +256])
	vec2 chunk_fract = fract((world_pos + 256.0) / 512.0);
	float chunk_line = float(chunk_fract.x < 0.006 || chunk_fract.y < 0.006);

	// World Origin Axes (X=0 and Z=0)
	float axis_line = float(abs(world_pos.x) < 2.0 || abs(world_pos.y) < 2.0);

	vec4 col = bg_color;
	if (cell_line > 0.5) col = cell_line_color;
	if (chunk_line > 0.5) col = chunk_border_color;
	if (axis_line > 0.5) col = origin_axis_color;

	ALBEDO = col.rgb;
	ROUGHNESS = 0.95;
}
