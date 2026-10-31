shader_type spatial;
// The surface of one piece of material on the decomposition tray (D190): muscle fibres with fat marbling, glossy
// organs with fine veins, dark blood clots, animal meat under a strip of hide. `rot` (0 fresh, 1 stage IV) darkens,
// dulls and moulds it; `frost` rimes it while ice lies on the tray. Bumps come from the same pattern, so the light
// catches the fibres and lumps.

uniform vec3 fresh : source_color = vec3(0.54, 0.23, 0.16);
uniform vec3 rotten : source_color = vec3(0.24, 0.2, 0.13);
uniform int kind = 0;          // 0 muscle, 1 organ, 2 blood, 3 animal, 4 preserved, 5 bone (a cube, D191)
uniform float rot : hint_range(0.0, 1.0) = 0.0;
uniform float frost : hint_range(0.0, 1.0) = 0.0;
instance uniform float seed = 0.0;

varying vec3 lo;               // the piece's own coordinates, about -1..1 across

float hash(vec3 p) {
	p = fract(p * 0.3183099 + 0.1);
	p *= 17.0;
	return fract(p.x * p.y * p.z * (p.x + p.y + p.z));
}

float noise(vec3 x) {
	vec3 i = floor(x);
	vec3 f = fract(x);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(mix(hash(i), hash(i + vec3(1, 0, 0)), f.x), mix(hash(i + vec3(0, 1, 0)), hash(i + vec3(1, 1, 0)), f.x), f.y),
		mix(mix(hash(i + vec3(0, 0, 1)), hash(i + vec3(1, 0, 1)), f.x), mix(hash(i + vec3(0, 1, 1)), hash(i + vec3(1, 1, 1)), f.x), f.y), f.z);
}

float fbm(vec3 p) {
	float a = 0.5;
	float s = 0.0;
	for (int i = 0; i < 4; i++) {
		s += a * noise(p);
		p = p * 2.03 + vec3(1.7, 9.2, 3.1);
		a *= 0.5;
	}
	return s;
}

void vertex() {
	lo = VERTEX / 0.004;
}

void fragment() {
	vec3 p = lo + vec3(seed * 7.13, seed * 3.71, seed * 5.27);
	float n = fbm(p * 1.6);
	vec3 base = fresh;
	float h = n;
	float rough = 0.4;
	if (kind == 0 || kind == 4) {
		// Muscle: fibres running along the piece, a little wavy, with streaks of fat.
		float fib = 0.5 + 0.5 * sin(p.z * 13.0 + p.x * 2.0 + n * 6.0);
		base = fresh * (0.72 + 0.5 * fib);
		float fat = smoothstep(0.6, 0.68, fbm(p * 2.2 + 5.0));
		base = mix(base, vec3(0.86, 0.76, 0.62), fat * 0.75 * (1.0 - rot));
		h = fib * 0.6 + n * 0.4;
		rough = kind == 4 ? 0.55 : 0.32;
	} else if (kind == 1) {
		// Organ: smooth, wet, lobed, with dark veins.
		float v = 1.0 - abs(noise(p * 3.0) * 2.0 - 1.0);
		float veins = smoothstep(0.88, 0.97, v);
		base = fresh * (0.78 + 0.45 * n);
		base = mix(base, fresh * 0.35 + vec3(0.12, 0.0, 0.05), veins * 0.8);
		h = n * 0.6 - veins * 0.4;
		rough = 0.18;
	} else if (kind == 2) {
		// Blood: a glossy clot, nearly black in its pits and folds.
		float pits = smoothstep(0.35, 0.6, fbm(p * 2.6 + 7.0));
		base = fresh * mix(0.25, 0.85, pits) * (0.8 + 0.4 * n);
		h = pits * 0.8 + n * 0.3;
		rough = mix(0.3, 0.1, pits);
	} else if (kind == 5) {
		// Bone: pale and dry, pitted with small pores.
		float pores = smoothstep(0.78, 0.9, noise(p * 7.0));
		base = fresh * (0.86 + 0.22 * n) - vec3(0.25, 0.24, 0.2) * pores;
		h = n * 0.4 - pores * 0.5;
		rough = 0.7;
	} else {
		// Animal: orange meat with a strip of bristly brown hide along the top.
		float fur = noise(p * vec3(16.0, 3.0, 16.0));
		float hide = smoothstep(0.35, 0.55, lo.y + (n - 0.5) * 0.4);
		vec3 meat = fresh * (0.75 + 0.45 * n);
		vec3 skin = vec3(0.24, 0.15, 0.09) * (0.6 + 0.8 * fur);
		base = mix(meat, skin, hide);
		h = mix(n, fur, hide);
		rough = mix(0.45, 0.85, hide);
	}
	// Rot: towards the stage IV colour, mottled green, white mould spots by the end.
	float mott = fbm(p * 1.3 + 11.0);
	base = mix(base, rotten * (0.7 + 0.6 * mott), rot * 0.8);
	base = mix(base, vec3(0.3, 0.36, 0.18), smoothstep(0.5, 0.72, mott) * rot * 0.55);
	float mould = smoothstep(0.86, 0.95, noise(p * 5.0)) * smoothstep(0.5, 1.0, rot);
	base = mix(base, vec3(0.72, 0.74, 0.62), mould);
	rough = mix(rough, 0.88, rot);
	h += mould * 0.6;
	// Frost while ice lies on the tray.
	float rime = frost * smoothstep(0.35, 0.65, noise(p * 6.0 + 3.0));
	base = mix(base, vec3(0.82, 0.88, 0.95), rime * 0.45);
	rough = mix(rough, 0.6, rime);

	ALBEDO = base;
	ROUGHNESS = rough;
	SPECULAR = 0.5;
	// Bump from the pattern (screen-space derivatives), in metres: a few tenths of a millimetre.
	float hm = h * 0.00022;
	vec3 dpdx = dFdx(VERTEX);
	vec3 dpdy = dFdy(VERTEX);
	vec3 r1 = cross(dpdy, NORMAL);
	vec3 r2 = cross(NORMAL, dpdx);
	float det = dot(dpdx, r1);
	vec3 grad = sign(det) * (dFdx(hm) * r1 + dFdy(hm) * r2);
	NORMAL = normalize(abs(det) * NORMAL - grad);
}
