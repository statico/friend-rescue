// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.events {
	
import flash.events.Event;

public class DirectionEvent extends Event {
	
	private var direction:Number;
	
	public function DirectionEvent(type:String, direction:Number,
			bubbles:Boolean=false, cancelable:Boolean=false) {
		super(type, bubbles, cancelable);
		this.direction = direction;
	}
	
	public function getDirection():Number {
		return direction;
	}
	
}

}