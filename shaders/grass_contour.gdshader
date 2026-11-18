shader_type canvas_item;

// 模式选择: 0 = 补丁遮罩模式 (大底色 + 阈值斑块遮罩，主推推荐), 1 = 等高阶梯模式 (Contour Bands)
uniform int color_mode : hint_range(0, 1) = 0;

// =========================================================
// 图案等比缩放 (保持现有噪波图案形状，整体纯粹放大或缩小)
// =========================================================
uniform float patch_zoom : hint_range(0.1, 5.0) = 1.0; // 1.0 为原大小，>1.0 放大，<1.0 缩小

// =========================================================
// 模式 0 专属: 大底色 + 阈值斑块遮罩 (Base + Patch Masks)
// =========================================================
uniform vec4 base_color : source_color = vec4(0.24, 0.52, 0.22, 1.0); // 丰茂主草色 (占 ~75% 面积)

// 深色斑块 (Dark Patch: 阴影/苔藓/茂密带)
uniform bool enable_dark_patch = true;
uniform vec4 dark_patch_color : source_color = vec4(0.13, 0.30, 0.14, 1.0); // 深色草绿
uniform float dark_patch_threshold : hint_range(0.0, 1.0) = 0.58; // 阈值 (越大越稀疏)
uniform sampler2D dark_patch_noise_tex : filter_linear, repeat_enable;

// 浅色斑块 (Light Patch: 嫩芽/阳光高光带)
uniform bool enable_light_patch = true;
uniform vec4 light_patch_color : source_color = vec4(0.46, 0.75, 0.26, 1.0); // 嫩芽浅色斑
uniform float light_patch_threshold : hint_range(0.0, 1.0) = 0.62; // 阈值 (越大越稀疏)
uniform sampler2D light_patch_noise_tex : filter_linear, repeat_enable;

// =========================================================
// 领域扭曲 (Domain Warp - 无理数黄金角自扰动场，赋予斑块手绘苔藓边缘)
// =========================================================
uniform bool enable_warp = true;
uniform float warp_strength : hint_range(0.0, 100.0) = 25.0;
uniform float irrational_rot : hint_range(0.0, 6.28318) = 2.399963; // 黄金角 ~137.5°
uniform sampler2D warp_noise_tex : filter_linear, repeat_enable;

// =========================================================
// 模式 1 兼容: 等高阶梯模式参数 (Contour Bands)
// =========================================================
uniform sampler2D base_noise_tex : filter_linear, repeat_enable;
uniform float noise_contrast : hint_range(0.5, 4.0) = 1.9;
uniform float noise_offset : hint_range(-0.5, 0.5) = 0.0;
uniform int num_bands : hint_range(2, 6) = 4;
uniform vec4 color_band_0 : source_color = vec4(0.11, 0.22, 0.12, 1.0);
uniform vec4 color_band_1 : source_color = vec4(0.18, 0.38, 0.19, 1.0);
uniform vec4 color_band_2 : source_color = vec4(0.28, 0.56, 0.25, 1.0);
uniform vec4 color_band_3 : source_color = vec4(0.48, 0.76, 0.27, 1.0);
uniform vec4 color_band_4 : source_color = vec4(0.68, 0.88, 0.38, 1.0);
uniform vec4 color_band_5 : source_color = vec4(0.88, 0.96, 0.55, 1.0);
uniform bool show_isolines = false;
uniform vec4 isoline_color : source_color = vec4(0.07, 0.13, 0.08, 1.0);

// 世界坐标偏移 (用于预览平移或多区块衔接)
uniform vec2 world_offset = vec2(0.0, 0.0);

void fragment() {
	vec2 pixel_coord = UV * 512.0 + world_offset;

	// 1. 无理数自扰动场 (Domain Warp)
	vec2 warped_coord = pixel_coord;
	if (enable_warp) {
		float cos_a = cos(irrational_rot);
		float sin_a = sin(irrational_rot);
		mat2 rot_irrational = mat2(vec2(cos_a, -sin_a), vec2(sin_a, cos_a));

		vec2 warp_uv = pixel_coord / 512.0;
		vec2 warp_sub = rot_irrational * (warp_uv * 1.6180339887);
		float wx = texture(warp_noise_tex, warp_uv).r * 2.0 - 1.0;
		float wy = texture(warp_noise_tex, warp_sub).r * 2.0 - 1.0;
		warped_coord += vec2(wx, wy) * warp_strength;
	}

	// 2. 图案整体等比缩放 (坐标除以 zoom，纯粹放大/缩小现有图案，形状保持 100% 相同)
	vec2 sample_coord = warped_coord / (512.0 * max(patch_zoom, 0.001));

	vec4 final_color = base_color;

	if (color_mode == 0) {
		// =========================================================
		// 模式 0: 大底色 + 阈值斑块遮罩 (Base + Patch Masks)
		// =========================================================
		final_color = base_color;

		// 采样深色斑块遮罩 (采用 1 像素屏幕导数 fwidth 抗锯齿平滑，消除移动爬行走样)
		if (enable_dark_patch) {
			float n_dark = texture(dark_patch_noise_tex, sample_coord).r;
			float w_dark = max(fwidth(n_dark) * 0.75, 0.0001);
			float m_dark = smoothstep(dark_patch_threshold - w_dark, dark_patch_threshold + w_dark, n_dark);
			final_color = mix(final_color, dark_patch_color, m_dark);
		}

		// 采样浅色斑块遮罩 (叠加上层)
		if (enable_light_patch) {
			float n_light = texture(light_patch_noise_tex, sample_coord).r;
			float w_light = max(fwidth(n_light) * 0.75, 0.0001);
			float m_light = smoothstep(light_patch_threshold - w_light, light_patch_threshold + w_light, n_light);
			final_color = mix(final_color, light_patch_color, m_light);
		}
	} else {
		// =========================================================
		// 模式 1: 等高阶梯分级 (Contour Bands)
		// =========================================================
		float raw_noise = texture(base_noise_tex, sample_coord).r;
		float centered = (raw_noise - 0.5) * noise_contrast + 0.5 + noise_offset;
		float norm_val = clamp(centered, 0.0, 0.9999);
		float scaled = norm_val * float(num_bands);
		int band_idx = int(floor(scaled));

		if (band_idx == 0) final_color = color_band_0;
		else if (band_idx == 1) final_color = color_band_1;
		else if (band_idx == 2) final_color = color_band_2;
		else if (band_idx == 3) final_color = color_band_3;
		else if (band_idx == 4) final_color = color_band_4;
		else final_color = color_band_5;

		if (show_isolines) {
			float f = fract(scaled);
			if (f < 0.05 || f > 0.95) {
				final_color = mix(final_color, isoline_color, 0.65);
			}
		}
	}

	COLOR = final_color;
}
