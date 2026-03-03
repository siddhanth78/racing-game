shader_type canvas_item;

uniform float strength = 0.006;
uniform float flow_speed = 0.03;
uniform float feather_size = 0.05;

uniform vec4 dark_blue  : source_color = vec4(0.0, 0.05, 0.2, 1.0);
uniform vec4 blue       : source_color = vec4(0.0, 0.2, 0.5, 1.0);
uniform vec4 light_blue : source_color = vec4(0.3, 0.6, 0.9, 1.0);
uniform vec4 white      : source_color = vec4(0.9, 0.95, 1.0, 1.0);

void fragment() {
    vec2 uv = UV;

    // Smooth drifting motion
    vec2 flow = vec2(TIME * flow_speed, TIME * flow_speed * 0.6);
    uv += flow;

    float n = 0.0;

    // Layered multi-scale waves
    n += sin(uv.x * 8.0);
    n += sin(uv.y * 9.0);
    n += sin((uv.x + uv.y) * 14.0);
    n += sin((uv.x - uv.y) * 18.0);

    n *= 0.25;

    float height = (n + 1.0) * 0.5;

    vec4 col = mix(dark_blue, blue, height);
    col = mix(col, light_blue, pow(height, 2.0));
    col = mix(col, white, pow(height, 6.0));

    // -------- Feather Edge --------
    // Distance to nearest edge
	float edge = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));

	// small band only at the border
	float fade_width = 0.03;
	float alpha = clamp(edge / fade_width, 0.0, 1.0);

	COLOR = vec4(col.rgb, col.a * alpha);
}