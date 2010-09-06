// Copyright (c) 2010 Ian Langworth

package tc.common.util {
	
/**
 * Math utility functions. 
 * 
 * Sine/cosing approximation from:
 * http://lab.polygonal.de/2007/07/18/fast-and-accurate-sinecosine-approximation/
 */
public class MathUtil {
	
	public static function degreesToRadians(degrees:Number):Number {
		return degrees * Math.PI / 180;
	}
	
	public static function radiansToDegrees(radians:Number):Number {
		return radians * 180 / Math.PI;
	}
	
	public static function distance(x1:Number, y1:Number, x2:Number, y2:Number):Number {
		return Math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2));
	}
	
	public static function angle(x1:Number, y1:Number, x2:Number, y2:Number):Number {
		return Math.atan2(y2 - y1, x2 - x1);
	}
	
	public static function fakeSin(x:Number):Number {
		if (x < -3.14159265)
	    x += 6.28318531;
		else if (x >  3.14159265)
	    x -= 6.28318531;
	    
		if (x < 0)
    	return 1.27323954 * x + .405284735 * x * x;
		else
    	return 1.27323954 * x - 0.405284735 * x * x;
	}
	
	public static function fakeCos(x:Number):Number {
		x += 1.57079632;
		if (x >  3.14159265)
	    x -= 6.28318531;
	    
		if (x < 0)
    	return 1.27323954 * x + 0.405284735 * x * x
		else
    	return 1.27323954 * x - 0.405284735 * x * x;
	}
}

}