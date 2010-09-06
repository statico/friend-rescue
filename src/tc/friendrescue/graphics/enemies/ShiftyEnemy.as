// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.enemies {
	
import flash.display.Bitmap;
import flash.geom.Rectangle;

import tc.common.util.TintUtil;
import tc.friendrescue.watchers.AbstractGuidanceSystem;

public class ShiftyEnemy extends AbstractEnemy {
	
	[Embed(source='../../../../../graphics/shifty.png')]
	private static const ShiftyPNG:Class;
	private static const shifty:Bitmap = new ShiftyPNG() as Bitmap;
	
	public function ShiftyEnemy(bounds:Rectangle, guidanceSystem:AbstractGuidanceSystem) {
		super(shifty, 25, 25, 3, 100, bounds, guidanceSystem);
		
		points = 15;
		maxSpeed = (100 + Math.random() * 40) / 1000;
		acceleration = 0.01 + Math.random() * 0.02;
		avoidsBullets = true;
		tint = TintUtil.YELLOW;
	}
	
	override protected function setDirection(directionRadians:Number):void {
		rotation = directionRadians * 180 / Math.PI + 180;
	}
	
}

}