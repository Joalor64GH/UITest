#if !macro
import flixel.*;
import flixel.util.*;
import flixel.math.*;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.input.keyboard.FlxKey;

import openfl.Assets;
import Paths;

#if (sys || desktop)
import sys.io.File;
import sys.FileSystem;
#end

import backend.ui.*;

using CoolUtil;
using StringTools;
#end