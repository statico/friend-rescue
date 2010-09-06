// Copyright (c) 2010 Ian Langworth

package tc.common.proxies {
	
import flash.events.Event;

public class ListenableNumberEvent extends Event {
	
	public static const CHANGED:String = "listenableNumberChanged";	
	
	private var newValue:Number;
	
	public function ListenableNumberEvent(type:String, newValue:Number,
			bubbles:Boolean=false, cancelable:Boolean=false) {
		super(type, bubbles, cancelable);
		this.newValue = newValue;
	}
	
	public function getNewValue():Number {
		return newValue;
	}
	
}

}