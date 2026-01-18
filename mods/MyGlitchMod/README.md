# Glitch Note Effect Mod

A soft mod for Friday Night Funkin' V-Slice that adds a custom "Glitch Note" type with chaotic visual effects.

## Features

When the opponent hits a "Glitch Note", the following effects occur:
1. **Camera Zoom** - A brief camera zoom effect
2. **HUD Shake** - The HUD tilts and resets
3. **Rapid Shader Toggle** - The opponent character rapidly alternates between glitch and invert shaders 20 times

This creates a chaotic, glitchy visual effect similar to the Psych Engine implementation.

## Installation

1. Copy the `MyGlitchMod` folder to your game's `mods/` directory
2. Enable the mod in the game's mod menu
3. The "Glitch Note" type will be available in the chart editor

## Usage

In the chart editor:
1. Select a note
2. Change its "Kind" to "Glitch Note"
3. When the opponent hits this note during gameplay, the glitch effects will trigger

## Technical Details

This mod uses V-Slice's HScript modding system:
- **GlitchNoteKind.hxc** - Scripted NoteKind class that handles the effect logic
- **glitch.frag** - GLSL fragment shader for RGB channel shifting and scanlines
- **invert.frag** - GLSL fragment shader for color inversion

The rapid shader toggling is achieved using FlxTimer with 20 loops at 0.01 second intervals, replicating the original Psych Engine Lua script behavior.

## Credits

Ported from Psych Engine Lua script to V-Slice HScript.

## License

MIT License
