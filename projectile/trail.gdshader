shader_type canvas_item;

uniform float head_fade : hint_range(0.0, 4.0) = 1.6;   // how fast it fades toward the tail
uniform float glow : hint_range(0.0, 4.0) = 1.2;        // brightness boost
uniform float alpha : hint_range(0.0, 1.0) = 0.85;      // overall transparency
uniform float width_softness : hint_range(0.0, 2.0) = 0.8; // soft edges across width

uniform vec4 tint : source_color = vec4(0.55, 0.8, 1.0, 1.0); // trail color

void fragment() {
	// For Line2D, UV.x runs along the line (0..1), UV.y across width (0..1)
	float along = UV.x;                 // 0=head (newest) or sometimes 1=head depending on point order
	float across = abs(UV.y - 0.5) * 2.0; // 0 center, 1 edge

	// Fade along the trail (stronger at tail)
	// If your fade looks reversed, change (along) to (1.0 - along)
	float along_fade = pow(along, head_fade);

	// Soften edges across width
	float edge = pow(1.0 - across, width_softness);

	// Base sample (if Line2D has a texture, use it; otherwise it's white)
	vec4 tex = texture(TEXTURE, UV);

	float a = tex.a * along_fade * edge * alpha;

	// Simple “glow”: brighten toward head a bit
	float head_boost = mix(0.8, 1.0 + glow, pow(1.0 - along, 2.0));

	COLOR = vec4(tint.rgb * head_boost, a);
}
