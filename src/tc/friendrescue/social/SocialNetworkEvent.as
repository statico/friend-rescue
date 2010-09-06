// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.social {
	
import flash.events.Event;

public class SocialNetworkEvent extends Event {
	
	public static const PROGRESS:String = 'socialNetworkLoadProgress';
	public static const ERROR:String = 'socialNetworkError';
	public static const RESCUABLE_FRIEND_CREATED:String = 'rescuableFriendCreated';
	public static const RESCUABLE_FRIEND_RESCUED:String = 'rescuableFriendRescued';
	public static const RESCUABLE_FRIEND_DESTROYED:String = 'rescuableFriendDestroyed';
	public static const BOSS_FRIEND_CREATED:String = 'bossFriendCreated';
	public static const BOSS_FRIEND_DESTROYED:String = 'bossFriendDestroyed';
	
	public var data:Object;
	public var amountLoaded:int;
	public var amountTotal:int;
	public var errorMessage:String;
	
	public function SocialNetworkEvent(type:String, data:Object = null,
			errorMessage:String = null, amountLoaded:int = 0, amountTotal:int = 0,
			bubbles:Boolean=false, cancelable:Boolean=false) {
		super(type, bubbles, cancelable);
		this.data = data;
		this.amountLoaded = amountLoaded;
		this.amountTotal = amountTotal;
		this.errorMessage = errorMessage;
	}
	
	override public function toString():String {
		return "[SocialNetworkEvent" +
			" type=" + type +
			" data=" + data +
			" errorMessage=" + errorMessage +
			" amountLoaded=" + amountLoaded +
			" amountTotal=" + amountTotal +
			"]";
	}
	
}

}