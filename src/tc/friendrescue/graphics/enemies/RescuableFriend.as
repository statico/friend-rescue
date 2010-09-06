// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.enemies {
	
import flash.display.Bitmap;
import flash.events.Event;
import flash.geom.Rectangle;

import tc.common.util.TintUtil;
import tc.friendrescue.controllers.SoundController;
import tc.friendrescue.social.Friend;
import tc.friendrescue.watchers.AbstractGuidanceSystem;

public class RescuableFriend extends AbstractEnemy {
	
	[Embed(source='../../../../../graphics/rescuable_friend.png')]
	private static const rescuableFriendPNG:Class;
	private static const rescuableFriend:Bitmap = new rescuableFriendPNG() as Bitmap;
	
	public function RescuableFriend(friend:Friend, bounds:Rectangle,
			guidanceSystem:AbstractGuidanceSystem) {
		super(rescuableFriend, 16, 16, 4, 250, bounds, guidanceSystem);
		this.friend = friend;
		
		friendly = true;
		size = SIZE_TINY;
		points = 300;
		maxSpeed = (5 + Math.random() * 10) / 800;
		acceleration = 0.004 + Math.random() * 0.006;
		tint = TintUtil.YELLOW;
		
		this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		this.addEventListener(AbstractEnemy.DESTROYED, onDestroyed);
	}
	
	private function onAddedToStage(e:Event):void {
		//SoundController.playLastLife();
	}
	
	private function onDestroyed(e:Event):void {
		trace(friend, 'destroyed!!');
	}
	
	public function playScream():void {
		if (friend.sex == Friend.FEMALE) {
			SoundController.playRandomFemaleScream();
		} else {
			SoundController.playRandomMaleScream();
		}
	}
	
}

}