// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics {
	
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

import tc.common.application.ISpriteRegistry;

public class Wall extends Sprite {
	
	public static const WALL_ACTIVATED:String = 'wallActivated';
	public static const WALL_DEACTIVATED:String = 'wallDeactivated';
	
	public var app:ISpriteRegistry;
	public var bounds:Rectangle;
	public var alarmActivated:Boolean;
	
	public function Wall(app:ISpriteRegistry, bounds:Rectangle = null) {
		super();
		this.app = app;
		app.getParent().addChild(this);
		
		if (bounds != null) {
			this.bounds = bounds;
		} else {
			this.bounds = new Rectangle(12, 12, 480, 426);
		}
		
		const n:int = this.bounds.x;
		const n2:int = n * 2;
		const h:int = this.bounds.height;
		var s:Stage = app.getParent().stage;
		
		// Top, bottom, left, right.
		graphics.beginFill(0xff0000, 0.4);
		graphics.drawRect(0, 0, s.stageWidth, n);
		graphics.drawRect(0, n + h, s.stageWidth, s.stageHeight - h - n);
		graphics.drawRect(0, n, n, h);
		graphics.drawRect(s.stageWidth - n, n, n, h);
		visible = false;
		
		s.addEventListener(Event.MOUSE_LEAVE, function(e:Event):void {
			if (alarmActivated && !visible) {
				visible = true;
				app.pause();
			}
			dispatchEvent(new Event(WALL_ACTIVATED));
		});
		s.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void {
			if (alarmActivated && visible) {
				visible = false;
				app.resume();
			}
			dispatchEvent(new Event(WALL_DEACTIVATED));
		});
	}
	
	public function getBoundsRect():Rectangle {
		return bounds;
	}
	
	public function moveToFront():void {
		app.getParent().addChild(this);
	}
	
	public function destroy():void {
		if (parent != null) {
			parent.removeChild(this);
		}
	}
	
}
	
}