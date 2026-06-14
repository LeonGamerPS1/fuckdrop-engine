#if !macro
import animate.FlxAnimate;
import backend.Constants;
import backend.assets.Paths;
import backend.gameplay.Conductor;
import backend.input.Controls.inputSystem;
import backend.settings.SaveData;
import backend.terminal.CustomLogger;
import backend.util.MathUtil;
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
import objects.FunkinSprite;
import objects.OffsetSprite;
import objects.ui.Alphabet;
import openfl.Assets as OpenFLAssets;
import util.Define;
#end
import haxe.Json;
import haxe.ds.StringMap;

using StringTools;
