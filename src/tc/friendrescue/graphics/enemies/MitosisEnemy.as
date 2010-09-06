// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.enemies {
	
import flash.display.Bitmap;
import flash.geom.Rectangle;

import tc.common.util.TintUtil;
import tc.friendrescue.watchers.AbstractGuidanceSystem;

public class MitosisEnemy extends AbstractEnemy {
	
	[Embed(source='../../../../../graphics/mitosis.png')]
	private static const MitosisPNG:Class;
	private static const mitosis:Bitmap = new MitosisPNG() as Bitmap;
	
	public function MitosisEnemy(bounds:Rectangle, guidanceSystem:AbstractGuidanceSystem) {
		super(mitosis, 25, 25, 4, 400, bounds, guidanceSystem);
		
		points = 10;
		maxSpeed = 90 / 1000;
		acceleration = 0.01;
		tint = TintUtil.GREEN;
		madeOfLiquid = true;
	}
	
}

}