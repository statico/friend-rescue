// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.enemies {
	
import flash.display.Bitmap;
import flash.geom.Rectangle;

import tc.common.util.TintUtil;
import tc.friendrescue.watchers.AbstractGuidanceSystem;

public class MitosisEnemyChild extends AbstractEnemy {
	
	[Embed(source='../../../../../graphics/mitosis_child.png')]
	private static const MitosisChildPNG:Class;
	private static const mitosisChild:Bitmap = new MitosisChildPNG() as Bitmap;
	
	private static const ACTIVATION_DELAY:int = 200;
	
	private var activationTimeLeft:int;
	
	public function MitosisEnemyChild(bounds:Rectangle,
			guidanceSystem:AbstractGuidanceSystem, vx:Number = 0, vy:Number = 0) {
		super(mitosisChild, 21, 21, 3, 75, bounds, guidanceSystem);
		
		maxSpeed = (125 + Math.random() * 50) / 1000;
		this.vx = vx * maxSpeed;
		this.vy = vy * maxSpeed;
		size = SIZE_SMALL;
		
		points = 5;
		acceleration = 0;
		useHitTest = true;
		tint = TintUtil.GREEN;
		madeOfLiquid = true;
		
		activationTimeLeft = ACTIVATION_DELAY;
	}
	
	override public function update(deltaTime:int):void {
		if (activationTimeLeft >= 0) {
			activationTimeLeft -= deltaTime;
			if (activationTimeLeft < 0) {
				acceleration = 0.01 + Math.random() * 0.01;
			}
		}
		super.update(deltaTime);
	}

}

}