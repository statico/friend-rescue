// Copyright (c) 2010 Ian Langworth

package tc.common.util {
	
public class ColorUtil {
	
	/** 
	 * Converts HSV to RGB value. 
	 * 
	 * @param h Hue as a value between 0 - 360 degrees 
	 * @param s Saturation as a value between 0 - 100
	 * @param v Value as a value between 0 - 100
	 * @returns The color in decimal.
	 */  
	public static function HSBToRGB(h:Number, s:Number, v:Number):Number {
		if (v == 0) {
			return 0;
		}
		
		h %= 360;
		h /= 60;
		s /= 100;
		v /= 100;
		
		var i:Number = Math.floor(h);
		var f:Number = h - i;
		var p:Number = v * (1 - s);
		var q:Number = v * (1 - (s * f));
		var t:Number = v * (1 - (s * (1 - f)));
		
		var r:Number;
		var g:Number;
		var b:Number;
		
		switch (i) {
			case 0: r = v; g = t; b = p; break;
			case 1: r = q; g = v; b = p; break;
			case 2: r = p; g = v; b = t; break;
			case 3: r = p; g = q; b = t; break;
			case 4: r = t; g = p; b = v; break;
			case 5: r = v; g = p; b = q; break;
		}
		
		r = Math.floor(r * 255);
		g = Math.floor(g * 255);
		b = Math.floor(b * 255);
		
		return r + g * 256 + b * 256 * 256;
	}

}

}