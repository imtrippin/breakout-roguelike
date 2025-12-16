shader_type canvas_item;

uniform float fill : hint_range(0.0, 1.0) = 0.0;
uniform float segments : hint_range(2.0, 40.0) = 10.0;

uniform vec4 fill_color : source_color = vec4(0.25, 0.8, 1.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.9, 1.0, 1.0, 1.0);
uniform vec4 bg_color   : source_color = vec4(0.08, 0.08, 0.12, 1.0);

void fragment() {
	float seg_size = 1.0 / segments;
	float seg_index = floor(UV.x / seg_size);
	float seg_end = (seg_index + 1.0) * seg_size;

	if (seg_end <= fill) {
		COLOR = fill_color;
	}
	else if (UV.x <= fill && UV.x >= fill - seg_size) {
		float glow = smoothstep(fill - seg_size, fill, UV.x);
		COLOR = mix(fill_color, glow_color, glow);
	}
	else {
		COLOR = bg_color;
	}
}
