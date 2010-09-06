// Copyright (c) 2010 Ian Langworth

package tc.common.proxies {
	
import flash.events.EventDispatcher;
	
public class ListenableNumber extends EventDispatcher {
	
	/** We use an offset to slightly throw off cheaters who scan memory. */ 
	private static var OFFSET:Number = 37;
	
	private var value:Number;
	
	public function ListenableNumber() {
		this.value = 0;
	}
	
	private function dispatchUpdate():void {
		var e:ListenableNumberEvent = new ListenableNumberEvent(
				ListenableNumberEvent.CHANGED, getValue());
		dispatchEvent(e);
	}

	public function setValue(value:Number):void {
		this.value = value + OFFSET;
		dispatchUpdate();
	}
	
	public function getValue():Number {
		return value - OFFSET;
	}
	
	public function add(difference:Number):void {
		value += difference;
		dispatchUpdate();
	}
	
	public function subtract(difference:Number):void {
		value -= difference;
		dispatchUpdate();
	}
	
}

}