// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.ui {

import flash.display.Sprite;
import flash.events.Event;

import tc.common.application.ISpriteRegistry;
import tc.common.ui.CommonTextField;
import tc.friendrescue.controllers.FontController;
import tc.friendrescue.social.AbstractSocialNetwork;
import tc.friendrescue.social.SocialNetworkEvent;

public class SocialNetworkLoader extends Sprite {
	
	private var app:ISpriteRegistry;
	private var socialNetwork:AbstractSocialNetwork;
	private var field:CommonTextField;
	
	public function SocialNetworkLoader(app:ISpriteRegistry, socialNetork:AbstractSocialNetwork) {
		super();
		this.app = app;
		this.socialNetwork = socialNetork;
		
		app.getParent().addChild(this);
	}
	
	public function load():void {
		drawBackground(0x3b5998);
		
		field = new CommonTextField();
		field.format.font = FontController.CONSOLE_FONT;
		field.format.size = FontController.CONSOLE_SIZE;
		field.format.color = 0xffffff;
		field.format.kerning = true;
		field.centerAlign(500);
		field.y = 175;
		field.setText('Connecting to ' + socialNetwork.getNetworkName() + '...' +
				"\n(it's a long way to Palo Alto)");
		addChild(field);
		
		socialNetwork.addEventListener(SocialNetworkEvent.PROGRESS, onProgress);
		socialNetwork.addEventListener(SocialNetworkEvent.ERROR, onError);
		socialNetwork.addEventListener(Event.COMPLETE, onComplete);
		socialNetwork.loadFriendInfo();
	}
	
	private function drawBackground(color:int):void {
		graphics.clear();
		graphics.beginFill(color);
		graphics.drawRoundRect(100, 150, 300, 75, 5, 5);
	}
	
	private function onProgress(e:SocialNetworkEvent):void {
		if (e.amountTotal != 0) {
			field.setText('Loading ' + socialNetwork.getNetworkName() + ' friends... ' +
				Math.round(e.amountLoaded / e.amountTotal * 100) + '%');
		} else {
			field.setText('Loading ' + socialNetwork.getNetworkName() + ' friends... ');
		}
	}
	
	private function onError(e:SocialNetworkEvent):void {
		drawBackground(0xcc0000);
		field.format.color = 0xffffff;
		field.setText('Error: ' + e.errorMessage +
				"\nPlease click the Reload button in your browser.");
	}
	
	private function onComplete(e:SocialNetworkEvent):void {
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	public function destroy():void {
		if (parent) parent.removeChild(this);
	}
	
}

}