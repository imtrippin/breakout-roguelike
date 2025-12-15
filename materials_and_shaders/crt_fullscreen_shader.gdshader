shader_type canvas_item;
render_mode unshaded;

// Screen texture (Godot 4.5 style)
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// Scanline controls
uniform float scanline_intensity : hint_range(0.0, 1.0) = 0.25;
uniform float scanline_density   : hint_range(50.0, 800.0) = 320.0;

// Optional subtle vertical mask (0 = off)
uniform float vertical_soften    : hint_range(0.0, 1.0) = 0.3;

// Tiny film grain (set to 0 to disable)
uniform float noise_intensity    : hint_range(0.0, 0.1) = 0.02;
uniform float noise_speed        : hint_range(0.0, 100.0) = 25.0;

// Overall tuning
uniform float brightness : hint_range(0.0, 2.0) = 1.0;
uniform float contrast   : hint_range(0.5, 2.0) = 1.0;

// simple random
float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	// Just sample the screen as-is, no distortion
	vec2 uv = SCREEN_UV;
	vec3 col = texture(SCREEN_TEXTURE, uv).rgb;

	// ---- Horizontal scanlines ----
	float scan = sin(uv.y * scanline_density);
	// 0..1 mask
	float scan_mask = 0.5 + 0.5 * scan;
	// soften the effect vertically a bit so the bottom/top aren’t too harsh
	if (vertical_soften > 0.0) {
		float vfade = smoothstep(0.0, vertical_soften, uv.y) *
		              (1.0 - smoothstep(1.0 - vertical_soften, 1.0, uv.y));
		scan_mask = mix(1.0, scan_mask, vfade);
	}
	col *= mix(1.0, scan_mask, scanline_intensity);

	// ---- Subtle noise / grain ----
	if (noise_intensity > 0.0) {
		float n = rand(vec2(uv.x + TIME * noise_speed,
		                    uv.y - TIME * noise_speed));
		col += (n - 0.5) * noise_intensity;
	}

	// ---- Brightness / contrast ----
	col = (col - 0.5) * contrast + 0.5;
	col *= brightness;
	col = clamp(col, 0.0, 1.0);

	COLOR = vec4(col, 1.0);
}
