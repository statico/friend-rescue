// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.ui {
	
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;

import tc.common.application.ISpriteRegistry;
import tc.common.application.IUpdatable;
import tc.common.util.ColorUtil;

public class ConsoleBackground extends Sprite implements IUpdatable {
	
	[Embed(source='../../../../graphics/console.png')]
	private static const ConsolePNG:Class;
	private static const console:Bitmap = new ConsolePNG() as Bitmap;
	
	private static const MAX_TWINKLES:int = 20;
	private static const TWINKLE_RADIUS:Number = 1;
	private static const TWINKLE_UPDATE_PERIOD:int = 100;
	
	private var app:ISpriteRegistry;
	private var stars:Bitmap;
	[Array('int')]
	private var tx:Array;
	[Array('int')]
	private var ty:Array;
	private var ti:int;
	private var sw:int;
	private var sh:int;
	private var step:int;
	
	public function ConsoleBackground(app:ISpriteRegistry) {
		super();
		this.app = app;
		
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		app.getParent().addChild(this);
	}
	
	private function onAddedToStage(e:Event):void {
		sw = stage.stageWidth;
		sh = stage.stageHeight;
		step = 0;
		
		// Init the X/Y twinkle location array.
		// (Two arrays is much faster than using Point objects.)
		tx = new Array();
		ty = new Array();
		for (var j:int = 0; j < MAX_TWINKLES; j++) {
			tx[j] = -10;
			ty[j] = -10;
		}
		ti = 0;

		// Draw background.
		stars = new Bitmap(new BitmapData(sw, sh, false, 0x000000));
		addChild(stars);
		
		// Draw stars.
		for (var i:int = 0; i < 1000; i++) {
			stars.bitmapData.setPixel(Math.random() * sw, Math.random() * sh, randomColor());
		}
		
		// Add console.
		addChild(console);
		
		app.subscribe(this);
	}
	
	private function randomColor():int {
		var hue:int = Math.random() * 360;
		var value:int = Math.random() * 50;
		return ColorUtil.HSBToRGB(hue, 25, value);
	}
	
	public function update(timeDelta:int):void {
		step += timeDelta;
		if (step > TWINKLE_UPDATE_PERIOD) {
			stars.bitmapData.setPixel(tx[ti], ty[ti], 0x000000);
			
			tx[ti] = Math.random() * sw;
			ty[ti] = Math.random() * sh;
			stars.bitmapData.setPixel(tx[ti], ty[ti], 0xffffff);
			
			ti = (ti + 1) % MAX_TWINKLES;
			step = 0;
		}
	}
	
}

}