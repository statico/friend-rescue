// Copyright (c) 2010 Ian Langworth

package tc.common.application {
	
import flash.display.Sprite;
	
public interface ISpriteRegistry {
	
	function subscribe(object:IUpdatable):void;
	
	function unsubscribe(object:IUpdatable):void;
	
	function getParent():Sprite;
	
	function pause():void;
	
	function resume():void;
	
}

}