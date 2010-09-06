// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.watchers {
	
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.utils.Timer;

/**
* A Proxy for a real GuidanceSystem which "lags" -- the target is only updated
* once after every N seconds.
*/
public class RusherGuidanceSystem extends AbstractGuidanceSystem {
	
	private var real:AbstractGuidanceSystem;
	private var fakeTarget:Sprite;
	private var updateTimer:Timer;
	
	public function RusherGuidanceSystem(real:AbstractGuidanceSystem,
			initialX:int, initialY:int, updateTicks:int) {
		super(target);
		this.real = real;
		
		fakeTarget = new Sprite();
		fakeTarget.x = initialX;
		fakeTarget.y = initialY;
		
		updateTimer = new Timer(updateTicks);
		updateTimer.addEventListener(TimerEvent.TIMER, onTimerUpdate);
		updateTimer.start();
	}
	
	override public function getTarget():Sprite {
		return fakeTarget;
	}
	
	override public function getMode():Number {
		return real.getMode();
	}
	
	override public function applyAvoiders(func:Function):void {
		real.applyAvoiders(func);
	}
	
	private function onTimerUpdate(e:TimerEvent):void {
		fakeTarget.x = real.getTarget().x;
		fakeTarget.y = real.getTarget().y;
	}
	
	override public function destroy():void {
		updateTimer.stop();
		updateTimer.removeEventListener(TimerEvent.TIMER, onTimerUpdate);
		super.destroy();
	}
	
}

}