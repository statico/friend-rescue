// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.explosions {
	
import flash.display.Bitmap;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;

import tc.common.application.IUpdatable;
import tc.common.util.MathUtil;

internal class RockDebris extends AbstractDebris implements IUpdatable {
	
	[Embed(source='../../../../../graphics/debris1.png')]
	private static const DebrisOnePNG:Class;
	private static const debris1:Bitmap = new DebrisOnePNG() as Bitmap;
	
	[Embed(source='../../../../../graphics/debris2.png')]
	private static const DebrisTwoPNG:Class;
	private static const debris2:Bitmap = new DebrisTwoPNG() as Bitmap;
	
	[Embed(source='../../../../../graphics/debris3.png')]
	private static const DebrisThreePNG:Class;
	private static const debris3:Bitmap = new DebrisThreePNG() as Bitmap;
	
	private static const BASE_SPEED:Number = 60 / 1000;
	private static const OFFSET:int = 10;
	
	public function RockDebris(x:int, y:int, bounds:Rectangle, tint:ColorTransform) {
		var bitmap:Bitmap;
		switch (Math.floor(Math.random() * 3)) {
			case 0: bitmap = debris1; break;
			case 1: bitmap = debris2; break;
			case 2: bitmap = debris3; break;
		}
		
		var rate:int = 750 + (250 - Math.random() * 500);
		super(bitmap, 24, 25, 6, rate, bounds, tint);
		
		this.x = x + Math.floor(Math.random() * OFFSET - OFFSET / 2);
		this.y = y + Math.floor(Math.random() * OFFSET - OFFSET / 2);
		
		var angle:Number = MathUtil.angle(x, y, this.x, this.y);
		vx = MathUtil.fakeCos(angle) * BASE_SPEED * Math.random();
		vy = MathUtil.fakeSin(angle) * BASE_SPEED * Math.random();
		
		lifeLeft = 6000 + Math.random() * 1000;
	}
	    
}

}
