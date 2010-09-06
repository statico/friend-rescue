// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.ui {
	
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.utils.Timer;

import tc.common.proxies.ListenableNumber;
import tc.common.proxies.ListenableNumberEvent;

public class ScoreMeter extends AbstractMeter {
	
	private static const SCORE_CYCLE_DURATION:int = 500;
	private static const SCORE_CYCLE_FRAME_MS:int = 50;
	
	private var targetValue:ListenableNumber;
	private var current:Number;
	private var timer:Timer;
	
	public function ScoreMeter(parent:Sprite, targetValue:ListenableNumber) {
		super();
		this.targetValue = targetValue;
		
		x = 9;
		y = 462;
		width = 109;
		parent.addChild(this);
		
		current = 0;
		
		targetValue.addEventListener(ListenableNumberEvent.CHANGED, updateMeter);
	}
	
	private function updateMeter(e:ListenableNumberEvent):void {
		if (timer) {
			timer.stop();
		}
		
		var count:int = SCORE_CYCLE_DURATION / SCORE_CYCLE_FRAME_MS;
		var target:Number = e.getNewValue();
		var step:int = (target - current) / count;
		
		function update(te:TimerEvent):void {
			current += step;
			setText(current.toString());
		}
		function complete(te:TimerEvent):void {
			setText(target.toString());
		}
		
		timer = new Timer(SCORE_CYCLE_FRAME_MS, count);
		timer.addEventListener(TimerEvent.TIMER, update);
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, complete);
		timer.start();
	}
	
	public function getValue():int {
		return targetValue.getValue();
	}
	
	public function destroy():void {
		if (parent != null) {
			parent.removeChild(this);
		}
	}
	
}

}