// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.explosions {
	
import flash.display.Bitmap;

import tc.common.application.IUpdatable;

internal class SmallExplosion extends AbstractExplosion implements IUpdatable {
	
	[Embed(source='../../../../../graphics/small_explosion.png')]
	private static const SmallExplosionPNG:Class;
	private static const explosion:Bitmap = new SmallExplosionPNG() as Bitmap;
	
	public function SmallExplosion(x:int = 0, y:int = 0) {
		super(explosion, 24, 25, 7, 400);
		this.x = x;
		this.y = y;
	}
	    
}

}
