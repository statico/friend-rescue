// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.ui {
	
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormatAlign;
import flash.utils.Timer;

import tc.common.application.ISpriteRegistry;
import tc.common.ui.CommonTextField;
import tc.friendrescue.controllers.FontController;
import tc.friendrescue.controllers.SoundController;

public class DataPanel extends Sprite {
	
	private static const COLOR:int = 0x00ff00;
	private static const TINT:ColorTransform = new ColorTransform(0, 1, 0);
	
	private var app:ISpriteRegistry;
	private var bounds:Rectangle;
	private var field:CommonTextField;
	private var blinker:Timer;
	private var bitmap:Bitmap;
	
	public function DataPanel(app:ISpriteRegistry, bounds:Rectangle = null) {
		super();
		this.app = app;
		
		if (bounds != null) {
			this.bounds = bounds;
		} else {	
			this.bounds = new Rectangle(140, 457, 187, 35);
		}
		
		field = new CommonTextField();
		field.format.font = FontController.CONSOLE_FONT;
		field.format.size = FontController.CONSOLE_SIZE;
		field.format.color = COLOR;
		field.format.kerning = true;
		addChild(field);
		
		app.getParent().addChild(this);
	}
	
	public function setText(text:String, blink:Boolean = true,
			originalBitmap:Bitmap = null):void {
		if (this.bitmap) {
			removeChild(this.bitmap);
			this.bitmap = null;
		}
		
		// Remember to call setText() before using textHeight.
		if (originalBitmap) {
			var bitmap:Bitmap = new Bitmap(originalBitmap.bitmapData.clone());
			
			field.autoSize = TextFieldAutoSize.LEFT;
			field.format.align = TextFormatAlign.LEFT;
			
			field.setText(text + "\n");
			
			addChild(bitmap);
			var scale:Number = bounds.height / bitmap.height;
			bitmap.scaleX = scale;
			bitmap.scaleY = scale;
			var bd:BitmapData = bitmap.bitmapData;
			// XXX bd.colorTransform(new Rectangle(0, 0, bd.width, bd.height), TINT);
			this.bitmap = bitmap;
			
			var totalWidth:int = field.textWidth + bitmap.width + 8;
			bitmap.x = bounds.x + (bounds.width / 2) - (totalWidth / 2);
			bitmap.y = bounds.y;
			field.x = bitmap.x + bitmap.width + 8;
			field.y = bounds.y + (bounds.height * 0.5) - (field.textHeight * 0.6)
		} else {
			// For some reason, any dicking with this causes this field to not draw properly.
			field.autoSize = TextFieldAutoSize.CENTER;
			field.format.align = TextFormatAlign.CENTER;
			field.width = bounds.width;
			
			field.setText(text + "\n");
			
			field.x = bounds.x + (bounds.width * 0.5) - (field.textWidth * 0.5);
			field.y = bounds.y + (bounds.height * 0.5) - (field.textHeight * 0.6);
		}
		
		if (blink) {
			var duration:int = 1000;
			var count:int = 3;
			
			if (blinker) blinker.stop();
			visible = false;
			blinker = new Timer(duration / (count * 2), (count * 2) - 1);
			blinker.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
				visible = !visible;
				if (visible) SoundController.playSnapHi();
			});
			blinker.start();
		}
	}
	
	public function destroy():void {
		if (parent != null) {
			parent.removeChild(this);
		}
	}
	
}

}