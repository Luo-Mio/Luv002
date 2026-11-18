shader_type spatial;
render_mode cull_disabled;

uniform sampler2D chunk_mask : filter_nearest;
uniform vec4 empty_color : source_color = vec4(0.12, 0.15, 0.18, 1.0);
uniform vec4 border_color : source_color = vec4(0.9, 0.75, 0.2, 1.0);

// =========================================================
// 草地 (ID = 1) 专属参数: 大底色 + 阈值斑块遮罩 (世界空间连续采样)
// =========================================================
uniform float grass_patch_zoom : hint_range(0.1, 5.0) = 1.0; // 图案等比整体缩放 (保持形状纯缩放)
uniform vec4 grass_base_color : source_color = vec4(0.23, 0.49, 0.27, 1.0);

uniform bool grass_enable_dark_patch = true;
uniform vec4 grass_dark_patch_color : source_color = vec4(0.13, 0.28, 0.17, 1.0);
uniform float grass_dark_threshold : hint_range(0.0, 1.0) = 0.58;
uniform sampler2D grass_dark_noise_tex : filter_linear, repeat_enable;

uniform bool grass_enable_light_patch = true;
uniform vec4 grass_light_patch_color : source_color = vec4(0.43, 0.76, 0.24, 1.0);
uniform float grass_light_threshold : hint_range(0.0, 1.0) = 0.62;
uniform sampler2D grass_light_noise_tex : filter_linear, repeat_enable;

uniform bool grass_enable_warp = true;
uniform float grass_warp_strength : hint_range(0.0, 100.0) = 25.0;
uniform float grass_irrational_rot : hint_range(0.0, 6.28318) = 2.399963;
uniform sampler2D grass_warp_noise_tex : filter_linear, repeat_enable;

varying vec3 v_world_pos;

void vertex() {
	v_world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

vec3 evaluate_grass(vec2 world_xz) {
	// 关键核心：将连续世界坐标严格量化到 1x1 的离散世界像素网格中心
	// 相当于在世界空间提前渲染/固定为离散像素，彻底消除数学光滑曲线在屏幕采样时的边缘抖动！
	vec2 coord = floor(world_xz) + 0.5;

	// 1. 无理数自扰动场 (Domain Warp)
	if (grass_enable_warp) {
		float cos_a = cos(grass_irrational_rot);
		float sin_a = sin(grass_irrational_rot);
		mat2 rot_irrational = mat2(vec2(cos_a, -sin_a), vec2(sin_a, cos_a));

		vec2 warp_uv = coord / 512.0;
		vec2 warp_sub = rot_irrational * (warp_uv * 1.6180339887);
		float wx = texture(grass_warp_noise_tex, warp_uv).r * 2.0 - 1.0;
		float wy = texture(grass_warp_noise_tex, warp_sub).r * 2.0 - 1.0;
		coord += vec2(wx, wy) * grass_warp_strength;
	}

	// 2. 图案等比整体缩放 (保留现有噪波的所有形状细节，纯粹几何缩放)
	vec2 sample_coord = coord / (512.0 * max(grass_patch_zoom, 0.001));

	vec4 col = grass_base_color;

	// 3. 深色斑块 (Dark Patch)
	if (grass_enable_dark_patch) {
		float n_dark = texture(grass_dark_noise_tex, sample_coord).r;
		if (n_dark > grass_dark_threshold) {
			col = grass_dark_patch_color;
		}
	}

	// 4. 浅色斑块 (Light Patch)
	if (grass_enable_light_patch) {
		float n_light = texture(grass_light_noise_tex, sample_coord).r;
		if (n_light > grass_light_threshold) {
			col = grass_light_patch_color;
		}
	}

	return col.rgb;
}

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
		// GRASS: Sample in world space (X, Z) - Seamless across chunks!
		col = evaluate_grass(v_world_pos.xz);
	} else if (terrain_id == 2) {
		col = vec3(0.45, 0.32, 0.22); // Dirt
	} else if (terrain_id == 3) {
		col = vec3(0.85, 0.75, 0.45); // Sand
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
