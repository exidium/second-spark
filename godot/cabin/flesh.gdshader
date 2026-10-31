// The companion's flesh on the operating table (D186). One shader, three looks:
// 0 muscle: raw red fibres running along the part, wet, pale tendon at each end.
// 1 skin: sallow yellow skin, mottled, with a ring of black stitches where the part was sewn on.
// 2 alive: the skin with blue veins of light pulsing under it.
shader_type spatial;

uniform int state = 0;
uniform float seed = 0.0;
uniform float stitch = 1.0;       // 0 on hands, feet and other small pieces
uniform float scale = 260.0;      // noise per metre, sampled on the table so every piece shares one grain

varying vec3 op;

void vertex() {
	op = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
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
	vec3 p = op * scale + vec3(seed * 7.0);
	float u = UV.x;
	float e = min(UV.y, 1.0 - UV.y);          // 0 at either end of the part
	if (state == 0) {
		// Fine fibres along the part, grouped in bellies by a slower wave, darker in the grooves.
		float fib = 0.5 + 0.5 * sin(u * TAU * 46.0 + fbm(p * 0.5) * 7.0);
		float belly = smoothstep(0.15, 0.7, 0.5 + 0.5 * sin(u * TAU * 5.0 + fbm(p * 0.3) * 3.0));
		vec3 c = mix(vec3(0.22, 0.03, 0.03), vec3(0.50, 0.09, 0.07), belly * (0.75 + 0.25 * fib));
		c *= 0.8 + 0.4 * fbm(p * 1.5);
		float tendon = smoothstep(0.1, 0.03, e) * stitch;
		c = mix(c, vec3(0.80, 0.72, 0.60), tendon * 0.85);
		ALBEDO = c;
		ROUGHNESS = mix(0.25, 0.5, fib * belly);
		SPECULAR = 0.7;
	} else {
		float m = fbm(p * 0.8);
		vec3 c = mix(vec3(0.50, 0.40, 0.22), vec3(0.70, 0.58, 0.34), m);
		c = mix(c, vec3(0.50, 0.54, 0.38), smoothstep(0.55, 0.8, fbm(p * 0.3 + 3.0)) * 0.5);
		// Stitches: a thread round the part near each end, crossed by short stitches.
		float line = 1.0 - smoothstep(0.004, 0.009, abs(e - 0.16));
		float cross = step(0.55, fract(u * 26.0)) * (1.0 - smoothstep(0.014, 0.022, abs(e - 0.16)));
		c = mix(c, vec3(0.10, 0.05, 0.04), max(line * 0.8, cross) * stitch);
		ALBEDO = c;
		ROUGHNESS = 0.72;
		if (state == 2) {
			float r = abs(fbm(p * 0.45 + vec3(0.0, TIME * 0.4, 0.0)) - 0.5);
			float vein = 1.0 - smoothstep(0.0, 0.05, r);
			float pulse = 0.55 + 0.45 * sin(TIME * 4.0 + seed * 3.0);
			float flick = step(0.15, fract(sin(floor(TIME * 18.0) + seed) * 437.5));
			ALBEDO = c * vec3(0.82, 0.9, 1.0);
			EMISSION = vec3(0.25, 0.55, 1.0) * vein * (pulse * 1.1 + 0.2) * flick + vec3(0.01, 0.025, 0.05) * pulse;
		}
	}
}
