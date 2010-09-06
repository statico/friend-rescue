// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.explosions {

import flash.display.Bitmap;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;

import tc.common.application.IUpdatable;
import tc.common.graphics.AnimatedBitmap;
import tc.common.util.TintUtil;

internal class AbstractDebris extends AnimatedBitmap implements IUpdatable {
	
	public static const DESTROYED:String = 'debrisDestroyedEvent';
	
	protected var lifeLeft:int;
	protected var originalLife:int;
	protected var vx:Number;
	protected var vy:Number;
	
	private var leftBound:int;
	private var topBound:int;
	private var rightBound:int;
	private var bottomBound:int;
	
	public function AbstractDebris(spriteSheet:Bitmap, cellWidth:int, cellHeight:int,
			cellCount:int, duration:int, bounds:Rectangle, tint:ColorTransform) {
		var bitmap:Bitmap;
		if (tint) {
			bitmap = TintUtil.tintBitmap(spriteSheet, tint);
		} else {
			bitmap = spriteSheet;
		}
		
		super(bitmap, cellWidth, cellHeight, cellCount, duration / cellCount);
		
		lifeLeft = 1000;
		originalLife = -1;
		vx = 0;
		vy = 0;
		
		leftBound = bounds.x;
		topBound = bounds.y;
		rightBound = leftBound + bounds.width;
		bottomBound = topBound + bounds.height;
	}
	    
	override public function update(deltaTime:int):void {
		super.update(deltaTime);
		
		x += vx * deltaTime;
		y += vy * deltaTime;
		
		if (originalLife == -1) {
			// This is the first update.
			originalLife = lifeLeft;
		}
		
		if (lifeLeft >= 0) {
			alpha = lifeLeft / originalLife;
			
			lifeLeft -= deltaTime;
			if (lifeLeft < 0) {
				dispatchEvent(new Event(DESTROYED));
			}
		}
		
		// Check edges.
		var radiusX:int = width >> 1;
		var radiusY:int = height >> 1;
		if (x + radiusX > rightBound) {
			x = rightBound - radiusX;
			vx *= -1;
		}
		if (x - radiusX < leftBound) {
			x = leftBound + radiusX;
			vx *= -1;
		}
		if (y + radiusY > bottomBound) {
			y = bottomBound - radiusY;
			vy *= -1;
		}
		if (y - radiusY < topBound) {
			y = topBound + radiusY;
			vy *= -1;
		}
	} 
    
}

}