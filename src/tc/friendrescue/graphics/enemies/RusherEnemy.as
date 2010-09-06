// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.enemies {
	
import flash.display.Bitmap;
import flash.geom.Rectangle;

import tc.common.util.MathUtil;
import tc.common.util.TintUtil;
import tc.friendrescue.watchers.AbstractGuidanceSystem;
import tc.friendrescue.watchers.RusherGuidanceSystem;

public class RusherEnemy extends AbstractEnemy {
	
	[Embed(source='../../../../../graphics/rusher.png')]
	private static const RusherPNG:Class;
	private static const rusher:Bitmap = new RusherPNG() as Bitmap;
	
	private static const RUSH_TIME:int = 3000;
	
	private var rusherGuidanceSystem:AbstractGuidanceSystem;
	
	public function RusherEnemy(initialX:int, initialY:int, bounds:Rectangle,
			realGuidanceSystem:AbstractGuidanceSystem) {
		rusherGuidanceSystem = new RusherGuidanceSystem(realGuidanceSystem,
				initialX, initialY, RUSH_TIME);
		super(rusher, 23, 23, 0, 0, bounds, rusherGuidanceSystem);
		
		points = 15;
		maxSpeed = 250 / 1000;
		acceleration = 0.1 + Math.random() * 0.01;
		tint = TintUtil.ORANGE;
		
		// This bitmap is a directional sprite sheet and we need to pick one frame.
		drawStep(6);
	}
	
	override protected function setDirection(directionRadians:Number):void {
		rotation = directionRadians * 180 / Math.PI - 90;
	}
	
	override public function destroy():void {
		rusherGuidanceSystem.destroy();
		super.destroy();
	}
	
}

}