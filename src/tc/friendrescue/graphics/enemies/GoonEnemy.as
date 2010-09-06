// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.enemies {
	
import flash.display.Bitmap;
import flash.geom.Rectangle;

import tc.common.util.TintUtil;
import tc.friendrescue.watchers.AbstractGuidanceSystem;

public class GoonEnemy extends AbstractEnemy {
	
	[Embed(source='../../../../../graphics/goon.png')]
	private static const GoonPNG:Class;
	private static const goon:Bitmap = new GoonPNG() as Bitmap;
	
	public function GoonEnemy(bounds:Rectangle, guidanceSystem:AbstractGuidanceSystem) {
		super(goon, 25, 25, 3, 100, bounds, guidanceSystem);
		
		points = 10;
		maxSpeed = (45 + Math.random() * 10) / 800;
		acceleration = 0.004 + Math.random() * 0.006;
		tint = TintUtil.MAGENTA;
	}
	
	override protected function setDirection(directionRadians:Number):void {
		rotation = directionRadians * 180 / Math.PI - 90;
	}
	
}

}