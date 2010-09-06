// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.ui {
	
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

import tc.common.ui.CommonTextField;
import tc.friendrescue.controllers.FontController;
	
public class Menu extends Sprite {
	
	public var title:CommonTextField;
	
	private var items:Array;
	private var selectedIndex:int;
	
	public function Menu(parent:Sprite, menuTitle:String, ... items) {
		super();
		
		if (items == null) {
			throw new Error('items cannot be null');
		}
		if (items.length == 0) {
			throw new Error('items length cannot be zero');
		}
		this.items = items;
		
		// Create a text field for the title.
		title = new CommonTextField();
		title.format.font = FontController.TITLE_FONT;
		title.format.size = 48;
		title.format.color = 0x00ffff;
		title.setText(menuTitle);
		title.centerAlign(parent.stage.stageWidth);
		title.stroke();
		
		// Calculate the height of the entire menu with the title and all items.
		var first:MenuItem = items[1] as MenuItem;
		var fieldHeight:int = first.height;
		var nextY:int = (parent.stage.stageHeight * 0.5) -
				((fieldHeight * 2 * items.length + title.textHeight * 2) * 0.6);
				
		// Add the title.
		title.y = nextY;
		addChild(title);
		nextY += title.textHeight * 1.5;
		
		// Add each menu item.
		for (var i:int = 0; i < items.length; i++) {
			var item:MenuItem = items[i] as MenuItem;
			item.y = nextY;
			item.menuIndex = i;
			addChild(item);
			nextY += fieldHeight * 1.5;
			
			item.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void {
				(items[selectedIndex] as MenuItem).unhighlight();
				var item:MenuItem = e.target as MenuItem;
				selectedIndex = item.menuIndex;
				item.highlight();
			});
			item.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				(e.target as MenuItem).choose();
			});
		}
		
		resetActivation();
	}
	
	public function resetActivation():void {
		// Activate the first menu item.
		selectedIndex = 0;
		var first:MenuItem = items[0] as MenuItem;
		first.highlight();
	}
	
	public function attach(stage:Stage):void {
		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}
	
	public function detach(stage:Stage):void {
		stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}
	
	private function onKeyDown(e:KeyboardEvent):void {
		switch (e.keyCode) {
			
			case Keyboard.DOWN:
				(items[selectedIndex] as MenuItem).unhighlight();
				selectedIndex++;
				if (selectedIndex >= items.length) {
					selectedIndex = 0;
				}
				(items[selectedIndex] as MenuItem).highlight();
				break;
				
			case Keyboard.UP:
				(items[selectedIndex] as MenuItem).unhighlight();
				selectedIndex--;
				if (selectedIndex < 0) {
					selectedIndex = items.length - 1;
				}
				(items[selectedIndex] as MenuItem).highlight();
				break;
				
			case Keyboard.ENTER:
			case Keyboard.SPACE:
				(items[selectedIndex] as MenuItem).choose();
				break;
		}
	}

}

}