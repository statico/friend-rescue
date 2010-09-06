// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.bullets {
	
import flash.display.Bitmap;
import flash.events.Event;
import flash.geom.ColorTransform;

import tc.common.application.IUpdatable;
import tc.common.graphics.AnimatedBitmap;

public class AbstractBullet extends AnimatedBitmap implements IUpdatable {
	
  public static const DESTROYED:String = 'bulletDestroyedEvent';
  
	public var friendly:Boolean;
	
	protected var speed:Number;
	protected var tint:ColorTransform;
	
	private var dx:Number;
	private var dy:Number;     
	
	public function AbstractBullet(spriteSheet:Bitmap, cellWidth:int, cellHeight:int,
			direction:Number) {
		super(spriteSheet, cellWidth, cellHeight, 1, 0, false);
		
		this.dx = Math.cos((direction + 180) * Math.PI / 180);
		this.dy = Math.sin((direction + 180) * Math.PI / 180);
		this.rotation = direction - 90;
		
		speed = 500 / 1000;
		friendly = true;
	}
	
	public function getTint():ColorTransform {
		return tint;
	}
	
	override public function update(deltaTime:int):void {
		x += dx * speed * deltaTime;
		y += dy * speed * deltaTime;
		if (x < -20 || x > stage.stageWidth + 20 || y < -20 || y > stage.stageHeight + 20) {
			destroy();
		}
	}
	
	public function destroy():void {
		dispatchEvent(new Event(DESTROYED));
	}
	
}

}