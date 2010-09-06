// Copyright (c) 2010 Ian Langworth

package tc.common.util {
	
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
	
public class TintUtil {
	
	public static const RED:ColorTransform = new ColorTransform(1, 0, 0);
	public static const GREEN:ColorTransform = new ColorTransform(0, 1, 0);
	public static const BLUE:ColorTransform = new ColorTransform(0, 0, 1);
	public static const CYAN:ColorTransform = new ColorTransform(0, 1, 1);
	public static const MAGENTA:ColorTransform = new ColorTransform(1, .25, .65);
	public static const YELLOW:ColorTransform = new ColorTransform(1, 1, 0);
	public static const ORANGE:ColorTransform = new ColorTransform(1, .50, 0);
	
	public static const ALL:Array = [RED, GREEN, BLUE, CYAN, MAGENTA, YELLOW,
																	 ORANGE];
	
	public static function tintBitmap(input:Bitmap, value:ColorTransform):Bitmap {
		return new Bitmap(tintBitmapData(input.bitmapData, value));
	}
	
	public static function tintBitmapData(input:BitmapData,
			value:ColorTransform):BitmapData {
		var output:BitmapData = input.clone();
		output.colorTransform(new Rectangle(0, 0, input.width, input.height), value);
		return output;
	}
	
	public static function randomTint():ColorTransform {
		return ALL[Math.floor(Math.random() * ALL.length)];
	}
	
}

}