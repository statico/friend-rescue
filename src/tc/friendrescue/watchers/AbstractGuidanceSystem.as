// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.watchers {
	
import flash.display.Sprite;
	
public class AbstractGuidanceSystem {
	
	public static const MODE_IDLE:Number = 0;
	public static const MODE_CHASE:Number = 1;
	public static const MODE_AVOID:Number = 2;
	
	protected var target:Sprite;
	protected var mode:Number;
	
	public function AbstractGuidanceSystem(target:Sprite) {
		this.target = target;
		this.mode = MODE_IDLE;
	}
	
	public function getTarget():Sprite {
		return target;
	}
	
	public function getMode():Number {
		return MODE_CHASE;
	}
	
	public function destroy():void { }
	
	public function applyAvoiders(func:Function):void { }
	
}

}