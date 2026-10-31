// Drawn over a body part as an overlay, added on top so the part's own texture shows through (D187, D188):
// alive: blue veins of light pulsing under the skin; damaged: the whole part washed yellow, brighter at its edges,
// breathing slowly. Either or both.
shader_type spatial;
render_mode unshaded, blend_add, depth_draw_never, shadows_disabled;

uniform float seed = 0.0;
uniform float scale = 260.0;      // noise per metre, sampled in the world so every part shares one grain
uniform float alive = 0.0;
uniform float damaged = 0.0;

varying vec3 wp;

void vertex() {
	wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

float h3(vec3 p) {
	p = fract(p * 0.3183099 + 0.1);
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float n3(vec3 x) {
	vec3 i = floor(x);
	vec3 f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(mix(h3(i), h3(i + vec3(1, 0, 0)), f.x), mix(h3(i + vec3(0, 1, 0)), h3(i + vec3(1, 1, 0)), f.x), f.y),
		mix(mix(h3(i + vec3(0, 0, 1)), h3(i + vec3(1, 0, 1)), f.x), mix(h3(i + vec3(0, 1, 1)), h3(i + vec3(1, 1, 1)), f.x), f.y), f.z);
}

float fbm(vec3 p) {
	float a = 0.5;
	float s = 0.0;
	for (int i = 0; i < 4; i++) {
		s += a * n3(p);
		p *= 2.03;
		a *= 0.5;
	}
	return s;
}

void fragment() {
	vec3 p = wp * scale + vec3(seed * 7.0);
	float r = abs(fbm(p * 0.45 + vec3(0.0, TIME * 0.4, 0.0)) - 0.5);
	float vein = 1.0 - smoothstep(0.0, 0.05, r);
	float pulse = 0.55 + 0.45 * sin(TIME * 4.0 + seed * 3.0);
	float flick = step(0.15, fract(sin(floor(TIME * 18.0) + seed) * 437.5));
	vec3 blue = (vec3(0.25, 0.55, 1.0) * vein * (pulse * 1.1 + 0.2) * flick + vec3(0.01, 0.03, 0.07) * pulse) * alive;
	float rim = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 2.0);
	float breathe = 0.75 + 0.25 * sin(TIME * 2.2 + seed);
	vec3 yellow = vec3(0.42, 0.32, 0.0) * (0.12 + 0.7 * rim) * breathe * damaged;
	ALBEDO = blue + yellow;
}
