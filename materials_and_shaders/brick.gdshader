shader_type canvas_item;

// Base crystal color (tint)
uniform vec4 base_color     : source_color = vec4(0.2, 0.8, 1.4, 1.0);
// Highlight color for bright facets
uniform vec4 highlight_color: source_color = vec4(1.8, 2.0, 2.2, 1.0);
// Edge rim color
uniform vec4 edge_color     : source_color = vec4(0.6, 1.4, 2.0, 1.0);

// Facet pattern scale (higher = smaller, more facets)
uniform float facet_scale = 8.0;

// Sparkle / shimmer
uniform float sparkle_speed    = 4.0;
uniform float sparkle_strength = 0.35;

// Subtle hue shift over time (0 = off)
uniform float hue_shift_strength = 0.08;

// Flash on hit
uniform float hit_flash = 0.0;


// --- helpers ---

float hash21(vec2 p) {
    p = fract(p * vec2(234.34, 567.21));
    p += dot(p, p + 23.45);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash21(i);
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    float a = 0.5;
    for (int i = 0; i < 3; i++) {
        v += noise(p) * a;
        p *= 2.5;
        a *= 0.5;
    }
    return v;
}

// Quick HSV→RGB for gentle hue shifting
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    if (tex.a <= 0.01) {
        discard;
    }

    // Center-based gradient for gem depth
    vec2 centered = UV - vec2(0.5);
    float dist = length(centered) / 0.5; // 0 center, ~1 edges

    // Slight darkening toward edges
    float depth = 1.0 - smoothstep(0.4, 1.0, dist);

    // Facets: use fbm + some directional “cuts”
    vec2 facet_uv = UV * facet_scale;
    float n = fbm(facet_uv);

    // Add some angular variation
    float cut1 = abs(dot(normalize(centered + 0.001), vec2(0.8, 0.2)));
    float cut2 = abs(dot(normalize(centered + 0.001), vec2(-0.6, 0.7)));
    float cuts = (cut1 + cut2) * 0.5;

    float facet_intensity = clamp(n * 1.2 + cuts * 0.8, 0.0, 1.5);

    // Sparkles: bright points that flicker
    float sparkle_noise = hash21(floor(facet_uv * 3.0));
    float sparkle = smoothstep(0.85, 1.0, sparkle_noise);
    float sparkle_time = 0.5 + 0.5 * sin(TIME * sparkle_speed + sparkle_noise * 12.0);
    sparkle *= sparkle_time * sparkle_strength;

    // Base + highlight colors
    vec3 base = base_color.rgb * depth;
    vec3 highlight = highlight_color.rgb * facet_intensity;

    vec3 color = base + highlight + highlight_color.rgb * sparkle;

    // Edge rim glow to keep brick silhouette sharp
    float edge_u = min(UV.x, 1.0 - UV.x);
    float edge_v = min(UV.y, 1.0 - UV.y);
    float edge_dist = min(edge_u, edge_v);
    float edge = smoothstep(0.14, 0.0, edge_dist);
    color += edge_color.rgb * edge * 0.5;

    // Subtle global hue shift over time (makes it feel alive)
    if (hue_shift_strength > 0.0) {
        // convert color roughly to HSV-ish space
        float h_shift = sin(TIME * 0.5) * hue_shift_strength;
        // approximate hue via hash of normalized color
        float base_h = hash21(color.rg * 3.7);
        vec3 hsv = vec3(base_h + h_shift, 0.7, 1.0);
        vec3 shifted = hsv2rgb(hsv);
        // blend toward shifted
        color = mix(color, shifted, 0.25);
    }

    vec4 final_col = vec4(color, 1.0);

    // Hit flash: lerp toward white
    final_col = mix(final_col, vec4(1.0), clamp(hit_flash, 0.0, 1.0));

    // Respect texture alpha
    final_col *= tex;

    COLOR = final_col;
}
