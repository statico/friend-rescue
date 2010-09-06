// Copyright (c) 2010 Ian Langworth

package tc.common.util {
	
import flash.display.DisplayObject;
	
public class SpriteUtil {
		
	/**
	 * Returns the distance between the center of two Sprites.
	 * @param a The first sprite.
	 * @param b The other sprite.
	 * @return The distance.
	 */	
	public static function distance(a:DisplayObject, b:DisplayObject):Number {
		return MathUtil.distance(a.x, a.y, b.x, b.y);
	}
	
	/**
	 * Returns the angle from one sprite to another in radians.
	 * @param a The first sprite.
	 * @param b The other sprite.
	 * @return The angle in radians.
	 * 
	 */
	public static function angle(a:DisplayObject, b:DisplayObject):Number {
		return MathUtil.angle(a.x, a.y, b.x, b.y);
	}
	
}

}