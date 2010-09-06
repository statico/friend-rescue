// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.social {

import flash.display.Bitmap;
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.utils.getTimer;

public class FakeSocialNetwork extends AbstractSocialNetwork {
	
	[Embed(source='../../../../graphics/fake_profile_pic.jpg')]
	private static const FakeProfilePicJPG:Class;
	private static const bitmap:Bitmap = new FakeProfilePicJPG() as Bitmap;
	
	private var highScore:int;
	
	public function FakeSocialNetwork(development:Boolean, target:IEventDispatcher=null) {
		super(development, '/null/', target);
	}
	
	private function makeFakeFriend(name:String, score:int = 0):Friend {
		return new Friend(0, name, score, bitmap,
				Math.random() * 2 > 1 ? Friend.MALE : Friend.FEMALE);
	}
	
	override public function getNetworkName():String {
		return "a fake social network";
	}
	
	override public function loadFriendInfo():void {
		dispatchEvent(new SocialNetworkEvent(Event.COMPLETE));
	}
	
	override public function getBossFriend():Friend {
		return makeFakeFriend('Bossie', Math.random() * 5000);
	}
	
	override public function getRescuableFriend():Friend {
		return makeFakeFriend('Fakey');
	}
	
	override public function getTopFriends():Array {
		return [getBossFriend(), getRescuableFriend(), getRescuableFriend()];
	}
	
	override public function recordFriendAsRescued(friend:Friend):void {
		trace('Fake: recordFriendAsRescued(' + friend + ')');
	}
	
	override public function recordFriendAsDestroyed(friend:Friend):void {
		trace('Fake: recordFriendAsDestroyed(' + friend + ')');
	}
	
	override public function recordFriendAsDefeated(friend:Friend):void {
		trace('Fake: recordFriendAsDefeated(' + friend + ')');
	}
	
	override public function recordGameBegin():void {
		trace('Fake: recordGameBegin()');
		gameStartTime = getTimer();
	}
	
	override public function recordGameEnd(level:int, score:int):void {
		if (score > highScore) {
			highScore = score;
		}
		
		var duration:int = getTimer() - gameStartTime;
		trace('Fake: recordGameEnd(' + level + ', ' + score + ')');
	}
	
	override public function getHighScore():int {
		return highScore;
	}
	
	
}

}