// Automatically converted with https://github.com/TheLeerName/ShadertoyToFlixel

#pragma header

#define iResolution vec3(openfl_TextureSize, 0.)
uniform float iTime;
#define iChannel0 bitmap
#define texture flixel_texture2D

// end of ShadertoyToFlixel header

// iChannel0 = background texture

float hash(float n)
{
    return fract(sin(n * 123.45) * 45678.9123);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy;

    vec3 col = texture(iChannel0, uv).rgb;

    float rain = 0.0;

    // Wind direction
    vec2 dir = normalize(vec2(-0.4, -1.0));

    for(float i = 0.0; i < 30.0; i++)
    {
        float seed = i;

        float speed = mix(1.5, 4.0, hash(seed + 1.0)) * -1.0;

        vec2 pos;
        pos.x = hash(seed * 17.0) + fract(hash(seed * 31.0) - iTime * 1.7);
        pos.y = fract(hash(seed * 31.0) - iTime * speed);

        vec2 p = uv - pos;

        // Wrap horizontally
        p.x = mod(p.x + 0.5, 1.0) - 0.5;

        float along = dot(p, dir);
        float across = dot(p, vec2(-dir.y, dir.x));

        float streak =
            smoothstep(0.15, 0.0, abs(along)) *
            smoothstep(0.01, 0.0, abs(across));

        rain += streak;
    }

    rain = clamp(rain * 0.8, 0.0, 1.0);

    col += vec3(rain);

    fragColor = vec4(col, texture(iChannel0, uv).a);
}

void main() {
	mainImage(gl_FragColor, openfl_TextureCoordv*openfl_TextureSize);
}