// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.explosions {
	
import flash.display.Bitmap;

import tc.common.application.IUpdatable;

internal class TinyExplosion extends AbstractExplosion implements IUpdatable {
	
	[Embed(source='../../../../../graphics/tiny_explosion.png')]
	private static const TinyExplosionPNG:Class;
	private static const explosion:Bitmap = new TinyExplosionPNG() as Bitmap;
	
	public function TinyExplosion(x:int = 0, y:int = 0) {
		super(explosion, 12, 13, 7, 600);
		this.x = x;
		this.y = y;
	}
	    
}

}
