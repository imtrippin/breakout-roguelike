shader_type canvas_item;

uniform vec4 lava_top_color    : source_color = vec4(1.0, 0.7, 0.3, 1.0);
uniform vec4 lava_mid_color    : source_color = vec4(1.0, 0.4, 0.0, 1.0);
uniform vec4 lava_bottom_color : source_color = vec4(0.4, 0.0, 0.0, 1.0);

uniform float surface_height : hint_range(0.0, 1.0) = 0.25;
uniform float wave_amplitude : hint_range(0.0, 0.3) = 0.01;
uniform float wave_frequency : hint_range(0.0, 40.0) = 5.0;
uniform float wave_speed     : hint_range(0.0, 10.0) = 2.0;

uniform float flow_speed     : hint_range(0.0, 10.0) = 1.5;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
   
	   // How many "pixels" across the lava. Smaller = chunkier.
    float pixel_cells = 128.0; // try 32.0, 48.0, 64.0 etc.

    // Snap UVs to a grid
    vec2 uv = floor(UV * pixel_cells) / pixel_cells;

    float x = uv.x;
    float y = uv.y;
    // --- Wavy surface ---
    float t = TIME * wave_speed;
    float surface = 1.0 - surface_height;

    float wave =
        sin(x * wave_frequency + t) * wave_amplitude +
        sin(x * wave_frequency * 0.5 - t * 1.4) * wave_amplitude * 0.5;

    float surface_y = surface + wave;

    // Above lava
    if (y < surface_y) {
        discard;
    }

    // Depth 0 at surface, 1 at bottom
    float depth = clamp((y - surface_y) / max(0.0001, 1.0 - surface_y), 0.0, 1.0);

    // Gradient
	float bottom_bias = 0.1

; // 0.3 = thicker bottom red
    vec4 col;
    if (depth < bottom_bias) {
        float k = depth / bottom_bias;
        col = mix(lava_top_color, lava_mid_color, k);
    } else {
        float k = (depth - bottom_bias) / 0.5;
        col = mix(lava_mid_color, lava_bottom_color, k);
    }

    // Flow / general movement
    vec2 flow_uv = vec2(x + TIME * flow_speed * 0.2, y * 3.0 + TIME * flow_speed);
    float n = noise(flow_uv * 6.0);

    COLOR = col;
}
