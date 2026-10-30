// A candle flame (D181): a quad that always faces the camera round the vertical, drawn as a teardrop that sways,
// stretches and flickers. Blue at the root, white-yellow core, orange edge. Additive and bright enough to bloom.
shader_type spatial;
render_mode unshaded, blend_add, cull_disabled, depth_draw_never, shadows_disabled;

uniform float seed = 0.0;
uniform float energy = 3.0;

float hash(float n) { return fract(sin(n) * 43758.5453); }
float noise(float x) {
	float i = floor(x);
	float f = fract(x);
	return mix(hash(i), hash(i + 1.0), f * f * (3.0 - 2.0 * f));
}

void vertex() {
	// Face the camera, turning only round the vertical axis.
	vec3 up = vec3(0.0, 1.0, 0.0);
	vec3 right = normalize(cross(up, INV_VIEW_MATRIX[2].xyz));
	vec3 fwd = normalize(cross(right, up));
	mat4 bb = mat4(vec4(right, 0.0), vec4(up, 0.0), vec4(fwd, 0.0), MODEL_MATRIX[3]);
	vec3 sc = vec3(length(MODEL_MATRIX[0].xyz), length(MODEL_MATRIX[1].xyz), length(MODEL_MATRIX[2].xyz));
	float t = TIME + seed;
	// The flame breathes taller and shorter.
	float stretch = 1.0 + 0.12 * sin(t * 9.0) + 0.1 * (noise(t * 6.0) - 0.5);
	vec3 v = VERTEX;
	v.y *= stretch;                  // the quad runs from 0 (wick) to 1 (tip)
	MODELVIEW_MATRIX = VIEW_MATRIX * bb * mat4(vec4(sc.x, 0, 0, 0), vec4(0, sc.y, 0, 0), vec4(0, 0, sc.z, 0), vec4(0, 0, 0, 1));
	VERTEX = v;
}

void fragment() {
	float t = TIME + seed;
	float y = 1.0 - UV.y;            // 0 at the wick, 1 at the tip
	float x = UV.x * 2.0 - 1.0;
	// The tip sways more than the root.
	float sway = (sin(t * 5.3 + y * 2.0) * 0.5 + (noise(t * 3.1) - 0.5)) * 0.22 * y * y;
	float w = 1.25 * sqrt(max(y, 0.0)) * pow(max(1.0 - y, 0.0), 0.7);
	float d = abs(x - sway) / max(w, 0.001);
	float body = smoothstep(1.0, 0.45, d) * smoothstep(0.0, 0.06, y);
	float core = smoothstep(0.75, 0.0, d) * smoothstep(0.85, 0.25, y) * smoothstep(0.08, 0.3, y);
	vec3 edge = vec3(1.0, 0.42, 0.08);
	vec3 mid = vec3(1.0, 0.75, 0.32);
	vec3 hot = vec3(1.0, 0.95, 0.8);
	vec3 col = mix(edge, mid, smoothstep(0.9, 0.4, d));
	col = mix(col, hot, core);
	// A small blue root.
	col = mix(vec3(0.45, 0.45, 0.9), col, smoothstep(0.0, 0.1, y));
	float flick = 0.85 + 0.15 * noise(t * 14.0);
	ALBEDO = col * energy * flick * body;
	ALPHA = body;
}
