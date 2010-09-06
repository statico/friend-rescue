// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.explosions {
	
import flash.display.Bitmap;

import tc.common.application.IUpdatable;

internal class MediumExplosion extends AbstractExplosion implements IUpdatable {
	
	[Embed(source='../../../../../graphics/medium_explosion.png')]
	private static const SmallExplosionPNG:Class;
	private static const explosion:Bitmap = new SmallExplosionPNG() as Bitmap;
	
	public function MediumExplosion(x:int = 0, y:int = 0) {
		super(explosion, 48, 48, 7, 400);
		this.x = x;
		this.y = y;
	}
	    
}

}
