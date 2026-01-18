package funkin.graphics.shaders;

import flixel.FlxG;
import flixel.addons.display.FlxRuntimeShader;

/**
 * A shader that creates a digital glitch/distortion effect.
 * Features RGB color splitting, scan lines, and horizontal displacement.
 */
@:nullSafety
class GlitchShader extends FlxRuntimeShader
{
  /**
   * The intensity of the glitch effect.
   * 0.0 = no effect, 1.0 = full glitch.
   */
  public var intensity(default, set):Float = 1.0;

  /**
   * The current time value for animation.
   */
  public var time(default, set):Float = 0.0;

  /**
   * The amount of RGB color separation.
   */
  public var rgbSplit(default, set):Float = 0.02;

  /**
   * The frequency of the scan lines.
   */
  public var scanLineFrequency(default, set):Float = 100.0;

  /**
   * The intensity of the scan lines.
   */
  public var scanLineIntensity(default, set):Float = 0.1;

  /**
   * Inline GLSL fragment shader source for digital glitch effect.
   */
  static final FRAGMENT_SHADER:String = '
    #pragma header

    // Digital Glitch Effect Shader
    // Creates a VHS/digital distortion effect with RGB splitting and scan lines
    // Used for the Glitch Note mechanic

    uniform float _intensity;
    uniform float _time;
    uniform float _rgbSplit;
    uniform float _scanLineFreq;
    uniform float _scanLineIntensity;

    // Pseudo-random function for glitch displacement
    float random(vec2 st) {
      return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
    }

    // Noise function for more natural glitching
    float noise(vec2 st) {
      vec2 i = floor(st);
      vec2 f = fract(st);

      float a = random(i);
      float b = random(i + vec2(1.0, 0.0));
      float c = random(i + vec2(0.0, 1.0));
      float d = random(i + vec2(1.0, 1.0));

      vec2 u = f * f * (3.0 - 2.0 * f);

      return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
    }

    void main() {
      vec2 uv = openfl_TextureCoordv;

      // Calculate glitch amount based on time and position
      float glitchStrength = _intensity;

      // Horizontal displacement based on time and Y position
      float blockSize = 0.05;
      float blockY = floor(uv.y / blockSize);
      float glitchLine = step(0.98, random(vec2(_time * 0.1, blockY)));
      float displacement = (random(vec2(_time, blockY)) - 0.5) * 0.1 * glitchStrength * glitchLine;

      // Apply horizontal shift
      vec2 shiftedUV = uv;
      shiftedUV.x += displacement;

      // RGB color splitting (chromatic aberration)
      float splitAmount = _rgbSplit * glitchStrength;

      vec4 colorR = flixel_texture2D(bitmap, vec2(shiftedUV.x + splitAmount, shiftedUV.y));
      vec4 colorG = flixel_texture2D(bitmap, shiftedUV);
      vec4 colorB = flixel_texture2D(bitmap, vec2(shiftedUV.x - splitAmount, shiftedUV.y));

      // Combine RGB channels
      vec4 color = vec4(colorR.r, colorG.g, colorB.b, colorG.a);

      // Add scan lines
      float scanLine = sin(uv.y * _scanLineFreq + _time * 10.0) * 0.5 + 0.5;
      scanLine = pow(scanLine, 2.0);
      color.rgb -= scanLine * _scanLineIntensity * glitchStrength;

      // Add occasional bright flashes on glitch lines
      if (glitchLine > 0.5) {
        float flash = random(vec2(_time * 2.0, blockY));
        if (flash > 0.8) {
          color.rgb += vec3(0.2) * glitchStrength;
        }
      }

      // Add subtle noise overlay
      float noiseVal = noise(uv * 100.0 + _time * 5.0);
      color.rgb += (noiseVal - 0.5) * 0.05 * glitchStrength;

      // Clamp color values
      color.rgb = clamp(color.rgb, 0.0, 1.0);

      gl_FragColor = color;
    }
  ';

  public function new(intensity:Float = 1.0)
  {
    super(FRAGMENT_SHADER);
    this.intensity = intensity;
    this.time = 0.0;
    this.rgbSplit = 0.02;
    this.scanLineFrequency = 100.0;
    this.scanLineIntensity = 0.1;
  }

  /**
   * Updates the shader's time uniform for animation.
   * Call this each frame for animated effects.
   */
  public function update(elapsed:Float):Void
  {
    this.time += elapsed;
  }

  function set_intensity(value:Float):Float
  {
    this.setFloat('_intensity', value);
    this.intensity = value;
    return this.intensity;
  }

  function set_time(value:Float):Float
  {
    this.setFloat('_time', value);
    this.time = value;
    return this.time;
  }

  function set_rgbSplit(value:Float):Float
  {
    this.setFloat('_rgbSplit', value);
    this.rgbSplit = value;
    return this.rgbSplit;
  }

  function set_scanLineFrequency(value:Float):Float
  {
    this.setFloat('_scanLineFreq', value);
    this.scanLineFrequency = value;
    return this.scanLineFrequency;
  }

  function set_scanLineIntensity(value:Float):Float
  {
    this.setFloat('_scanLineIntensity', value);
    this.scanLineIntensity = value;
    return this.scanLineIntensity;
  }
}
