// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.explosions {
	
import flash.display.Bitmap;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;

import tc.common.application.IUpdatable;
import tc.common.util.MathUtil;

internal class FlareDebris extends AbstractDebris implements IUpdatable {
	
	[Embed(source='../../../../../graphics/flare.png')]
	private static const FlarePNG:Class;
	private static const flare:Bitmap = new FlarePNG() as Bitmap;
	
	private static const BASE_SPEED:Number = 400 / 1000;
	private static const OFFSET:int = 10;
	
	public function FlareDebris(x:int, y:int, bounds:Rectangle, tint:ColorTransform) {
		var rate:int = 100 + (50 - Math.random() * 100);
		super(flare, 11, 11, 3, rate, bounds, tint);
		
		this.x = x + Math.floor(Math.random() * OFFSET - OFFSET / 2);
		this.y = y + Math.floor(Math.random() * OFFSET - OFFSET / 2);
		
		var angle:Number = MathUtil.angle(x, y, this.x, this.y);
		vx = MathUtil.fakeCos(angle) * BASE_SPEED * Math.random();
		vy = MathUtil.fakeSin(angle) * BASE_SPEED * Math.random();
		
		lifeLeft = 500 + Math.random() * 500;
	}
	    
}

}
