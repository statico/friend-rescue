// Copyright (c) 2010 Ian Langworth

package {
	
import flash.display.DisplayObject;
import flash.events.Event;

import tc.common.preloader.AbstractPreloader;
import tc.common.preloader.SplashScreen;

public class Preloader extends AbstractPreloader {
	
	private var splash:SplashScreen;
	
	public function Preloader() {
		super();
		// Sync width and height with Preloader.
		splash = new SplashScreen(this, 500, 500);
	}
	
	override protected function mainClassName():String {
		return 'FriendRescue';
	}
	
	override protected function updateLoading(percent:Number):void {
		splash.showProgress(percent);
	}
	
	override protected function endLoading():void {
		splash.showProgress(1);
	}
	
	override protected function mainClassReady(main:DisplayObject):void {
		splash.dismiss();
		splash.addEventListener(Event.COMPLETE, function(e:Event):void {
			addChildAt(main, 0);
		});
	}
}

}
