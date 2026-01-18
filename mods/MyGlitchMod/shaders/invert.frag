#pragma header

// Invert color shader - inverts all RGB channels

void main() {
    // Get the texture color
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

    // Only invert if pixel is fully opaque
    if (color.a == 1.0) {
        color.r = 1.0 - color.r;
        color.g = 1.0 - color.g;
        color.b = 1.0 - color.b;
    } else if (color.a > 0.0) {
        // For partially transparent pixels, still invert but preserve alpha
        color.r = 1.0 - color.r;
        color.g = 1.0 - color.g;
        color.b = 1.0 - color.b;
    }

    gl_FragColor = color;
}
