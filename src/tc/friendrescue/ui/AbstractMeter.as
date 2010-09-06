// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.ui {
	
import flash.filters.BevelFilter;
import flash.filters.GlowFilter;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;

import tc.common.ui.CommonTextField;
import tc.friendrescue.controllers.FontController;

public class AbstractMeter extends CommonTextField {
	
	public function AbstractMeter() {
		super();
		
		format.font = FontController.SCORE_FONT;
		format.size = FontController.SCORE_SIZE;
		format.color = 0xFFDD00;
		format.align = TextFormatAlign.CENTER;
		autoSize = TextFieldAutoSize.NONE;
		
		filters = [
				new BevelFilter(1, 45, 0xFFDAA0, 1, 0x897C11, 1, 0, 0, 100, 0),
				new GlowFilter(0x000000, 1, 3, 3, 100),
				];
	}
	
}

}