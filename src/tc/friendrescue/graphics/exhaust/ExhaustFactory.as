// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.exhaust {
	
import flash.events.Event;

import tc.common.application.ISpriteRegistry;
  
public class ExhaustFactory {
    
  private var app:ISpriteRegistry;
  
	public function ExhaustFactory(app:ISpriteRegistry) {
		this.app = app;
	}
    
	public function makeExhaust(x:Number, y:Number, direction:Number):void {
		var ex:Exhaust = new Exhaust(direction);
		ex.x = x;
		ex.y = y;
		
		app.getParent().addChild(ex);
		app.subscribe(ex);
		ex.addEventListener(Exhaust.DESTROYED, onDestroyed);
	}
		
	private function onDestroyed(e:Event):void {
		var ex:Exhaust = e.target as Exhaust;
		app.unsubscribe(ex);
		try {
			app.getParent().removeChild(ex);
		} catch (e:ArgumentError) {
			// This event might fire twice in one frame.
		}
	}
	
}

}