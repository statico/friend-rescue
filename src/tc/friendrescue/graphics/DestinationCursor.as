// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics {
	
import flash.display.Bitmap;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.ui.Mouse;

import tc.common.application.ISpriteRegistry;
import tc.common.application.IUpdatable;
import tc.common.graphics.AnimatedBitmap;

public class DestinationCursor extends AnimatedBitmap implements IUpdatable {
	
	[Embed(source='../../../../graphics/cursor.png')]
	private static const CursorPNG:Class;
	private static const cursor:Bitmap = new CursorPNG() as Bitmap;
	
	private var app:ISpriteRegistry;
	
	public function DestinationCursor(app:ISpriteRegistry) {
		super(cursor, 24, 25, 6, 1000 / 12);
		
		this.app = app;
		app.getParent().addChild(this);
		app.subscribe(this);
	
		addEventListener(Event.REMOVED, onRemoved);
		mouseEnabled = false; // Objects _under_ the sprite should get clicks.
		
		stage.addEventListener(Event.MOUSE_LEAVE, function(e:Event):void {
			visible = false;
			Mouse.show();
		});
		stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:Event):void {
			visible = true;
			Mouse.hide();
		});
	}
	
	public function moveToFront():void {
		app.getParent().addChild(this);
	}
	
	override public function update(deltaTime:int):void {
		super.update(deltaTime);
		x = app.getParent().stage.mouseX;
		y = app.getParent().stage.mouseY;
	}
	
	private function onRemoved(e:Event):void {
		try {
			app.unsubscribe(this);
		} catch (e:ArgumentError) {
			// Could be called after this sprite has been removed.
		}
		Mouse.show();
	} 
	
	public function destroy():void {
		app.unsubscribe(this);
		app.getParent().removeChild(this);
	} 
}

}