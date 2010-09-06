// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.watchers {
	
import tc.common.application.ISpriteRegistry;
import tc.common.application.IUpdatable;
import tc.common.util.TintUtil;
import tc.friendrescue.graphics.Wall;
import tc.friendrescue.graphics.bullets.AbstractBullet;
import tc.friendrescue.graphics.bullets.BulletFactory;
import tc.friendrescue.graphics.enemies.AbstractEnemy;
import tc.friendrescue.graphics.enemies.EnemyFactory;
import tc.friendrescue.graphics.explosions.ExplosionFactory;
	
public class BulletAndEnemyWatcher implements IUpdatable {
	
	private var app:ISpriteRegistry;
	private var bulletFactory:BulletFactory;
	private var enemyFactory:EnemyFactory;
	private var explosionFactory:ExplosionFactory;
	
	public function BulletAndEnemyWatcher(app:ISpriteRegistry, bulletFactory:BulletFactory,
			enemyFactory:EnemyFactory, wall:Wall, particleMultiplier:Number) {
		this.app = app;
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
		enemyFactory.applyToEnemies(function(enemy:AbstractEnemy):void {
			bulletFactory.applyToFriendlyBullets(function(bullet:AbstractBullet):void {
				
				// Sure this is gross, but inlining the math makes it faster.
				if ((enemy.useHitTest && enemy.hitTestObject(bullet)) ||
			 	  	(!enemy.useHitTest && Math.sqrt((bullet.x - enemy.x) * (bullet.x - enemy.x) +
			 	  		(bullet.y - enemy.y) * (bullet.y - enemy.y)) < enemy.width)) {
			 	  			
			 	  enemy.injure();
			 	  if (enemy.hasArmor()) {
			 	  	enemy.flash();
						explosionFactory.makeBigFlareExplosion(bullet.x, bullet.y, TintUtil.GREEN);	
			 	  } else {
			 	  	if (enemy.isFriendly()) {
			 	  		explosionFactory.makeBloodyExplosion(enemy.x, enemy.y);
			 	  		// Bad hardcoding below
							explosionFactory.makeTinyExplosionWithoutDebris(enemy.x, enemy.y);
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
				 	 	}
						enemy.destroy();
			 	  }
					bullet.destroy();
				}
				
			});
		});
	}

}

}