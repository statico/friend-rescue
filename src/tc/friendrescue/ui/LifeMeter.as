// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.ui {
	
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.utils.Timer;

import tc.common.proxies.ListenableNumber;
import tc.common.proxies.ListenableNumberEvent;
import tc.friendrescue.controllers.SoundController;

public class LifeMeter extends AbstractMeter {
	
	private var value:ListenableNumber;
	
	public function LifeMeter(parent:Sprite, value:ListenableNumber) {
		super();
		this.value = value;
		
		x = 350;
		y = 462;
		width = 95;
		parent.addChild(this);
		
		value.addEventListener(ListenableNumberEvent.CHANGED, function(e:ListenableNumberEvent):void {
			setText('Lives: ' + e.getNewValue());
		});
	}
	
	public function destroy():void {
		if (parent != null) {
			parent.removeChild(this);
		}
	}
	
	override public function blink(duration:int = 1200, count:int = 3):void {
		visible = false;
		var blinker:Timer = new Timer(duration / (count * 2), (count * 2) - 1);
		blinker.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
			visible = !visible;
			if (visible) SoundController.playPing();
		});
		blinker.start();
	}
	
}

}