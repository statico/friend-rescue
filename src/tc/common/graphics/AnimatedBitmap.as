// Copyright (c) 2010 Ian Langworth

package tc.common.graphics {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

import tc.common.application.IUpdatable;

public class AnimatedBitmap extends Sprite implements IUpdatable {
	
	private static const topLeft:Point = new Point(0, 0);
	
	private var canvas:Bitmap;
	private var spriteSheet:Bitmap;
	private var cellWidth:int;
	private var cellHeight:int;
	private var cellCount:int;
	private var speed:int;
	private var loop:Boolean;
	private var step:int;
	private var ticks:int;
	
	public function AnimatedBitmap(spriteSheet:Bitmap, cellWidth:int, cellHeight:int,
			cellCount:int, speed:int, loop:Boolean = true) {
		super();
		this.spriteSheet = spriteSheet;
		this.cellWidth = cellWidth;
		this.cellHeight = cellHeight;
		this.cellCount = cellCount;
		this.speed = speed;
		this.loop = loop;
		
		step = 0;
		ticks = 0;
		
		canvas = new Bitmap(new BitmapData(cellWidth, cellHeight));
		canvas.pixelSnapping = PixelSnapping.ALWAYS;
		canvas.x = -cellWidth * 0.5;
		canvas.y = -cellHeight * 0.5;
		addChild(canvas);
		
		draw();
	}
	
	protected function drawStep(step:int):void {
		this.step = step;
		draw();
	}
	
	private function draw():void {
		var r:Rectangle = new Rectangle(step * cellWidth, 0, cellWidth, cellHeight);
		canvas.bitmapData.copyPixels(spriteSheet.bitmapData, r, topLeft);
	}
	
	public function update(deltaTime:int):void {
		if (speed > 0) {
			ticks += deltaTime;
			if (ticks > speed) {
				step += ticks / speed;
				if (!loop && step >= cellCount) {
					canvas.bitmapData.fillRect(new Rectangle(0, 0, cellWidth, cellHeight), 0);
					speed = 0;
					loopFinished();
				} else {
					step = step % cellCount;
					ticks = ticks % speed;
					draw();
				}
			}
		}
	}
	
	protected function loopFinished():void { }
	
}

}