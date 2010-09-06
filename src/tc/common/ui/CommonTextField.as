// Copyright (c) 2010 Ian Langworth

package tc.common.ui {
	
import flash.events.TimerEvent;
import flash.filters.GlowFilter;
import flash.text.AntiAliasType;
import flash.text.GridFitType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flash.utils.Timer;

public class CommonTextField extends TextField {
	
	public var format:TextFormat;
	private var blinker:Timer;
	
	public function CommonTextField() {
		super();
		
		antiAliasType = AntiAliasType.NORMAL;
		embedFonts = true;
		selectable = false;
		autoSize = TextFieldAutoSize.LEFT;
		gridFitType = GridFitType.PIXEL;
		
		format = new TextFormat();
		format.align = TextFormatAlign.LEFT;
	}
	
	public function setText(text:String):void {
		defaultTextFormat = format;
		this.text	= text;
	}
	
	public function setColor(color:int):void {
		format.color = color;
		setText(text);
	}
	
	public function centerAlign(width:int):void {
		var oldText:String = text;
		text = 'M';
		x = (width * 0.5) - (textWidth * 0.5);
		autoSize = TextFieldAutoSize.CENTER;
		format.align = TextFormatAlign.CENTER;
		setText(oldText);
	}
	
	public function leftAlign(leftEdge:int):void {
		x = leftEdge;
		autoSize = TextFieldAutoSize.LEFT;
		format.align = TextFormatAlign.LEFT;
		setText(text);
	}
	
	public function rightAlign(rightEdge:int):void {
		x = rightEdge;
		autoSize = TextFieldAutoSize.RIGHT;
		format.align = TextFormatAlign.RIGHT;
		setText(text);
	}
	
	public function stroke(color:int = 0x000000, width:int = 6):void {
		filters = [new GlowFilter(color, 1, width, width, 40)];
	}
	
	public function blink(duration:int = 1200, count:int = 3):void {
		if (blinker) blinker.stop();
		visible = false;
		blinker = new Timer(duration / (count * 2), (count * 2) - 1);
		blinker.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
			visible = !visible;
		});
		blinker.start();
	}
	
}

}