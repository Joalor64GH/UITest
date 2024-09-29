package backend.ui;

import flixel.util.typeLimit.OneOfTwo;
import flixel.input.keyboard.FlxKey;

class UIContextMenu extends SubStateExt {
	public var options:Array<UIContextMenuOption>;
	var x:Float;
	var y:Float;
	var contextCam:FlxCamera;

	var bg:UISliceSprite;
	var callback:UIContextMenuCallback;

	public var contextMenuOptions:Array<UIContextMenuOptionSpr> = [];
	public var separators:Array<FlxSprite> = [];

	private var __oobDeletion:Bool = true;

	public inline function preventOutOfBoxClickDeletion() {
		__oobDeletion = false;
	}

	public function new(options:Array<UIContextMenuOption>, callback:UIContextMenuCallback, x:Float, y:Float) {
		super();
		this.options = options.getDefault([]);
		this.x = x;
		this.y = y;
		this.callback = callback;
	}

	public override function create() {
		super.create();
		camera = contextCam = new FlxCamera();
		contextCam.bgColor = 0;
		contextCam.alpha = 0;
		contextCam.scroll.set(0, 7.5);
		FlxG.cameras.add(contextCam, false);

		bg = new UISliceSprite(x, y, 100, 100, 'editors/ui/context-bg');
		bg.cameras = [contextCam];
		add(bg);

		var lastY:Float = bg.y + 4;
		for(o in options) {
			if (o == null) {
				var spr = new FlxSprite(bg.x + 8, lastY + 2).makeGraphic(1, 1, -1);
				spr.alpha = 0.3;
				separators.push(spr);
				add(spr);
				lastY += 5;
				continue;
			}
			var spr = new UIContextMenuOptionSpr(bg.x + 4, lastY, o, this);
			spr.cameras = [contextCam];
			lastY = spr.y + spr.bHeight;
			contextMenuOptions.push(spr);
			add(spr);

			o.button = spr;
			if (o.onCreate != null) o.onCreate(spr);
		}

		var maxW = bg.bWidth - 8;
		for(o in contextMenuOptions)
			if (o.bWidth > maxW)
				maxW = o.bWidth;

		for(o in contextMenuOptions)
			o.bWidth = maxW;
		for(o in separators) {
			o.scale.set(maxW - 8, 1);
			o.updateHitbox();
		}
		bg.bWidth = maxW + 8;
		bg.bHeight = Std.int(lastY - bg.y + 4);

		if (bg.y + bg.bHeight > FlxG.height) {
			bg.y -= bg.bHeight;
			for(o in contextMenuOptions)
				o.y -= bg.bHeight;
			for(o in separators)
				o.y -= bg.bHeight;
		}
	}

	public function select(option:UIContextMenuOption) {
		var index = options.indexOf(option);
		if (option.onSelect != null)
			option.onSelect(option);
		if (callback != null)
			callback(this, index, option);
		if (option.closeOnSelect == null ? true : option.closeOnSelect)
			close();
	}

	public override function update(elapsed:Float) {
		if (__oobDeletion && FlxG.mouse.justPressed && !bg.hoveredByChild)
			close();

		__oobDeletion = true;

		super.update(elapsed);

		contextCam.scroll.y = CoolUtil.fpsLerp(contextCam.scroll.y, 0, 0.5);
		contextCam.alpha = CoolUtil.fpsLerp(contextCam.alpha, 1, 0.25);
	}

	public override function destroy() {
		super.destroy();
		FlxG.cameras.remove(contextCam);
		if (UIState.state.curContextMenu == this)
			UIState.state.curContextMenu = null;
	}
}

typedef UIContextMenuCallback = UIContextMenu->Int->UIContextMenuOption->Void;
typedef UIContextMenuOption = {
	var label:String;
	var ?keybind:Array<FlxKey>;
	var ?keybinds:Array<Array<FlxKey>>;
	var ?keybindText:String;
	var ?closeOnSelect:Bool;
	var ?color:FlxColor;
	var ?icon:Int;
	var ?onSelect:UIContextMenuOption->Void;
	var ?button:UIContextMenuOptionSpr;
	var ?onCreate:UIContextMenuOptionSpr->Void;
	var ?childs:Array<UIContextMenuOption>;
}