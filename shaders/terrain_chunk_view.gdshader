shader_type spatial;
render_mode cull_disabled;

uniform sampler2D chunk_mask : filter_nearest;
uniform vec4 empty_color : source_color = vec4(0.12, 0.15, 0.18, 1.0);
uniform vec4 border_color : source_color = vec4(0.9, 0.75, 0.2, 1.0);

void fragment() {
	vec4 mask_data = texture(chunk_mask, UV);
	int terrain_id = int(round(mask_data.r * 255.0));
	int flags = int(round(mask_data.g * 255.0));

	vec3 col = empty_color.rgb;

	// Terrain Colors
	if (terrain_id == 0) {
		// EMPTY / Void
		// Subtle 32-pixel check pattern to visualize the empty canvas
		vec2 check = floor(UV * 512.0 / 32.0);
		float checker = mod(check.x + check.y, 2.0);
		col = mix(empty_color.rgb, empty_color.rgb * 1.15, checker);
	} else if (terrain_id == 1) {
		col = vec3(0.85, 0.75, 0.45); // Sand
	} else if (terrain_id == 2) {
		col = vec3(0.45, 0.32, 0.22); // Dirt
	} else if (terrain_id == 3) {
		col = vec3(0.25, 0.58, 0.28); // Grass
	} else if (terrain_id == 4) {
		col = vec3(0.35, 0.22, 0.14); // Farmland
	} else {
		col = vec3(0.6, 0.62, 0.65);  // Stone
	}

	// If G channel has FLAG_WET (bit 1), darken the tile
	if ((flags & 2) != 0) {
		col *= 0.75;
	}

	// Chunk border (1 pixel wide on edges of the 512x512 chunk)
	vec2 pixel_coord = UV * 512.0;
	if (pixel_coord.x < 1.0 || pixel_coord.x > 511.0 || pixel_coord.y < 1.0 || pixel_coord.y > 511.0) {
		col = border_color.rgb;
	}

	ALBEDO = col;
	ROUGHNESS = 0.95;
}
