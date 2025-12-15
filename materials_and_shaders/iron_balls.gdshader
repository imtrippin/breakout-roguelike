shader_type canvas_item;

uniform float heavy_strength : hint_range(0.0, 3.0) = 1.0;
uniform vec4 heavy_color : source_color = vec4(1.0, 0.75, 0.2, 1.0);

void fragment() {
	vec4 tex = texture(TEXTURE, UV);

	// pulse effect
	float pulse = (sin(TIME * 6.0) + 1.0) * 0.5;

	// edge glow
	float dist = distance(UV, vec2(0.5));
	float glow = smoothstep(0.45, 0.55, dist);

	vec4 heavy_glow = heavy_color * glow * heavy_strength * pulse;

	COLOR = tex + heavy_glow;
}
