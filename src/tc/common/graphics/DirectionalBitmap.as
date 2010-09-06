// Copyright (c) 2010 Ian Langworth

package tc.common.graphics {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.PixelSnapping;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

import tc.common.application.IUpdatable;

public class DirectionalBitmap extends Sprite implements IUpdatable {
	
	private static const topLeft:Point = new Point(0, 0);
	
	private var pseudoRotation_:int;
	
	private var canvas:Bitmap;
	private var spriteSheet:Bitmap;
	private var cellWidth:int;
	private var cellHeight:int;
	private var degreesDivisor:Number;
	
	public function DirectionalBitmap(spriteSheet:Bitmap, cellWidth:int, cellHeight:int,
			cellCount:int) {
		super();
		this.spriteSheet = spriteSheet;
		this.cellWidth = cellWidth;
		this.cellHeight = cellHeight;
		
		canvas = new Bitmap(new BitmapData(cellWidth, cellHeight));
		canvas.pixelSnapping = PixelSnapping.ALWAYS;
		canvas.x = -cellWidth * 0.5;
		canvas.y = -cellHeight * 0.5;
		addChild(canvas);
		
		degreesDivisor = 360 / cellCount;
		
		// set() calls draw(), which requires canvas and degreesDivisor to be set. 
		pseudoRotation = 0;
	}
	
	public function set pseudoRotation(value:int):void {
		if (value > 360) {
			pseudoRotation_ = value % 360;
		} else if (value < 0) {
			pseudoRotation_ = 360 - ((value * -1) % 360);
		} else {
			pseudoRotation_ = value;
		}
		draw();
	}
	
	public function get pseudoRotation():int {
		return pseudoRotation_;
	}
	
	private function draw():void {
		var index:int = pseudoRotation / degreesDivisor;
		var r:Rectangle = new Rectangle(index * cellWidth, 0, cellWidth, cellHeight);
		canvas.bitmapData.copyPixels(spriteSheet.bitmapData, r, topLeft);
	}
	
	public function update(deltaTime:int):void { }
	
}

}