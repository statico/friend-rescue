// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.bullets {
  
import flash.display.Bitmap;

import tc.common.util.TintUtil;

public class ShipBullet extends AbstractBullet {
  
	[Embed(source='../../../../../graphics/ship_bullet.png')]
	private static const BulletPNG:Class;
	private static const bullet:Bitmap = new BulletPNG() as Bitmap;
	
	public function ShipBullet(direction:Number) {
		super(bullet, 11, 11, direction);
		friendly = true;
		tint = TintUtil.CYAN;
	}
	
}

}