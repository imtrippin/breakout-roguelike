shader_type canvas_item;

uniform vec4 core_color  : source_color = vec4(0.4, 0.8, 1.2, 1.0);
uniform vec4 glow_color  : source_color = vec4(0.8, 1.0, 1.5, 1.0);

// scanline params
uniform float line_density   = 60.0;
uniform float line_speed     = 1.5;
uniform float line_strength  = 0.4;

// how strict the “blueness” mask is (center only)
uniform float blue_threshold = 0.2;
uniform float blue_softness  = 0.15;

// impact flash params
uniform vec4  impact_color   : source_color = vec4(1.6, 1.6, 1.8, 1.0);
uniform float flash_amount   : hint_range(0.0, 1.0) = 0.0;   // strength of flash
uniform vec2  impact_uv      = vec2(0.5, 0.5);               // where the ball hit (UV)
uniform float impact_radius  : hint_range(0.0, 1.0) = 0.25;  // current radius of ring
uniform float impact_softness : hint_range(0.0, 1.0) = 0.4;  // how soft the edge is


void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    if (tex.a < 0.01) {
        discard;
    }

    // base paddle color
    vec3 base = tex.rgb * core_color.rgb;

    // ---- blue mask so scanlines only affect blue middle ----
    float blue_value = tex.b - max(tex.r, tex.g);
    float blue_mask = smoothstep(blue_threshold,
                                 blue_threshold + blue_softness,
                                 blue_value);

    // ---- scanlines ----
    float stripe = sin(UV.y * line_density + TIME * line_speed);
    stripe = 0.5 + 0.5 * stripe;
    stripe = pow(stripe, 3.0); // sharpen bright parts

    float scan_effect = stripe * line_strength;
    vec3 scanned = base + scan_effect * blue_mask * glow_color.rgb;

    // ---- impact flash: radial burst from impact_uv ----
    // distance from impact point in UV space
    float d = distance(UV, impact_uv);
    // soft circular mask: 1 near center → 0 outside radius
    float ring = 1.0 - smoothstep(impact_radius, impact_radius + impact_softness, d);
    // combine with flash_amount so we can animate it from script
    float impact_strength = ring * flash_amount;

    // boost brightness & tint toward impact_color where the ring is
    vec3 impacted = mix(scanned, impact_color.rgb, impact_strength);

    COLOR = vec4(impacted, tex.a * core_color.a);
}
