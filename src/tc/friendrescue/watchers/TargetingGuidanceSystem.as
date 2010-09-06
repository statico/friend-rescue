// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.watchers {
	
import flash.display.DisplayObject;
import flash.display.Sprite;

import tc.friendrescue.graphics.bullets.BulletFactory;

public class TargetingGuidanceSystem extends AbstractGuidanceSystem {
	
	private var toggleable:IToggleable;
	private var bulletFactory:BulletFactory; // TODO - Probably too tightly-coupled.
		
	public function TargetingGuidanceSystem(target:Sprite, toggleable:IToggleable,
			bulletFactory:BulletFactory) {
		super(target);
		this.toggleable = toggleable;
		this.bulletFactory = bulletFactory;
	}
	
	override public function getMode():Number {
		return toggleable.isActive() ? MODE_CHASE : MODE_AVOID;
	}
	
	override public function applyAvoiders(func:Function):void {
		bulletFactory.applyToFriendlyBullets(function(obj:DisplayObject):void {
			func.call(this, obj);
		});
	}

}

}