shader_type canvas_item;

// ---------- SKY COLORS ----------
uniform vec4 sky_top    : source_color = vec4(0.03, 0.03, 0.10, 1.0);
uniform vec4 sky_bottom : source_color = vec4(0.00, 0.00, 0.02, 1.0);

// Nebula colors
uniform vec4 nebula_color_1 : source_color = vec4(0.25, 0.10, 0.35, 1.0);
uniform vec4 nebula_color_2 : source_color = vec4(0.05, 0.30, 0.55, 1.0);
uniform float nebula_intensity = 0.7;

// ---------- STARS ----------
uniform vec4 star_color_big   : source_color = vec4(1.2, 1.1, 1.0, 1.0);
uniform vec4 star_color_small : source_color = vec4(0.7, 0.9, 1.2, 1.0);

uniform float star_density_big   = 55.0;
uniform float star_density_small = 110.0;

uniform float twinkle_speed_big   = 2.0;
uniform float twinkle_speed_small = 4.5;
uniform float drift_big   = 0.01;
uniform float drift_small = 0.02;

uniform float star_intensity = 1.5;

// ---------- VIGNETTE ----------
uniform float vignette_strength = 0.7;


// -------- noise helpers --------
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
           (c - a) * u.y * (1.0 - u.x) +
           (d - b) * u.x * u.y;
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 5; i++) {
        v += noise(p) * a;
        // rotate + scale each octave to break straight lines
        mat2 rot = mat2(
            vec2(0.8, 0.6),
            vec2(-0.6, 0.8)
        );
        p = rot * p * 1.9;
        a *= 0.5;
    }
    return v;
}

// star layer with jitter + rotated grid to hide visible cell lines
vec3 star_layer(vec2 uv, float density, float drift, float twinkle_speed, vec4 col) {
    uv.x += TIME * drift;

    // rotate grid so it isn't aligned to screen axes
    mat2 rot = mat2(
        vec2(0.93, 0.36),
        vec2(-0.36, 0.93)
    );
    vec2 grid_pos = rot * uv * density;

    vec2 cell = floor(grid_pos);
    vec2 cell_center = cell + 0.5;

    // jitter star inside the cell
    vec2 jitter = vec2(
        hash(cell + 3.1),
        hash(cell + 7.3)
    ) - 0.5;

    vec2 star_pos = cell_center + jitter * 0.8;
    vec2 cell_uv = grid_pos - star_pos;

    float rnd = hash(cell);

    // only some cells get stars
    float has_star = step(0.82, rnd);

    float dist = length(cell_uv);
    float core = smoothstep(0.28, 0.0, dist);

    float twinkle = 0.6 + 0.4 * sin(TIME * twinkle_speed + rnd * 25.0);

    float brightness = core * twinkle * has_star * star_intensity;

    return col.rgb * brightness;
}


void fragment() {
    // ColorRect UV (0–1 across rect)
    vec2 uv = UV;

    // ---------- gradient sky ----------
    vec4 sky = mix(sky_bottom, sky_top, uv.y);
    vec3 col = sky.rgb;

    // ---------- NEBULA ----------
    vec2 n_uv = (uv - 0.5) * vec2(3.3, 2.4);
    float n1 = fbm(n_uv + vec2(TIME * 0.015, -TIME * 0.011));
    float n2 = fbm(n_uv * 1.7 + vec2(-TIME * 0.009, TIME * 0.013));
    float neb = (n1 + n2) * 0.5;

    neb = pow(neb, 1.4); // smooth out

    vec3 nebula = mix(nebula_color_1.rgb, nebula_color_2.rgb, neb);
    float nebula_mask = smoothstep(0.25, 0.9, uv.y);
    col += nebula * nebula_intensity * nebula_mask;

    // ---------- STARS ----------
    vec3 big_stars   = star_layer(uv, star_density_big,   drift_big,   twinkle_speed_big,   star_color_big);
    vec3 small_stars = star_layer(uv, star_density_small, drift_small, twinkle_speed_small, star_color_small);

    col += big_stars;
    col += small_stars * 0.7;

    // ---------- subtle dithering to reduce banding ----------
    float dither = (hash(uv * vec2(1024.0, 768.0)) - 0.5) * 0.01;
    col += vec3(dither);

    // ---------- VIGNETTE ----------
    vec2 centered = uv - 0.5;
    float vign = 1.0 - smoothstep(0.6, 0.95, length(centered));
    col *= mix(1.0 - vignette_strength, 1.0, vign);

    COLOR = vec4(col, 1.0);
}
