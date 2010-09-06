// Copyright (c) 2010 Ian Langworth

/* Courtesy http://www.gamepoetry.com/wpress/2008/05/30/the-last-preloader-youll-ever-need/ */
package tc.common.preloader {

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.events.Event;
import flash.utils.getDefinitionByName;

// This becomes the new "root" of the movie, so it will exist forever.
public class AbstractPreloader extends MovieClip {
	
	private var firstEnterFrame:Boolean;
	
	public function AbstractPreloader() {
		stop();
		firstEnterFrame = true;
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	protected function mainClassName():String {
		return 'Main';
	};
	
	// It's possible this function will never be called if the load is instant
	protected function updateLoading(a_percent:Number ):void {}
	
	// It's possible this function will never be called if the load is instant
	protected function beginLoading():void {}
	
	// It's possible this function will never be called if the load is instant
	// (if beginLoading was called, endLoading will be also)
	protected function endLoading():void {}
	
	protected function mainClassReady(object:DisplayObject):void {}
	
	private function onEnterFrame(event:Event):void {
		if (firstEnterFrame) {
			firstEnterFrame = false;

			if(root.loaderInfo.bytesLoaded >= root.loaderInfo.bytesTotal) {
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				nextFrame();
				initialize();
				endLoading();
			} else {
				beginLoading();
			}
			
			return;
		}

		if(root.loaderInfo.bytesLoaded >= root.loaderInfo.bytesTotal) {
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			nextFrame();
			initialize();
			endLoading();
		} else {
			var percent:Number = root.loaderInfo.bytesLoaded / root.loaderInfo.bytesTotal;
			updateLoading(percent);
		}
	}
		
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
