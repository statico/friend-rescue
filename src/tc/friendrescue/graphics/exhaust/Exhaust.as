// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.exhaust {
  
import flash.display.Bitmap;
import flash.events.Event;

import tc.common.graphics.RandomBitmap;

internal class Exhaust extends RandomBitmap {
  
	[Embed(source='../../../../../graphics/exhaust.png')]
	private static const ExhaustPNG:Class;
	private static const exhaust:Bitmap = new ExhaustPNG() as Bitmap;
	
	public static const DESTROYED:String = 'exhaustExpiredEvent';
	
  private static const LIFE:Number = 20;
  
	private var lifeLeft:int;
	private var dx:Number;
	private var dy:Number;     
	    
	public function Exhaust(direction:Number) {
		super(exhaust, 23, 7, 4);
		this.dx = Math.cos((direction + 180) * Math.PI / 180);
		this.dy = Math.sin((direction + 180) * Math.PI / 180);
		rotation = direction + 180;
		lifeLeft = LIFE;
	}
	    
	override public function update(deltaTime:int):void {
		super.update(deltaTime);
		
		x += dx;
		y += dy;
		      
		lifeLeft--;
		if (lifeLeft <= 0) {
			dispatchEvent(new Event(DESTROYED));
		}
	}
    
}

}