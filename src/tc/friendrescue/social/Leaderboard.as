// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.social {
	
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;

import tc.common.application.ISpriteRegistry;
import tc.common.application.IUpdatable;
import tc.common.ui.CommonTextField;
import tc.friendrescue.controllers.FontController;
import tc.friendrescue.controllers.SoundController;

public class Leaderboard extends Sprite implements IUpdatable {
	
	private static const BITMAP_WIDTH:int = 50;
	private static const POSITION_WIDTH:int = 100;
	
	private var app:ISpriteRegistry;
	private var socialNetwork:AbstractSocialNetwork;	
	private var startX:int;
	private var realWidth:int;
		
	
	public function Leaderboard(app:ISpriteRegistry, socialNetwork:AbstractSocialNetwork) {
		super();
		this.app = app;
		this.socialNetwork = socialNetwork;
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		app.getParent().addChild(this);
	}
	
	private function onAddedToStage(e:Event):void {
		removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		
		var friends:Array = socialNetwork.getTopFriends();
		if (friends == null || friends.length == 0) {
			trace('No top friends for leaderboard');
			return;
		}
		
		for (var i:int = 0, friend:Friend; friend = friends[i] as Friend; i++) {
			var start:int = i * POSITION_WIDTH;
			
			var copy:Bitmap = new Bitmap(friend.bitmap.bitmapData.clone());
			var scale:Number = BITMAP_WIDTH / copy.width;
			copy.scaleX = scale;
			copy.scaleY = scale;
			
			var image:Sprite = new Sprite();
			image.addChild(copy);
			image.x = start + ((POSITION_WIDTH / 2) - (BITMAP_WIDTH / 2));
			image.y = 0;
			addChild(image);
			
			var field:CommonTextField = new CommonTextField();
			field.format.font = FontController.CONSOLE_FONT;
			field.format.size = FontController.CONSOLE_SIZE;
			field.centerAlign(POSITION_WIDTH);
			
			if (friend.highScore > 0) {
				field.format.color = 0x00ffff;
				field.setText(friend.name + "\n" + friend.highScore);
			} else {
				field.format.color = 0xffff00;
				field.setText("Rescue\n" + friend.name + " !");
			}
			
			field.x = start + ((POSITION_WIDTH / 2) - (field.textWidth / 2));
			field.y = image.y + image.height + 7;;
			addChild(field);
			
			var navigateToProfile:Function = makeOnClickClosure(friend);
			image.addEventListener(MouseEvent.CLICK, navigateToProfile);
			field.addEventListener(MouseEvent.CLICK, navigateToProfile);
			
			if (i == 0) {
				startX = Math.min(image.x, field.x);
			}
		}
		
		filters = [new GlowFilter(0x000000)];
		x = 500;
		y = 500 * 0.66;
		realWidth = width + startX;
		
		app.subscribe(this);
	}
	
	public function makeOnClickClosure(friend:Friend):Function {
		return function(e:Event):void {
			SoundController.playBigClick();
			friend.navigateToProfile();
		};
	}
	
	public function update(deltaTime:int):void {
		x -= deltaTime * 0.05;
		if (x < -realWidth) {
			x = stage.width - startX;
		}
	}
	
	public function destroy():void {
		app.unsubscribe(this);
		if (parent != null) {
			parent.removeChild(this);
		}
	}
	
}

}