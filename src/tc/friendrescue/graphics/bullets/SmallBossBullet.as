// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.bullets {
  
import flash.display.Bitmap;

import tc.common.util.TintUtil;

public class SmallBossBullet extends AbstractBullet {
  
	[Embed(source='../../../../../graphics/small_boss_bullet.png')]
	private static const BulletPNG:Class;
	private static const bullet:Bitmap = new BulletPNG() as Bitmap;
	
	public function SmallBossBullet(direction:Number) {
		super(bullet, 11, 11, direction);
		friendly = false;
		speed *= .75;
		tint = TintUtil.GREEN;
	}
	
}
	
}