// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.watchers {
	
import tc.common.application.ISpriteRegistry;
import tc.common.application.IUpdatable;
import tc.common.util.SpriteUtil;
import tc.friendrescue.graphics.Ship;
import tc.friendrescue.graphics.Wall;
import tc.friendrescue.graphics.bullets.AbstractBullet;
import tc.friendrescue.graphics.bullets.BulletFactory;
import tc.friendrescue.graphics.enemies.AbstractEnemy;
import tc.friendrescue.graphics.enemies.EnemyFactory;
import tc.friendrescue.graphics.explosions.ExplosionFactory;

public class ShipWatcher implements IUpdatable {
	
	private var app:ISpriteRegistry;
	private var ship:Ship;
	private var enemyFactory:EnemyFactory;
	private var bulletFactory:BulletFactory;
	private var explosionFactory:ExplosionFactory;
	
	public function ShipWatcher(app:ISpriteRegistry, ship:Ship,
			bulletFactory:BulletFactory,
			enemyFactory:EnemyFactory,
			wall:Wall,
			particleMultiplier:Number) {
		this.app = app;
		this.ship = ship;
		this.bulletFactory = bulletFactory;
		this.enemyFactory = enemyFactory;
		this.explosionFactory = new ExplosionFactory(app, wall.getBoundsRect(),
				particleMultiplier);
		app.subscribe(this);
	}
		
	public function destroy():void {
		app.unsubscribe(this);
		explosionFactory.destroy();
	}
	
	public function update(deltaTime:int):void {
		
		// Check unfriendly bullets colliding with the player's ship.
		bulletFactory.applyToUnfriendlyBullets(function(bullet:AbstractBullet):void {
			if (SpriteUtil.distance(ship, bullet) < ship.width) {
				if (ship.isVulnerable()) {
					explosionFactory.makeBigExplosion(ship.x, ship.y, false, ship.getTint());
					ship.explode();
				} else {
					explosionFactory.makeMediumFlareExplosion(bullet.x, bullet.y, ship.getTint());	
					ship.flash();
				}
				bullet.destroy();
			}
		});
			 	  			
		// Check enemies colliding with the player's ship.
		enemyFactory.applyToEnemies(function(enemy:AbstractEnemy):void {
			if ((enemy.useHitTest && enemy.hitTestObject(ship)) ||
		 	  	(!enemy.useHitTest && SpriteUtil.distance(ship, enemy) < ship.width)) {
		 	  		
		 	 	if (enemy.isFriendly()) {
		 	 		enemy.rescue();
		 	 		explosionFactory.makeSparkles(enemy.x, enemy.y);
		 	 	} else {
			 	  enemy.injure();
			 	  if (enemy.hasArmor()) {
			 	  	enemy.flash();
			 	  } else {
			 	 		switch (enemy.getSize()) {
			 	 			case AbstractEnemy.SIZE_TINY:
								explosionFactory.makeTinyExplosion(enemy.x, enemy.y, enemy.madeOfLiquid, enemy.getTint());	
								break;
			 	 			case AbstractEnemy.SIZE_SMALL:
								explosionFactory.makeSmallExplosion(enemy.x, enemy.y, enemy.madeOfLiquid, enemy.getTint());	
								break;
			 	 			case AbstractEnemy.SIZE_BIG:
								explosionFactory.makeBigExplosion(enemy.x, enemy.y, enemy.madeOfLiquid, enemy.getTint());	
								break;
			 	 			default:
								explosionFactory.makeMediumExplosion(enemy.x, enemy.y, enemy.madeOfLiquid, enemy.getTint());	
						}
						enemy.destroy();
		 	 		}
					if (ship.isVulnerable()) {
						explosionFactory.makeBigExplosion(ship.x, ship.y, false, ship.getTint());
						ship.explode();
					} else {
						ship.flash();
					}
		 	 	}
		 	 	
			}
		});
	}

}

}