// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.explosions {
	
import flash.display.Bitmap;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;

import tc.common.application.IUpdatable;
import tc.common.util.MathUtil;

internal class SparkleDebris extends AbstractDebris implements IUpdatable {
	
	[Embed(source='../../../../../graphics/sparkle1.png')]
	private static const SparkleOnePNG:Class;
	private static const sparkle1:Bitmap = new SparkleOnePNG() as Bitmap;
	
	[Embed(source='../../../../../graphics/sparkle2.png')]
	private static const SparkleTwoPNG:Class;
	private static const sparkle2:Bitmap = new SparkleTwoPNG() as Bitmap;
	
	[Embed(source='../../../../../graphics/sparkle3.png')]
	private static const SparkleThreePNG:Class;
	private static const sparkle3:Bitmap = new SparkleThreePNG() as Bitmap;
	
	private static const BASE_SPEED:Number = 25 / 1000;
	private static const OFFSET:int = 10;
	
	public function SparkleDebris(x:int, y:int, bounds:Rectangle, tint:ColorTransform) {
		var bitmap:Bitmap;
		switch (Math.floor(Math.random() * 3)) {
			case 0: bitmap = sparkle1; break;
			case 1: bitmap = sparkle2; break;
			case 2: bitmap = sparkle3; break;
		}
		
		var rate:int = 300 + (50 - Math.random() * 100);
		super(bitmap, 11, 11, 3, rate, bounds, tint);
		
		this.x = x + Math.floor(Math.random() * OFFSET - OFFSET / 2);
		this.y = y + Math.floor(Math.random() * OFFSET - OFFSET / 2);
		
		var angle:Number = MathUtil.angle(x, y, this.x, this.y);
		vx = MathUtil.fakeCos(angle) * BASE_SPEED * Math.random();
		vy = MathUtil.fakeSin(angle) * BASE_SPEED * Math.random();
		
		lifeLeft = 8000 + Math.random() * 1000;
	}
	    
}

}
