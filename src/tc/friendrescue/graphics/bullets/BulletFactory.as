// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.bullets {
  
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.utils.Dictionary;

import tc.common.application.ISpriteRegistry;
import tc.common.application.IUpdatable;
import tc.friendrescue.controllers.SoundController;

public class BulletFactory {
  
	public static const TYPE_SHIP:int = 0;
	public static const TYPE_SMALL_BOSS:int = 1;
	
  private var friendlyBullets:Dictionary;
  private var unfriendlyBullets:Dictionary;
  private var app:ISpriteRegistry;
  
	public function BulletFactory(app:ISpriteRegistry) {
		this.app = app;
		friendlyBullets = new Dictionary();
		unfriendlyBullets = new Dictionary();
	}
	    
	public function addBullet(type:int, x:Number, y:Number, direction:Number):void {
		var bullet:AbstractBullet;
		switch (type) {
			case TYPE_SHIP:
				SoundController.playBullet();
				bullet = new ShipBullet(direction);
				break;
			case TYPE_SMALL_BOSS:
				SoundController.playPhoton();
				bullet = new SmallBossBullet(direction);
				break;
			default:
				throw new Error('Invalid bullet type: ' + type);
		} 
		bullet.x = x;
		bullet.y = y;
		
		app.subscribe(bullet);
		app.getParent().addChild(bullet);
		if (bullet.friendly) {
			friendlyBullets[bullet] = true;
		} else {
			unfriendlyBullets[bullet] = true;
		}
		bullet.addEventListener(AbstractBullet.DESTROYED, onDestroyed);
	}
	
	private function onDestroyed(e:Event):void {
		delete friendlyBullets[e.target];
		delete unfriendlyBullets[e.target];
		app.unsubscribe(e.target as IUpdatable);
		try {
		 	app.getParent().removeChild(e.target as AbstractBullet);	
		} catch (e:ArgumentError) {
			// This event might fire twice in one frame.
		}
	}
	
	public function applyToFriendlyBullets(func:Function):void {
		for (var obj:Object in friendlyBullets) {
			func(obj as AbstractBullet);
		}
	}
	
	public function applyToUnfriendlyBullets(func:Function):void {
		for (var obj:Object in unfriendlyBullets) {
			func(obj as AbstractBullet);
		}
	}
	
}

}