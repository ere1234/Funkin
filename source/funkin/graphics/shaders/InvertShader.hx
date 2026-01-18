package funkin.graphics.shaders;

import flixel.addons.display.FlxRuntimeShader;

/**
 * A shader that inverts the colors of a sprite.
 * Creates a negative/inverted color effect.
 */
@:nullSafety
class InvertShader extends FlxRuntimeShader
{
  /**
   * The intensity of the invert effect.
   * 0.0 = no effect, 1.0 = full invert.
   */
  public var intensity(default, set):Float = 1.0;

  /**
   * Inline GLSL fragment shader source for color inversion.
   */
  static final FRAGMENT_SHADER:String = '
    #pragma header

    // Invert/Negative color shader with adjustable intensity
    // Used for the Glitch Note mechanic

    uniform float _intensity;

    void main() {
      // Get the original pixel color
      vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

      if (color.a > 0.0) {
        // Calculate inverted colors
        vec3 invertedColor = vec3(1.0 - color.r, 1.0 - color.g, 1.0 - color.b);

        // Mix between original and inverted based on intensity
        color.rgb = mix(color.rgb, invertedColor, _intensity);
      }

      gl_FragColor = color;
    }
  ';

  public function new(intensity:Float = 1.0)
  {
    super(FRAGMENT_SHADER);
    this.intensity = intensity;
  }

  function set_intensity(value:Float):Float
  {
    this.setFloat('_intensity', value);
    this.intensity = value;
    return this.intensity;
  }
}
