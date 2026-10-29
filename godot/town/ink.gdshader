// Ink lines where depth or surface direction changes, drawn over the finished 3D picture, so the town reads like a
// pen drawing. Sits on a full-screen quad in front of the camera.
shader_type spatial;
render_mode unshaded, fog_disabled, depth_test_disabled, depth_draw_never, cull_disabled, shadows_disabled;

uniform sampler2D depth_tex : hint_depth_texture, filter_nearest;
uniform sampler2D normal_tex : hint_normal_roughness_texture, filter_nearest;
uniform vec4 ink : source_color = vec4(0.06, 0.045, 0.04, 1.0);
uniform float depth_k = 0.035;
uniform float normal_k = 0.4;
uniform float strength = 0.9;
uniform float fade_start = 350.0;
uniform float fade_end = 1100.0;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

float lin(vec2 uv, mat4 inv) {
	float d = texture(depth_tex, uv).r;
	vec4 v = inv * vec4(uv * 2.0 - 1.0, d, 1.0);
	return -v.z / v.w;
}

void fragment() {
	vec2 px = 1.6 / VIEWPORT_SIZE;
	vec2 uv = SCREEN_UV;
	float d0 = lin(uv, INV_PROJECTION_MATRIX);
	vec3 n0 = texture(normal_tex, uv).xyz * 2.0 - 1.0;
	float edge = 0.0;
	vec2 offs[4] = vec2[](vec2(px.x, 0.0), vec2(-px.x, 0.0), vec2(0.0, px.y), vec2(0.0, -px.y));
	for (int i = 0; i < 4; i++) {
		float d = lin(uv + offs[i], INV_PROJECTION_MATRIX);
		if (abs(d - d0) / min(d, d0) > depth_k) {
			edge = 1.0;
		}
		vec3 n = texture(normal_tex, uv + offs[i]).xyz * 2.0 - 1.0;
		if (dot(n, n0) < 1.0 - normal_k) {
			edge = max(edge, 0.8);
		}
	}
	float fade = 1.0 - smoothstep(fade_start, fade_end, d0);
	ALBEDO = ink.rgb;
	ALPHA = edge * strength * fade;
}
