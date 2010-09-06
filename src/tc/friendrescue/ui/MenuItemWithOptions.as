// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.ui {
	
public class MenuItemWithOptions extends MenuItem {
	
	private var selectedOptionIndex:int;
	private var options:Array;
	
	public function MenuItemWithOptions(itemText:String, options:Array=null, defaultOption:String=null) {
		super(itemText);
		this.options = options;
		
		// Store the options and select the first.
		if (options != null) {
			selectedOptionIndex = 0;
			if (defaultOption != null) {
				for (var i:int = 0; i < options.length; i++) {
					if (options[i] == defaultOption) {
						selectedOptionIndex = i;
						break;
					}
				}
			}
		}
		
		updateFieldText();
	}
	
	private function updateFieldText():void {
		setText(itemText + ' ' + getSelectedValue());
	}
	
	public function getSelectedValue():String {
		return options[selectedOptionIndex];
	}
	
	override public function choose():void {
		selectedOptionIndex++;
		if (selectedOptionIndex >= options.length) {
			selectedOptionIndex = 0;
		}
		updateFieldText();
		super.choose();
	}
}
	
}