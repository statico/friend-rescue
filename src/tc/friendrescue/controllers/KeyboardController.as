// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.controllers {
	
import flash.display.Stage;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.KeyboardEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import tc.friendrescue.events.DirectionEvent;
	
public class KeyboardController extends EventDispatcher {
	
	public static const BULLET_FIRE_INTERVAL:int = 90;
	
	public static const FIRE_BULLET:String = 'keyboardControllerFireBullet';
	
	// Probably not the right thing to make this a public static var, but dammit,
	// I'm getting tired of this app.
	public static var enabled:Boolean = true;
	
	private var keyUp:Boolean = false;
	private var keyRight:Boolean = false;
	private var keyDown:Boolean = false;
	private var keyLeft:Boolean = false;
	private var gracePeriod:Boolean = false;
	private var bulletTimer:Timer;
	
	public function KeyboardController(stage:Stage, target:IEventDispatcher = null) {
		super(target);
		
		bulletTimer = new Timer(BULLET_FIRE_INTERVAL);
		bulletTimer.addEventListener(TimerEvent.TIMER, onBulletTimerFire);
		
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
	}
	
	private function onKeyDown(e:KeyboardEvent):void {
		if (e.ctrlKey || e.altKey || e.shiftKey) {
			return;
		}
	  switch (e.charCode) {
	    case 119: keyUp = true; break;
	    case 100: keyRight = true; break;
	    case 115: keyDown = true; break;
	    case 97: keyLeft = true; break;
	    default: return;
	  }
	  gracePeriod = false;
	  bulletTimer.start();
	}
    
	private function onKeyUp(e:KeyboardEvent):void {
		if (e.ctrlKey || e.altKey || e.shiftKey) {
			return;
		}
	  switch (e.charCode) {
	    case 119: keyUp = false; break;
	    case 100: keyRight = false; break;
	    case 115: keyDown = false; break;
	    case 97: keyLeft = false; break;
	    default: return;
	  }
	  if (!(keyUp || keyRight || keyDown || keyLeft)) {
	  	// A grace period makes sure that the player can't hammer the keyboard
	  	// faster than they would shoot if they simply held down the key. 
	  	if (gracePeriod) {
			  bulletTimer.stop();
			  gracePeriod = false;
			} else {
				gracePeriod = true;
			}
	  }
	}
	
	private function onBulletTimerFire(e:TimerEvent):void {
		var direction:Number;
		if (keyUp && keyLeft) direction = 45;
		else if (keyUp && keyRight) direction = 135;
		else if (keyDown && keyLeft) direction = 315;
		else if (keyDown && keyRight) direction = 225;
		else if (keyUp) direction = 90;
		else if (keyRight) direction = 180;
		else if (keyDown) direction = 270;
		else if (keyLeft) direction = 0;
		else return;
		if (enabled) {
			dispatchEvent(new DirectionEvent(KeyboardController.FIRE_BULLET, direction));
		}
	}
}

}