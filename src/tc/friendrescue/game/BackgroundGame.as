// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.game {
	
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.utils.Timer;

import tc.common.application.ISpriteRegistry;
import tc.friendrescue.graphics.Wall;
import tc.friendrescue.graphics.bullets.BulletFactory;
import tc.friendrescue.graphics.enemies.AbstractEnemy;
import tc.friendrescue.graphics.enemies.EnemyFactory;
import tc.friendrescue.watchers.AbstractGuidanceSystem;
import tc.friendrescue.watchers.RandomGuidanceSystem;

public class BackgroundGame {
	
	private static const MAX_ENEMIES:int = 10;
	
	private var app:ISpriteRegistry;
	private var target:Sprite;
	private var enemyFactory:EnemyFactory;
	private var timer:Timer;
	
	public function BackgroundGame(app:ISpriteRegistry) {
		this.app = app;
		
		target = new Sprite();
	}
	
	public function show():void { 
		var bulletFactory:BulletFactory = new BulletFactory(app);
		var wall:Wall = new Wall(app);
		var guidanceSystem:AbstractGuidanceSystem =
			new RandomGuidanceSystem(app.getParent().stage.stageWidth,
					app.getParent().stage.stageHeight, app.getParent().stage);
		enemyFactory = new EnemyFactory(app, target, wall, bulletFactory, guidanceSystem);
		enemyFactory.soundEnabled = false;
		
		timer = new Timer(900);
		timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
			
			var count:int = enemyFactory.enemyCount();
			if (count > MAX_ENEMIES) {
				enemyFactory.applyToEnemies(function(enemy:AbstractEnemy):void {
					if (Math.random() * count * 0.25 < 1) {
						enemy.destroy();
					}
				});
			} else {
				var enemy:Sprite = enemyFactory.makeRandomPrimaryEnemy(false, false);
				enemy.alpha = 0.5;
			}
			
		});
		timer.start();
	}
	
	public function hide():void {
		timer.stop();
		enemyFactory.destroy();
	}
	
}

}