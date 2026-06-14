package shitengine.shaders;

class RGBShift extends FlxShader
{
	@:glFragmentSource('
#pragma header

uniform float r;
uniform float g;
uniform float b;

void main() {
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

    if (color.a > 0.0) {
        // Un-premultiply
        vec3 unmultiplied = color.rgb / color.a;

        // Apply tint (add or multiply — your choice)
        vec3 offset = vec3(r, g, b) / 255.0;
        unmultiplied = clamp(unmultiplied + offset, 0.0, 1.0);

        // Re-premultiply
        color.rgb = unmultiplied * color.a;
    }

    gl_FragColor = color;
}
    ')
	public function new()
	{
		super();
	}
}
