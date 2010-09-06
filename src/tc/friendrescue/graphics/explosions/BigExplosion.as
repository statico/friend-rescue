// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.explosions {
	
import flash.display.Bitmap;

import tc.common.application.IUpdatable;

internal class BigExplosion extends AbstractExplosion implements IUpdatable {
	
	[Embed(source='../../../../../graphics/big_explosion.png')]
	private static const BigExplosionPNG:Class;
	private static const explosion:Bitmap = new BigExplosionPNG() as Bitmap;
	
	public function BigExplosion(x:int = 0, y:int = 0) {
		super(explosion, 48, 48, 7, 600);
		this.x = x;
		this.y = y;
	}
	    
}

}
