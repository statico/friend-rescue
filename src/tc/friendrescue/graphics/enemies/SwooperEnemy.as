// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.enemies {
	
import flash.display.Bitmap;
import flash.geom.Rectangle;

import tc.common.util.MathUtil;
import tc.common.util.TintUtil;
import tc.friendrescue.watchers.AbstractGuidanceSystem;

public class SwooperEnemy extends AbstractEnemy {
	
	[Embed(source='../../../../../graphics/swooper.png')]
	private static const SwooperPNG:Class;
	private static const swooper:Bitmap = new SwooperPNG() as Bitmap;
	
	private static const BASE_SWOOP_SPEED:Number = 0.4;
	private static const BASE_ORBIT_DIAMETER:int = 40;
	private static const VARIANCE:Number = 0.50;
	
	private var swoopDirection:int;
	private var swoopSpeed:Number;
	private var orbitDiameter:int;
	private var oldX:int;
	private var oldY:int;
	
	public function SwooperEnemy(initialX:int, initialY:int, bounds:Rectangle,
			guidanceSystem:AbstractGuidanceSystem) {
		super(swooper, 23, 23, 0, 0, bounds, guidanceSystem);
		
		points = 20;
		maxSpeed = (60 + Math.random() * 10) / 800;
		acceleration = 0.004 + Math.random() * 0.006;
		tint = TintUtil.RED;
		useHitTest = true;
		
		oldX = initialX;
		oldY = initialY;
		swoopDirection = 360 * Math.random();
		
		// Pick a slightly random ratio of speed/radius. (The smaller the diameter,
		// the faster the swoop speed.)
		var multiplier:Number = Math.random();
		swoopSpeed = BASE_SWOOP_SPEED + (multiplier * BASE_SWOOP_SPEED * -VARIANCE)
				- (BASE_SWOOP_SPEED * -VARIANCE / 2);
		orbitDiameter = BASE_ORBIT_DIAMETER + (multiplier * BASE_ORBIT_DIAMETER * VARIANCE)
				- (BASE_ORBIT_DIAMETER * VARIANCE / 2);
		
		// This bitmap is a directional sprite sheet and we need to pick one frame.
		drawStep(2);
	}
	
	override protected function setDirection(directionRadians:Number):void {
		rotation = swoopDirection;
	}
	
	override public function update(deltaTime:int):void {
		// Restore our original x and y.
		x = oldX;
		y = oldY;
		
		// Let AbstractEnemy calculate where our center of orbit is.
		super.update(deltaTime);
		
		// Save that x and y.
		oldX = x;
		oldY = y;
		
		// Modify the real x and y based on swoopDirection.
		swoopDirection = (swoopDirection + deltaTime * swoopSpeed) % 360;
		var swoopRadians:Number = MathUtil.degreesToRadians(swoopDirection);
		x += MathUtil.fakeCos(swoopRadians) * orbitDiameter;
		y += MathUtil.fakeSin(swoopRadians) * orbitDiameter;
	}
	
}

}