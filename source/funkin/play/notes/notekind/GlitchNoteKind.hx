package funkin.play.notes.notekind;

import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxTimer;
import funkin.modding.events.ScriptEvent;
import funkin.modding.events.ScriptEvent.HitNoteScriptEvent;
import funkin.graphics.shaders.InvertShader;
import funkin.graphics.shaders.GlitchShader;
import funkin.play.PlayState;
import funkin.play.character.BaseCharacter;

/**
 * A custom note kind that triggers glitch effects when hit by the opponent.
 * Ported from Psych Engine Lua implementation.
 *
 * Effects include:
 * - Camera zoom bump
 * - Camera shake
 * - HUD angle shake
 * - Shader effects on the opponent (rapid toggle between invert and glitch)
 */
class GlitchNoteKind extends NoteKind
{
  /**
   * Duration of the glitch effect in seconds.
   */
  static inline final GLITCH_DURATION:Float = 0.3;

  /**
   * Number of shader toggles during the glitch effect.
   */
  static inline final SHADER_TOGGLE_COUNT:Int = 6;

  /**
   * Camera zoom amount to add on hit.
   */
  static inline final CAMERA_ZOOM_AMOUNT:Float = 0.03;

  /**
   * Camera shake intensity.
   */
  static inline final CAMERA_SHAKE_INTENSITY:Float = 0.01;

  /**
   * Camera shake duration.
   */
  static inline final CAMERA_SHAKE_DURATION:Float = 0.1;

  /**
   * HUD angle for the shake effect.
   */
  static inline final HUD_SHAKE_ANGLE:Float = 3.0;

  /**
   * HUD shake reset duration.
   */
  static inline final HUD_SHAKE_RESET_DURATION:Float = 0.1;

  /**
   * The invert shader used for the negative effect.
   */
  var invertShader:InvertShader;

  /**
   * The glitch shader used for the digital glitch effect.
   */
  var glitchShader:GlitchShader;

  /**
   * Timer for managing shader toggles.
   */
  var shaderToggleTimer:FlxTimer;

  /**
   * Counter for tracking shader toggle state.
   */
  var toggleCount:Int = 0;

  /**
   * Whether the glitch effect is currently active.
   */
  var glitchActive:Bool = false;

  public function new(?noteKind:String)
  {
    super(noteKind ?? 'glitch-note', 'Glitch Note - Triggers visual glitch effects on opponent hit');

    // Initialize shaders
    invertShader = new InvertShader();
    glitchShader = new GlitchShader();
    shaderToggleTimer = new FlxTimer();
  }

  /**
   * Called when a note of this kind is hit.
   * Triggers the glitch effects on opponent hit.
   */
  override public function onNoteHit(event:HitNoteScriptEvent):Void
  {
    super.onNoteHit(event);

    // Only trigger effects for opponent notes (strumline index 1)
    if (event.note == null || event.note.noteData == null) return;
    if (event.note.noteData.getStrumlineIndex() != 1) return;

    // Trigger glitch effects
    triggerGlitchEffects();
  }

  /**
   * Triggers all the glitch effects:
   * - Camera zoom
   * - Camera shake
   * - HUD shake
   * - Shader effects on opponent
   */
  function triggerGlitchEffects():Void
  {
    if (PlayState.instance == null) return;

    // 1. Camera Zoom - add zoom bump
    PlayState.instance.cameraBopMultiplier += CAMERA_ZOOM_AMOUNT;

    // 2. Camera Shake
    if (FlxG.camera != null)
    {
      FlxG.camera.shake(CAMERA_SHAKE_INTENSITY, CAMERA_SHAKE_DURATION);
    }

    // 3. HUD Shake - tilt the HUD camera and reset
    if (PlayState.instance.camHUD != null)
    {
      PlayState.instance.camHUD.angle = HUD_SHAKE_ANGLE;
      FlxTween.tween(PlayState.instance.camHUD, {angle: 0}, HUD_SHAKE_RESET_DURATION, {ease: FlxEase.quartOut});
    }

    // 4. Shader Effects on Opponent
    triggerShaderEffects();
  }

  /**
   * Triggers the shader toggle effect on the opponent character.
   * Rapidly switches between invert and glitch shaders.
   */
  function triggerShaderEffects():Void
  {
    if (PlayState.instance == null || PlayState.instance.currentStage == null) return;

    var dad:BaseCharacter = PlayState.instance.currentStage.getDad();
    if (dad == null) return;

    // Don't start a new effect if one is already running
    if (glitchActive) return;

    glitchActive = true;
    toggleCount = 0;

    // Update the glitch shader time
    glitchShader.update(FlxG.elapsed);

    // Start the shader toggle sequence
    doShaderToggle(dad);
  }

  /**
   * Performs a single shader toggle iteration.
   * Alternates between invert and glitch shaders.
   */
  function doShaderToggle(dad:BaseCharacter):Void
  {
    if (dad == null)
    {
      glitchActive = false;
      return;
    }

    if (toggleCount >= SHADER_TOGGLE_COUNT)
    {
      // Reset to no shader when done
      @:privateAccess
      dad.shader = null;
      glitchActive = false;
      return;
    }

    // Toggle between shaders
    if (toggleCount % 2 == 0)
    {
      @:privateAccess
      dad.shader = invertShader;
    }
    else
    {
      // Update glitch shader with current time
      glitchShader.update(FlxG.elapsed);
      @:privateAccess
      dad.shader = glitchShader;
    }

    toggleCount++;

    // Schedule next toggle
    var toggleInterval:Float = GLITCH_DURATION / SHADER_TOGGLE_COUNT;
    shaderToggleTimer.start(toggleInterval, function(_) {
      doShaderToggle(dad);
    });
  }

  override public function onDestroy(event:ScriptEvent):Void
  {
    super.onDestroy(event);

    // Clean up timer
    if (shaderToggleTimer != null)
    {
      shaderToggleTimer.cancel();
    }
  }
}
