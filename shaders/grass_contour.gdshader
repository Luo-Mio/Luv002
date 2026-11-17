shader_type canvas_item;

// Noise 1: Macro Base Noise (宏观基础形状)
uniform float base_freq : hint_range(0.002, 0.08) = 0.012;
uniform int base_octaves : hint_range(1, 5) = 3;

// Noise 2: Domain Warp with Irrational Matrix (无理数自扰动)
uniform float warp_freq : hint_range(0.005, 0.15) = 0.028;
uniform float warp_strength : hint_range(0.0, 80.0) = 35.0;
uniform float irrational_rot : hint_range(0.0, 6.28318) = 2.399963; // 黄金角 ~137.5°

// Contour Stepping (等高线阶梯分级与纯色色斑)
uniform int num_bands : hint_range(2, 6) = 4;
uniform vec4 color_band_0 : source_color = vec4(0.12, 0.22, 0.14, 1.0); // 最深暗绿
uniform vec4 color_band_1 : source_color = vec4(0.18, 0.38, 0.20, 1.0); // 基础草绿
uniform vec4 color_band_2 : source_color = vec4(0.30, 0.58, 0.26, 1.0); // 鲜亮嫩绿
uniform vec4 color_band_3 : source_color = vec4(0.52, 0.78, 0.32, 1.0); // 阳光黄绿
uniform vec4 color_band_4 : source_color = vec4(0.72, 0.88, 0.45, 1.0); // 浅浅高光
uniform vec4 color_band_5 : source_color = vec4(0.88, 0.95, 0.60, 1.0); // 极亮黄绿

uniform bool show_isolines = false; // 是否显示等高线细分线
uniform vec4 isoline_color : source_color = vec4(0.08, 0.15, 0.09, 1.0);

// --- High-Performance GPU Noise Functions ---
vec2 hash2(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float gradient_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f); // Quintic or cubic interpolation

	return mix(
		mix(dot(hash2(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
		    dot(hash2(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
		mix(dot(hash2(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
		    dot(hash2(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x),
		u.y
	);
}

// Fractal Brownian Motion (fBm)
float fbm(vec2 p, int octaves) {
	float val = 0.0;
	float amp = 0.5;
	float freq = 1.0;
	for (int i = 0; i < octaves; i++) {
		val += amp * gradient_noise(p * freq);
		freq *= 2.02;
		amp *= 0.5;
	}
	return val;
}

void fragment() {
	// Pixel coordinates in 512x512 space
	vec2 coord = UV * 512.0;

	// 1. 无理数旋转矩阵 (Irrational Golden Angle Matrix)
	float cos_a = cos(irrational_rot);
	float sin_a = sin(irrational_rot);
	mat2 rot_irrational = mat2(vec2(cos_a, -sin_a), vec2(sin_a, cos_a));

	// 2. 领域扭曲采样 (Domain Warping)
	// 用旋转后的无理数坐标采样高频微观扰动场
	vec2 p_warped_coord = rot_irrational * (coord * 1.6180339887);
	vec2 warp_offset = vec2(
		fbm(coord * warp_freq, 2),
		fbm((p_warped_coord + vec2(137.5, 92.3)) * warp_freq, 2)
	) * warp_strength;

	// 3. 宏观基础噪波采样 (被扰动后的坐标)
	vec2 final_sample_pos = (coord + warp_offset) * base_freq;
	float raw_noise = fbm(final_sample_pos, base_octaves);

	// 归一化到 0.0 ~ 1.0
	float norm_val = clamp(raw_noise * 0.5 + 0.5, 0.0, 0.9999);

	// 4. 等高线阶梯分级 (Quantization Stepping)
	float scaled_val = norm_val * float(num_bands);
	int band_idx = int(floor(scaled_val));

	vec4 chosen_color = color_band_0;
	if (band_idx == 0) chosen_color = color_band_0;
	else if (band_idx == 1) chosen_color = color_band_1;
	else if (band_idx == 2) chosen_color = color_band_2;
	else if (band_idx == 3) chosen_color = color_band_3;
	else if (band_idx == 4) chosen_color = color_band_4;
	else chosen_color = color_band_5;

	// 可选等高线细分线
	if (show_isolines) {
		float step_fract = fract(scaled_val);
		if (step_fract < 0.04 || step_fract > 0.96) {
			chosen_color = mix(chosen_color, isoline_color, 0.6);
		}
	}

	COLOR = chosen_color;
}
