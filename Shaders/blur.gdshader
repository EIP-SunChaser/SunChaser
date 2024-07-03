shader_type canvas_item;

uniform sampler2D SCREEN_TEXUTRE : hint_screen_texture, filter_linear_mipmap;
uniform float blur : hint_range(0.0, 2.5);
uniform float blur_brightness : hint_range(0.0, 1.0);

void fragment() {
    COLOR = textureLod(SCREEN_TEXUTRE, SCREEN_UV, blur);
	COLOR.rgb *= blur_brightness;
}
