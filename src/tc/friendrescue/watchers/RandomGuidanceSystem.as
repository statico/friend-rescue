// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.watchers {
	
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.TimerEvent;
import flash.utils.Timer;

public class RandomGuidanceSystem extends AbstractGuidanceSystem {
	
	private var maxWidth:int;
	private var maxHeight:int;
	private var timer:Timer;
	private var stage:Stage;
	private var dummy:DisplayObject
	
	public function RandomGuidanceSystem(maxWidth:int, maxHeight:int, stage:Stage) {
		this.maxWidth = maxWidth;
		this.maxHeight = maxHeight;
		this.stage = stage;
		
		var randomTarget:Sprite = new Sprite();
		super(randomTarget);
		
		moveTargetToRandomLocation();
		
		timer = new Timer(1000);
		timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
			moveTargetToRandomLocation();
		});
		timer.start();
		
		dummy = new Shape();
	}
	
	private function moveTargetToRandomLocation():void {
		target.x = Math.random() * maxWidth;
		target.y = Math.random() * maxHeight;
	}
		
	override public function destroy():void {
		timer.stop();
	}
	
	override public function applyAvoiders(func:Function):void {
		dummy.x = stage.mouseX;
		dummy.y = stage.mouseY;
		func.call(null, dummy);
	}

}

}