// Copyright (c) 2010 Ian Langworth

package tc.common.preloader {
	
import flash.text.AntiAliasType;
import flash.text.GridFitType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;

public class TCTextField extends TextField {
	
	public static const FORMAT:TextFormat = new TextFormat('_sans', 12,
			0xffffff, false, false, false, null, null, TextFormatAlign.CENTER);
		
	public function TCTextField(x:int, y:int, text:String = '') {
		super();
		
		defaultTextFormat = FORMAT;
		antiAliasType = AntiAliasType.ADVANCED;
		autoSize = TextFieldAutoSize.CENTER;
		selectable = false;
		
		this.text = text;
		this.x = Math.floor(x - textWidth / 2);
		this.y = y;
	}
	
}

}