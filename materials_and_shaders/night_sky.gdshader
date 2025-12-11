shader_type canvas_item;

// How many star cells per screen (bigger = more, smaller stars)
uniform float star_density = 80.0;

// How bright stars can get
uniform float star_intensity = 1.7;

// How fast stars twinkle
uniform float twinkle_speed = 3.0;

// How many cells actually get a star (0–1, larger = more stars)
uniform float star_fill = 0.25;

// Background sky colors
uniform vec4 sky_top : source_color    = vec4(0.02, 0.02, 0.10, 1.0);
uniform vec4 sky_bottom : source_color = vec4(0.00, 0.00, 0.02, 1.0);

// Star color
uniform vec4 star_color : source_color = vec4(0.8, 0.9, 1.2, 1.0);

// Slight horizontal drifting of stars
uniform float drift_speed = 0.01;

// Simple 2D hash for pseudo-random
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void fragment() {
    // Background gradient (bottom to top)
    vec4 sky = mix(sky_bottom, sky_top, UV.y);

    // Scroll stars very slowly for a living sky feel
    vec2 uv = UV;
    uv.x += TIME * drift_speed;

    // Star grid
    vec2 grid_pos = uv * star_density;
    vec2 cell = floor(grid_pos);
    vec2 cell_uv = fract(grid_pos) - 0.5; // center of cell at 0,0

    float rnd = hash(cell);

    // Only some cells get stars
    float has_star = step(1.0 - star_fill, rnd);

    // Star radius (small radial glow)
    float dist = length(cell_uv);
    float star_core = smoothstep(0.22, 0.0, dist); // smaller = sharper

    // Twinkle using per-cell random phase
    float twinkle = 0.5 + 0.5 * sin(TIME * twinkle_speed + rnd * 20.0);

    float star_brightness = star_core * twinkle * has_star * star_intensity;

    vec4 stars = star_color * star_brightness;

    // Add stars on top of the sky
    vec4 final_col;
    final_col.rgb = sky.rgb + stars.rgb;
    final_col.a   = 1.0;

    COLOR = final_col;
}
