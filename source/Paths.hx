package;

#if sys
import sys.FileSystem;
import sys.io.File;
#end
import haxe.io.Path;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFramesCollection;

class Paths {
	public static var tempFramesCache:Map<String, FlxFramesCollection> = [];

	inline public static final DEFAULT_FOLDER:String = 'assets';

	static public function getPath(folder:Null<String>, file:String) {
		if (folder == null)
			folder = DEFAULT_FOLDER;
		return folder + '/' + file;
	}

	static public function file(file:String, folder:String = DEFAULT_FOLDER) {
		if (#if sys FileSystem.exists(folder) && #end (folder != null && folder != DEFAULT_FOLDER)) {
			return getPath(folder, file);
		}
		return getPath(null, file);
	}

	inline static public function txt(key:String) {
		return file('data/$key.txt');
	}

	inline static public function xml(key:String) {
		return file('data/$key.xml');
	}

	inline static public function json(key:String) {
		return file('data/$key.json');
	}

	#if yaml
	inline static public function yaml(key:String) {
		return file('data/$key.yaml');
	}
	#end

	inline static public function sound(key:String) {
		return file('sounds/$key.ogg');
	}

	inline static public function soundRandom(key:String, min:Int, max:Int) {
		return file('sounds/$key${FlxG.random.int(min, max)}.ogg');
	}

	inline static public function music(key:String) {
		return file('music/$key.ogg');
	}

	inline static public function image(key:String) {
		return file('images/$key.png');
	}

	inline static public function font(key:String) {
		return file('fonts/$key');
	}

	inline static public function getSparrowAtlas(key:String)
		return FlxAtlasFrames.fromSparrow(image(key), file('images/$key.xml'));

	inline static public function getSparrowAtlasAlt(key:String)
		return FlxAtlasFrames.fromSparrow('$key.png', '$key.xml');

	inline static public function getPackerAtlas(key:String)
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key), file('images/$key.txt'));

	inline static public function getPackerAtlasAlt(key:String)
		return FlxAtlasFrames.fromSpriteSheetPacker('$key.png', '$key.txt');

	inline static public function getAsepriteAtlas(key:String)
		return FlxAtlasFrames.fromAseprite(image(key), file('images/$key.json'));

	inline static public function getAsepriteAtlasAlt(key:String)
		return FlxAtlasFrames.fromAseprite('$key.png', '$key.json');

	public static function getFrames(key:String, assetsPath:Bool = false) {
		if (tempFramesCache.exists(key)) {
			var frames = tempFramesCache[key];
			if (frames.parent != null && frames.parent.bitmap != null && frames.parent.bitmap.readable)
				return frames;
			else
				tempFramesCache.remove(key);
		}
		return tempFramesCache[key] = loadFrames(assetsPath ? key : Paths.image(key));
	}

	static function loadFrames(path:String, Unique:Bool = false, Key:String = null, SkipAtlasCheck:Bool = false):FlxFramesCollection {
		var notExts:String = switch (Path.extension(path).toLowerCase()) {
			case "png": file(path.substring(0, path.length - 4));
			default: path;
		}
		var noExt:String = Path.withoutExtension(getPath(path));
		var hasNoEx:String = Path.withoutExtension(path);

		if (FileSystem.exists('$notExts/1.png')) {
			trace('multiple sprite sheets on $notExts.');

			var graphic = FlxG.bitmap.add("flixel/images/logo/default.png", false, '$notExts/mult');
			var frames = MultiFramesCollection.findFrame(graphic);
			if (frames != null)
				return frames;

			trace("no frames yet for multiple atlases!!");
			var cur = 1;
			var finalFrames = new MultiFramesCollection(graphic);
			while (FileSystem.exists('$notExts/$cur.png')) {
				var spr = loadFrames('$notExts/$cur.png');
				finalFrames.addFrames(spr);
				cur++;
			}
			return finalFrames;
		} else if (FileSystem.exists('$noExt/1.png')) {
			trace('multiple sprite sheets on $noExt.');

			var graphic = FlxG.bitmap.add("flixel/images/logo/default.png", false, '$noExt/mult');
			var frames = MultiFramesCollection.findFrame(graphic);
			if (frames != null)
				return frames;

			trace("no frames yet for multiple atlases!!");
			var cur = 1;
			var finalFrames = new MultiFramesCollection(graphic);
			while (FileSystem.exists('$noExt/$cur.png')) {
				var spr = loadFrames('$noExt/$cur.png');
				finalFrames.addFrames(spr);
				cur++;
			}
			return finalFrames;
		} else if (FileSystem.exists('$hasNoEx/1.png')) {
			trace('multiple sprite sheets on $hasNoEx.');

			var graphic = FlxG.bitmap.add("flixel/images/logo/default.png", false, '$hasNoEx/mult');
			var frames = MultiFramesCollection.findFrame(graphic);
			if (frames != null)
				return frames;

			trace("no frames yet for multiple atlases!!");
			var cur = 1;
			var finalFrames = new MultiFramesCollection(graphic);
			while (FileSystem.exists('$hasNoEx/$cur.png')) {
				var spr = loadFrames('$hasNoEx/$cur.png');
				finalFrames.addFrames(spr);
				cur++;
			}
			return finalFrames;
		} else if (FileSystem.exists('$noExt.xml')) {
			return Paths.getSparrowAtlasAlt(noExt);
		} else if (FileSystem.exists('$noExt.txt')) {
			return Paths.getPackerAtlasAlt(noExt);
		} else if (FileSystem.exists('$noExt.json')) {
			return Paths.getAsepriteAtlasAlt(noExt);
		}

		var graph:FlxGraphic = null;
		try {
			graph = FlxG.bitmap.add(hasNoEx, Unique, Key);
		} catch (e:haxe.Exception) {
			trace(e.message);
			return null;
		}
		return graph.imageFrame;
	}
}