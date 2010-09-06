// Copyright (c) 2010 Ian Langworth

package tc.common.preloader {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.TimerEvent;
import flash.utils.Timer;
import flash.utils.getDefinitionByName;

public class FakeAbstractPreloader extends MovieClip {
	
	private var steps:int = 50;
	private var seconds:int = 2;
	private var step:int = 0;
	
	public function FakeAbstractPreloader() {
		stop();
		beginLoading();
		var timer:Timer = new Timer(seconds * 1000 / steps, steps);
		timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
			updateLoading(step / steps);
			step++;
		});
		timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void {
			nextFrame();
			initialize();
			endLoading();
		});
		timer.start();
	}
	
	protected function mainClassName():String {
		return 'Main';
	};
	
	protected function updateLoading(a_percent:Number ):void {}
	protected function beginLoading():void {}
	protected function endLoading():void {}
	protected function mainClassReady(object:DisplayObject):void {}
	
	private function initialize():void {
		var foo:String = mainClassName();
		var MainClass:Class = getDefinitionByName(mainClassName()) as Class;
		if (MainClass == null) {
			throw new Error('AbstractPreloader:initialize. ' +
					'There was no class matching that name. ' +
					'Did you remember to override mainClassName?');
		}
		
		var main:DisplayObject = new MainClass() as DisplayObject;
		if (main == null) {
			throw new Error('AbstractPreloader:initialize. ' +
					'Main class needs to inherit from Sprite or MovieClip.');
		}
		
		mainClassReady(main);
	}
}

}
