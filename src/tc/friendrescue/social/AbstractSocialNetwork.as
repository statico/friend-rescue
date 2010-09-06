// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.social {

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;

import tc.common.marshalling.SignedSerializer;

public class AbstractSocialNetwork extends EventDispatcher {
	
    // Of course, if someone decompiles the SWF, they'll be able to fake RPC
    // requests to the backend. That's okay -- if someone is willing to go
    // through the effort to cheat and get a high score, more power to 'em :)
	private static const RPC_KEY:String = '1111111128271';
	
	private static const PROD_RPC_HOST:String = 'http://tc-friend-rescue.tremendous-creations.com';
	private static const DEV_RPC_HOST:String = 'http://powerbox.langworth.com:8123';
	
	protected var gameStartTime:int;
	
	private var rpcBaseUrl:String;
	
	public function AbstractSocialNetwork(development:Boolean, rpcPath:String,
				target:IEventDispatcher = null) {
		super(target);
		rpcBaseUrl = (development ? DEV_RPC_HOST : PROD_RPC_HOST) + rpcPath;
	}
	
	public function getNetworkName():String { return null; }
	
	public function getHighScore():int { return -1; }
	
	public function loadFriendInfo():void {}
	
	public function getRescuableFriend():Friend { return null; }
	
	public function getBossFriend():Friend { return null; }
	
	public function getTopFriends():Array { return null; }
	
	public function recordFriendAsRescued(friend:Friend):void {}
	
	public function recordFriendAsDestroyed(friend:Friend):void {}
	
	public function recordFriendAsDefeated(friend:Friend):void {}
	
	public function recordGameBegin():void {}
	
	public function recordGameEnd(level:int, score:int):void {}
	
	protected function rpc(method:String, data:Object):URLLoader {
		var request:URLRequest = new URLRequest(rpcBaseUrl + method);
		request.method = URLRequestMethod.POST;
		request.data = SignedSerializer.encode(RPC_KEY, data);
		
		var loader:URLLoader = new URLLoader(request);
		loader.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void {
			dispatchEvent(new SocialNetworkEvent(SocialNetworkEvent.ERROR, null, e.target.data));
			
		});
			
		return loader;
	}
	
	protected function decodeData(input:String):Object {
		return SignedSerializer.decode(RPC_KEY, input);
	}
	
}

}
