// Copyright (c) 2010 Ian Langworth

package tc.common.graphics {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

import tc.common.application.IUpdatable;

public class RandomBitmap extends Sprite implements IUpdatable {
	
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
	
	public function RandomBitmap(spriteSheet:Bitmap, cellWidth:int, cellHeight:int,
			cellCount:int) {
		canvas = new Bitmap(new BitmapData(cellWidth, cellHeight));
		canvas.pixelSnapping = PixelSnapping.ALWAYS;
		canvas.x = -cellWidth * 0.5;
		canvas.y = -cellHeight * 0.5;
		addChild(canvas);
		
		var index:int = Math.random() * cellCount;	
		var r:Rectangle = new Rectangle(index * cellWidth, 0, cellWidth, cellHeight);
		canvas.bitmapData.copyPixels(spriteSheet.bitmapData, r, topLeft);
	}
	
	public function update(deltaTime:int):void { }
}

}