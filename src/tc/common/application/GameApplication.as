// Copyright (c) 2010 Ian Langworth

package tc.common.application {
	
import flash.display.Sprite;
import flash.events.Event;
import flash.utils.Dictionary;
import flash.utils.Timer;
import flash.utils.getTimer;
	
public class GameApplication implements ISpriteRegistry {
	
	private var parent:Sprite;
	private var subscribers:Dictionary;
	private var timer:Timer;
	private var accumulator:int;
	private var timerDelay:int;
	private var running:Boolean;
	
	public function GameApplication(parent:Sprite) {
		this.parent = parent;
		subscribers = new Dictionary();
		accumulator = 0;
		running = true;
		parent.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	public function getParent():Sprite {
		return parent;
	}
	
	public function subscribe(object:IUpdatable):void {
		subscribers[object] = true;
	}
	
	public function unsubscribe(object:IUpdatable):void {
		delete subscribers[object];
	}
	
	private function onEnterFrame(e:Event):void {
    var beforeTime:int = getTimer();
    var deltaTime:int = beforeTime - accumulator;
	    
    // Watch the subscriber count if something seems wrong.
		if (running) {
			for (var subscriber:Object in subscribers) {
				(subscriber as IUpdatable).update(deltaTime);
			}
		}
			
		while (timerDelay > getTimer() - beforeTime) {
			// Do nothing.
		}
		
    accumulator = beforeTime;
	}
	
	public function pause():void {
		running = false;
	}

	public function resume():void {
		running = true;
	}

}

}