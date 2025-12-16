shader_type canvas_item;

uniform vec4 core_color : source_color = vec4(0.35, 0.85, 1.0, 1.0);
uniform vec4 rim_color  : source_color = vec4(0.85, 1.0, 1.0, 1.0);

uniform float core_radius : hint_range(0.05, 0.49) = 0.18;   // bright center size
uniform float rim_width   : hint_range(0.01, 0.40) = 0.18;   // glow thickness
uniform float softness    : hint_range(0.01, 0.40) = 0.10;   // edge softness

uniform float pulse_strength : hint_range(0.0, 0.30) = 0.08;
uniform float pulse_speed    : hint_range(0.0, 20.0) = 6.0;

uniform float outline_width  : hint_range(0.0, 0.15) = 0.03;
uniform vec4  outline_color  : source_color = vec4(0.05, 0.10, 0.20, 1.0);

uniform float time = 0.0;

void fragment() {
	// UV centered at (0,0), radius 0..~0.707
	vec2 uv = UV - vec2(0.5);
	float r = length(uv);

	// Pulse slightly changes the core size
	float pulse = sin(time * pulse_speed) * pulse_strength;
	float cr = core_radius + pulse * 0.5;

	// Base disc alpha (soft edge)
	float disc = 1.0 - smoothstep(0.5 - softness, 0.5, r);

	// Core and rim masks
	float core = 1.0 - smoothstep(cr, cr + softness, r);
	float rim_inner = cr;
	float rim_outer = cr + rim_width;
	float rim = smoothstep(rim_inner, rim_inner + softness, r) * (1.0 - smoothstep(rim_outer, rim_outer + softness, r));

	// Outline ring near the edge of the disc
	float out_a = 0.0;
	if (outline_width > 0.0) {
		float o0 = 0.5 - outline_width - softness;
		float o1 = 0.5 - softness;
		out_a = smoothstep(o0, o0 + softness, r) * (1.0 - smoothstep(o1, o1 + softness, r));
	}

	// Color mix
	vec3 col = vec3(0.0);
	col += core_color.rgb * core * 1.2;
	col += rim_color.rgb * rim * 1.0;

	// Final alpha combines disc + rim (rim can exceed disc for glow)
	float a = max(disc, rim * 0.8);
	// Apply outline darkening
	col = mix(col, outline_color.rgb, clamp(out_a, 0.0, 1.0));
	a = max(a, out_a);

	COLOR = vec4(col, a);
}
