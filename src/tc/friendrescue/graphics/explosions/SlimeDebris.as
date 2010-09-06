// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.explosions {
	
import flash.display.Bitmap;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;

import tc.common.application.IUpdatable;
import tc.common.util.MathUtil;

internal class SlimeDebris extends AbstractDebris implements IUpdatable {
	
	[Embed(source='../../../../../graphics/slime1.png')]
	private static const SlimeOnePNG:Class;
	private static const slime1:Bitmap = new SlimeOnePNG() as Bitmap;
	
	[Embed(source='../../../../../graphics/slime2.png')]
	private static const SlimeTwoPNG:Class;
	private static const slime2:Bitmap = new SlimeTwoPNG() as Bitmap;
	
	private static const BASE_SPEED:Number = 50 / 1000;
	private static const OFFSET:int = 10;
	
	public function SlimeDebris(x:int, y:int, bounds:Rectangle, tint:ColorTransform) {
		var bitmap:Bitmap;
		switch (Math.floor(Math.random() * 2)) {
			case 0: bitmap = slime1; break;
			case 1: bitmap = slime2; break;
		}
		
		super(bitmap, 7, 7, 1, 0, bounds, tint);
		
		this.x = x + Math.floor(Math.random() * OFFSET - OFFSET / 2);
		this.y = y + Math.floor(Math.random() * OFFSET - OFFSET / 2);
		
		var angle:Number = MathUtil.angle(x, y, this.x, this.y);
		vx = MathUtil.fakeCos(angle) * BASE_SPEED * Math.random();
		vy = MathUtil.fakeSin(angle) * BASE_SPEED * Math.random();
		
		lifeLeft = 3000 + Math.random() * 1000;
	}
	    
}

}
