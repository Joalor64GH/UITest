package;

class Main extends openfl.display.Sprite
{
	public final config:Dynamic = {
		dimensions: [1280, 720], 
		framerate: 60,
		initialState: PlayState,
		skipSplash: false,
		startFullscreen: false 
	};

	public function new()
	{
		super();
		addChild(new FlxGame(config.dimensions[0], config.dimensions[1], config.initialState, config.framerate, config.framerate,
			config.skipSplash, config.startFullscreen));
	}
}
