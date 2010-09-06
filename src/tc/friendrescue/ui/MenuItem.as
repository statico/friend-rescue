// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.ui {
	
import flash.events.Event;

import tc.common.ui.CommonTextField;
import tc.friendrescue.controllers.FontController;
import tc.friendrescue.controllers.SoundController;
	
public class MenuItem extends CommonTextField {
	
	public static const CHOOSE:String = 'menuItemHasBeenChosen';
	
	public static const inactiveColor:int = 0x00ffff;
	public static const activeColor:int = 0xffff00;
	
	public var menuIndex:int;
	public var highlighted:Boolean;
	
	protected var itemText:String;
			   
	public function MenuItem(itemText:String) {
		super();
		this.itemText = itemText;
		
		format.font = FontController.MENU_FONT;
		format.size = 24;
		format.color = inactiveColor;
		setText(itemText);
		stroke();
		
		addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void {
			x = 0;
			centerAlign(parent.stage.stageWidth);
		});
	}
	
	public function highlight():void {
		SoundController.playSmallClick();
		highlighted = true;
		setColor(activeColor);
	}
	
	public function unhighlight():void {
		highlighted = false;
		// setColor(inactiveColor);
	}
	
	public function choose():void {
		dispatchEvent(new Event(CHOOSE));
		SoundController.playBigClick();
	}

}

}