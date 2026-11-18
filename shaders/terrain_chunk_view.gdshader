shader_type spatial;
render_mode cull_disabled;

// =========================================================
// 方案 B 核心: 提前烘焙的 512x512 静态像素艺术底片贴图 (像广告牌一样贴在地面上)
// 运行时零噪声计算，100% 纯正硬切像素色块，绝对稳固无抖动
// =========================================================
uniform sampler2D baked_chunk_texture : filter_nearest;
uniform bool use_baked_texture = true;

// 兼容备用通道
uniform sampler2D chunk_mask : filter_nearest;
uniform vec4 empty_color : source_color = vec4(0.12, 0.15, 0.18, 1.0);
uniform vec4 border_color : source_color = vec4(0.9, 0.75, 0.2, 1.0);

void fragment() {
	if (use_baked_texture) {
		// 方案 B: 直接读取已经烘焙好的静态像素色块 (广告牌模式)
		ALBEDO = texture(baked_chunk_texture, UV).rgb;
		ROUGHNESS = 0.95;
	} else {
		// 备用纯色显示
		vec4 mask_data = texture(chunk_mask, UV);
		int terrain_id = int(round(mask_data.r * 255.0));

		vec3 col = empty_color.rgb;
		if (terrain_id == 0) {
			vec2 check = floor(UV * 512.0 / 32.0);
			float checker = mod(check.x + check.y, 2.0);
			col = mix(empty_color.rgb, empty_color.rgb * 1.15, checker);
		} else if (terrain_id == 1) {
			col = vec3(0.23, 0.49, 0.27);
		} else {
			col = vec3(0.45, 0.32, 0.22);
		}

		vec2 pixel_coord = UV * 512.0;
		if (pixel_coord.x < 1.0 || pixel_coord.x > 511.0 || pixel_coord.y < 1.0 || pixel_coord.y > 511.0) {
			col = border_color.rgb;
		}

		ALBEDO = col;
		ROUGHNESS = 0.95;
	}
}
