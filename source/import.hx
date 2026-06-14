#if !macro
import animate.FlxAnimate;
import flixel.*;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.*;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.system.FlxAssets.FlxShader;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.*;
import flixel.util.FlxTimer;
import openfl.Assets as OpenFLAssets;
import shitengine.backend.Constants;
import shitengine.backend.assets.Paths;
import shitengine.backend.gameplay.Conductor;
import shitengine.backend.input.Controls.inputSystem;
import shitengine.backend.settings.SaveData;
import shitengine.backend.terminal.CustomLogger;
import shitengine.backend.util.MathUtil;
import shitengine.objects.FunkinSprite;
import shitengine.objects.OffsetSprite;
import shitengine.objects.ui.Alphabet;
import shitengine.util.Define;
#end
import haxe.Json;
import haxe.ds.StringMap;

using StringTools;
