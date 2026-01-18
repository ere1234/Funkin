#pragma header

// Glitch shader effect - shifts RGB channels and adds distortion

uniform float uTime;
uniform float uIntensity;

float random(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec2 uv = openfl_TextureCoordv;

    // Base intensity (default to 1.0 if not set)
    float intensity = uIntensity > 0.0 ? uIntensity : 1.0;
    float time = uTime > 0.0 ? uTime : 0.0;

    // RGB channel offset based on time
    float offset = 0.01 * intensity * sin(time * 10.0);

    // Add some random jitter
    float jitter = random(vec2(time, uv.y)) * 0.003 * intensity;

    // Sample RGB channels with offset
    float r = flixel_texture2D(bitmap, vec2(uv.x + offset + jitter, uv.y)).r;
    float g = flixel_texture2D(bitmap, vec2(uv.x, uv.y)).g;
    float b = flixel_texture2D(bitmap, vec2(uv.x - offset - jitter, uv.y)).b;
    float a = flixel_texture2D(bitmap, uv).a;

    // Scanline effect
    float scanline = sin(uv.y * 800.0 + time * 5.0) * 0.04 * intensity;

    // Combine
    vec3 color = vec3(r, g, b);
    color -= scanline;

    // Add occasional horizontal glitch lines
    float glitchLine = step(0.99, random(vec2(time * 0.1, floor(uv.y * 50.0))));
    if (glitchLine > 0.5) {
        color = 1.0 - color; // Invert on glitch lines
    }

    gl_FragColor = vec4(color, a);
}
