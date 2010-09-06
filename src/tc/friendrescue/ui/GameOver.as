// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.ui {
	
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.utils.Timer;

import tc.common.ui.CommonTextField;
import tc.friendrescue.controllers.FontController;

public class GameOver extends Sprite {
	
	private var blinker:Timer;
	
	public function GameOver(parent:Sprite) {
		super();
		parent.addChild(this);
		
		var title:CommonTextField = new CommonTextField();
		title.format.font = FontController.MENU_FONT;
		title.format.size = 48;
		title.format.color = 0x00cc00;
		title.setText('Game Over');
		title.centerAlign(parent.stage.stageWidth);
		title.y = parent.stage.stageHeight / 2 - title.textHeight / 2 * 3; 
		title.stroke();
		addChild(title);
		
		var instructions:CommonTextField = new CommonTextField();
		instructions.format = title.format;
		instructions.format.size = 24;
		instructions.setText('Click to continue');
		instructions.centerAlign(parent.stage.stageWidth);
		instructions.y = title.y + title.textHeight * 1.5;
		instructions.stroke();
		addChild(instructions);
		
		blinker = new Timer(600);
		blinker.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
			alpha = alpha ? 0 : 1;
		});
		blinker.start();
	}
	
	public function destroy():void {
		blinker.stop();
		if (parent != null) {
			parent.removeChild(this);
		} else {
			trace('parent was null for', this);
		}
	}
	
}

}