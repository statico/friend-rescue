// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.explosions {
	
import flash.display.Bitmap;
import flash.events.Event;

import tc.common.application.IUpdatable;
import tc.common.graphics.AnimatedBitmap;

internal class AbstractExplosion extends AnimatedBitmap implements IUpdatable {
	
	public static const DESTROYED:String = 'explosionDestroyedEvent';
	
	public function AbstractExplosion(spriteSheet:Bitmap, cellWidth:int, cellHeight:int,
			cellCount:int, duration:int) {
		super(spriteSheet, cellWidth, cellHeight, cellCount, duration / cellCount, false);
	}
	    
	override protected function loopFinished():void {
		dispatchEvent(new Event(DESTROYED));
	}
    
}

}