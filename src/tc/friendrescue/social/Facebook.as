// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.social {
	
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.utils.getTimer;
	
public class Facebook extends AbstractSocialNetwork {
	
	private static const RPC_PATH:String = '/fb/rpc/';
	
	private var uid:int;
	private var root:DisplayObject;
	private var rescuableFriends:Array;
	private var bossFriends:Array;
	private var amountLoaded:int;
	private var amountTotal:int;
	private var friendsToLoad:Array;
	private var highScore:int;
	
	public function Facebook(development:Boolean, root:DisplayObject,
			target:IEventDispatcher = null) {
		super(development, RPC_PATH, target);
		this.root = root;
		this.rescuableFriends = new Array();
		this.bossFriends = new Array();
	}
	
	override public function getNetworkName():String {
		return 'Facebook';
	}
	
	override public function getHighScore():int {
		return highScore;
	}
	
	override public function loadFriendInfo():void {
		dispatchProgress(0);
		
		var loader1:URLLoader = rpc('GetHighScore', null);
		loader1.addEventListener(Event.COMPLETE, onHighScoreComplete);
		
		function onHighScoreComplete(e:Event):void {
			var receiver:URLLoader = URLLoader(e.target);
			var data:Object = decodeData(receiver.data);
			if (data != null) {
				highScore = data as Number;
				trace('loaded highScore of', highScore);
				dispatchProgress(1);
			}
				
			var loader2:URLLoader = rpc('GetFriends', null);
			loader2.addEventListener(Event.COMPLETE, onFriendsComplete);
		}
		
		function onFriendsComplete(e:Event):void {
			var receiver:URLLoader = URLLoader(e.target);
			var data:Object = decodeData(receiver.data);
			if (data) {
				friendsToLoad = data as Array;
				amountTotal = friendsToLoad.length;
				dispatchProgress(2);
				
				// Multiple download threads, effectively.
				loadNextFriend();
				loadNextFriend();
			} else {
				rpcError();
			}
		}
		
		function rpcError():void {
			dispatchEvent(new SocialNetworkEvent(SocialNetworkEvent.ERROR, null,
				"Unable to connect to Facebook"));
		}
	}
	
	private function dispatchProgress(loaded:int, total:int = 100):void {
		dispatchEvent(new SocialNetworkEvent(SocialNetworkEvent.PROGRESS, null, null, 
				loaded, total));
	}
	
	private function incrementAndLoadNextFriend():void {
		amountLoaded++;
		if (amountLoaded == amountTotal) {
			dispatchEvent(new SocialNetworkEvent(Event.COMPLETE));
		} else {
			dispatchProgress(amountLoaded, amountTotal);
			loadNextFriend();
		}
	}
	
	private function loadNextFriend():void {
		if (friendsToLoad.length > 0) {
			var info:Object = friendsToLoad.pop();
			if (info.imageUrl) {
				var makeFriend:Function = function(e:Event):void {
					var bitmap:Bitmap = Bitmap(e.target.content);
					var friend:Friend = new Friend(info.uid, info.name, info.highScore,
							bitmap, info.sex, info.profileUrl);
					
					if (info.hasAddedApp) {
						bossFriends.push(friend);
						trace('added', friend, 'to bossFriends');
					} else {
						rescuableFriends.push(friend);
						trace('added', friend, 'to rescuableFriends');
					}
					
					incrementAndLoadNextFriend();
				};
				
				var loader:Loader = new Loader();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, makeFriend)
				var context:LoaderContext = new LoaderContext()
				context.checkPolicyFile = true;
				loader.load(new URLRequest(info.imageUrl), context);
				trace('fetching', info.imageUrl);
			} else {
				trace('no imageURL for uid', info.uid, 'named', info.name);
				incrementAndLoadNextFriend();
			}
		}
	}
	
	override public function getBossFriend():Friend {
		if (bossFriends.length == 0) {
			trace('No boss friends available');
			return null;
		}
		var index:int = Math.random() * bossFriends.length;
		return bossFriends[index];
	}
	
	override public function getRescuableFriend():Friend {
		if (rescuableFriends.length == 0) {
			trace('No rescuable friends available');
			return null;
		}
		var index:int = Math.random() * rescuableFriends.length;
		return rescuableFriends[index];
	}
	
	override public function getTopFriends():Array {
		var result:Array = new Array();
		function addToResult(obj:Object, index:int, array:Array):void {
			result.push(obj);
		}
		bossFriends.forEach(addToResult);
		rescuableFriends.forEach(addToResult);
		result.sortOn('highScore', Array.NUMERIC | Array.DESCENDING);
		return result;
	}
	
	override public function recordFriendAsRescued(friend:Friend):void {
		rpc('RecordFriendAsRescued', {uid: friend.uid});
	}
	
	override public function recordFriendAsDestroyed(friend:Friend):void {
		rpc('RecordFriendAsDestroyed', {uid: friend.uid});
	}
	
	override public function recordFriendAsDefeated(friend:Friend):void {
		rpc('RecordFriendAsDefeated', {uid: friend.uid});
	}
	
	override public function recordGameBegin():void {
		gameStartTime = getTimer();
		rpc('RecordGameBegin', {});
	}
	
	override public function recordGameEnd(level:int, score:int):void {
		if (score > highScore) {
			highScore = score;
		}
		
		var data:Object = {level: level,
				score: score,
				duration: getTimer() - gameStartTime};
		rpc('RecordGameEnd', data);
	}
	
	override protected function rpc(method:String, data:Object):URLLoader {
		if (data == null) {
			data = new Object();
		}
		data.session_key = getSessionKey();
		return super.rpc(method, data);
	}
	
	private function getSessionKey():String {
		return root.loaderInfo.parameters.fb_sig_session_key;
	}

}

}