shader_type canvas_item;

uniform sampler2D base_noise_tex : filter_linear, repeat_enable;
uniform sampler2D warp_noise_tex : filter_linear, repeat_enable;

// Domain Warp (无理数自扰动)
uniform float warp_strength : hint_range(0.0, 100.0) = 30.0;
uniform float irrational_rot : hint_range(0.0, 6.28318) = 2.399963; // 黄金角 ~137.5°

// 对比度与亮度拉伸 (解决高斯钟形分布导致中间两色聚拢的问题)
uniform float noise_contrast : hint_range(0.5, 4.0) = 1.9;
uniform float noise_offset : hint_range(-0.5, 0.5) = 0.0;

// 等高线阶梯分级 (num_bands 决定启用多少个色阶)
uniform int num_bands : hint_range(2, 6) = 4;
uniform vec4 color_band_0 : source_color = vec4(0.11, 0.22, 0.12, 1.0); // 极深暗绿 (底层)
uniform vec4 color_band_1 : source_color = vec4(0.18, 0.38, 0.19, 1.0); // 基础草绿
uniform vec4 color_band_2 : source_color = vec4(0.28, 0.56, 0.25, 1.0); // 丰茂中绿
uniform vec4 color_band_3 : source_color = vec4(0.48, 0.76, 0.27, 1.0); // 鲜亮嫩绿
uniform vec4 color_band_4 : source_color = vec4(0.68, 0.88, 0.38, 1.0); // 阳光黄绿
uniform vec4 color_band_5 : source_color = vec4(0.88, 0.96, 0.55, 1.0); // 浅浅高光

uniform bool show_isolines = false; // 是否显示等高线细边框
uniform vec4 isoline_color : source_color = vec4(0.07, 0.13, 0.08, 1.0);

void fragment() {
	vec2 uv = UV;

	// 1. 无理数旋转矩阵 (黄金角变换打碎周期性)
	float cos_a = cos(irrational_rot);
	float sin_a = sin(irrational_rot);
	mat2 rot_irrational = mat2(vec2(cos_a, -sin_a), vec2(sin_a, cos_a));

	// 2. 采样微观扰动场 (Warp Field)
	vec2 warped_coord = rot_irrational * (uv * 1.6180339887);
	float warp_x = texture(warp_noise_tex, uv).r * 2.0 - 1.0;
	float warp_y = texture(warp_noise_tex, warped_coord).r * 2.0 - 1.0;

	vec2 offset = vec2(warp_x, warp_y) * (warp_strength / 512.0);

	// 3. 采样宏观基础噪波 (受到微观扰动扯动的坐标)
	float raw_noise = texture(base_noise_tex, uv + offset).r;

	// 4. 对比度直方图拉伸 (关键：将挤在中间的噪波均等推向两端，使各级颜色均匀铺开)
	float centered = (raw_noise - 0.5) * noise_contrast + 0.5 + noise_offset;
	float norm_val = clamp(centered, 0.0, 0.9999);

	// 5. 等高线阶梯分级 (由 num_bands 控制当前划分为几个色阶)
	float scaled = norm_val * float(num_bands);
	int band_idx = int(floor(scaled));

	vec4 final_color = color_band_0;
	if (band_idx == 0) final_color = color_band_0;
	else if (band_idx == 1) final_color = color_band_1;
	else if (band_idx == 2) final_color = color_band_2;
	else if (band_idx == 3) final_color = color_band_3;
	else if (band_idx == 4) final_color = color_band_4;
	else final_color = color_band_5;

	// 可选等高线细分线
	if (show_isolines) {
		float f = fract(scaled);
		if (f < 0.05 || f > 0.95) {
			final_color = mix(final_color, isoline_color, 0.65);
		}
	}

	COLOR = final_color;
}
