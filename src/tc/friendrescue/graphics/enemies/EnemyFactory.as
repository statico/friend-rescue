// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.enemies {
	
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.Dictionary;

import tc.common.application.ISpriteRegistry;
import tc.common.util.MathUtil;
import tc.common.util.SpriteUtil;
import tc.friendrescue.controllers.SoundController;
import tc.friendrescue.events.EnemyEvent;
import tc.friendrescue.graphics.Wall;
import tc.friendrescue.graphics.bullets.BulletFactory;
import tc.friendrescue.social.AbstractSocialNetwork;
import tc.friendrescue.social.Friend;
import tc.friendrescue.social.SocialNetworkEvent;
import tc.friendrescue.watchers.AbstractGuidanceSystem;

public class EnemyFactory extends EventDispatcher {
	
	public static const ENEMY_CREATED:String = 'aNewEnemyHasBeenCreated';
	public static const ENEMY_DESTOYRED:String = 'anEnemyHasBeenDestroyed';
	public static const ENEMY_RESCUED:String = 'anEnemyHasBeenRescued';
	public static const ENEMY_SPLIT:String = 'anEnemyHasSplitInTwoOrSomething';
	
	public static const TYPE_GOON:int = 0;
	public static const TYPE_SHIFTY:int = 1;
	public static const TYPE_MITOSIS:int = 2;
	public static const TYPE_RESCUABLE:int = 3;
	public static const TYPE_RUSHER:int = 4;
	public static const TYPE_SWOOPER:int = 5;
	public static const TYPE_SMALL_BOSS:int = 6;
	
	private var app:ISpriteRegistry;
	private var wall:Wall;
	private var ship:Sprite;
	private var enemies:Dictionary;
	private var bulletFactory:BulletFactory;
	private var guidanceSystem:AbstractGuidanceSystem;
	private var socialNetwork:AbstractSocialNetwork;
	public var soundEnabled:Boolean;
	
	public function EnemyFactory(app:ISpriteRegistry, ship:Sprite, wall:Wall,
			bulletFactory:BulletFactory,
			guidanceSystem:AbstractGuidanceSystem,
			socialNetwork:AbstractSocialNetwork = null,
			target:IEventDispatcher = null) {
		super(target);
		this.app = app;
		this.ship = ship;
		this.wall = wall;
		this.bulletFactory = bulletFactory;
		this.guidanceSystem = guidanceSystem;
		this.socialNetwork = socialNetwork;
		soundEnabled = true;
		enemies = new Dictionary();
	}
	
	public function applyToEnemies(func:Function):void {
		for (var obj:Object in enemies) {
			func(obj as AbstractEnemy);
		}
	}
	
	public function enemyCount():int {
		var count:int = 0;
		applyToEnemies(function(enemy:AbstractEnemy):void { count++ });
		return count;
	}
	
	public function makeRandomPrimaryEnemy(corners:Boolean = false,
			blink:Boolean = true):Sprite {
		var type:int;
		switch (Math.floor(Math.random() * 3)) {
			case 0: type = TYPE_GOON; break;
			case 1: type = TYPE_SHIFTY; break;
			case 2: type = TYPE_MITOSIS; break;
		}
		return makeEnemy(type, corners, blink);
	}

	public function makeRandomSecondaryEnemy(corners:Boolean = false,
			blink:Boolean = true):Sprite {
		var type:int;
		switch (Math.floor(Math.random() * 14)) {
			case 0:
			case 2:
			case 3:
				type = TYPE_GOON;
				break;
			case 4:
			case 5:
			case 6:
				type = TYPE_SHIFTY;
				break;
			case 7:
			case 8:
			case 9:
				type = TYPE_MITOSIS;
				break;
			case 10:
			case 11:
			case 12:
				type = TYPE_SWOOPER;
				break;
			case 13:
				type = TYPE_RUSHER;
				break;
		}
		return makeEnemy(type, corners, blink);
	}

	public function makeEnemy(type:Number, corners:Boolean = false,
			blink:Boolean = true):Sprite {
		var enemy:AbstractEnemy;
		var friend:Friend;
		
		// The X and Y values of the new enemy are calculated first since some types
		// of enemies will want to know where they are placed initially.
		var target:Sprite = guidanceSystem.getTarget();
		var sw:Number = wall.bounds.width;
		var sh:Number = wall.bounds.height;
		var newX:int;
		var newY:int;
		if (corners) {
			newX = sw * Math.floor(Math.random() * 2) + Math.random() * ship.width + wall.bounds.x;
			newY = sh * Math.floor(Math.random() * 2) + Math.random() * ship.height + wall.bounds.y;
		} else {
			// Choose a random location, but make sure the new enemy doesn't appear
			// right in front of the user.
			var distance:Number = 0;
			var minimumDistance:Number = target.width * 10;
			while (distance <= minimumDistance) {
				newX = Math.random() * (sw * 0.90) + (sw * 0.05);
				newY = Math.random() * (sh * 0.90) + (sh * 0.05);
				distance = MathUtil.distance(newX, newY, target.x, target.y);
			}
		}
		
		switch (type) {
			
			case TYPE_GOON:
				enemy = new GoonEnemy(wall.bounds, guidanceSystem);
				break;
				
			case TYPE_SHIFTY:
				enemy = new ShiftyEnemy(wall.bounds, guidanceSystem);
				break;
				
			case TYPE_SWOOPER:
				enemy = new SwooperEnemy(newX, newY, wall.bounds, guidanceSystem);
				break;
				
			case TYPE_RUSHER:
				enemy = new RusherEnemy(newX, newY, wall.bounds, guidanceSystem);
				break;
				
			case TYPE_MITOSIS:
				enemy = new MitosisEnemy(wall.bounds, guidanceSystem);
				enemy.addEventListener(AbstractEnemy.DESTROYED, function(e:EnemyEvent):void {
					var distance:Number = enemy.width * 1.5;
					
					var directionRadians:Number = SpriteUtil.angle(enemy, guidanceSystem.getTarget());
					var child1direction:Number = directionRadians + (Math.PI * 0.25);
					var child2direction:Number = directionRadians - (Math.PI * 0.25);
					
					// Mitosis enemies 'split'
					var child1:AbstractEnemy = new MitosisEnemyChild(wall.bounds, guidanceSystem,
						Math.cos(child1direction), Math.sin(child1direction));
					var child2:AbstractEnemy = new MitosisEnemyChild(wall.bounds, guidanceSystem,
						Math.cos(child2direction), Math.sin(child2direction));
					child1.x = enemy.x;
					child1.y = enemy.y;
					child2.x = enemy.x;
					child2.y = enemy.y;
					child1.alpha = enemy.alpha;
					child2.alpha = enemy.alpha;
					child1.rotation = 180;
					
					addEnemy(child1);
					addEnemy(child2);
				});
				break;
				
			case TYPE_RESCUABLE:
				if (socialNetwork != null) {
					friend = socialNetwork.getRescuableFriend();
					if (friend != null && friend.bitmap != null) {
						enemy = new RescuableFriend(friend, wall.bounds, guidanceSystem);
						dispatchEvent(new SocialNetworkEvent(SocialNetworkEvent.RESCUABLE_FRIEND_CREATED, friend));
						break;
					}
				}
				trace('Forced to return generic enemy instead of rescuable friend');
				return makeEnemy(TYPE_GOON, corners, blink);
				
			case TYPE_SMALL_BOSS:
				if (socialNetwork != null) {
					friend = socialNetwork.getBossFriend();
					if (friend != null && friend.bitmap != null) {
						enemy = new SmallBossFriend(friend, wall.bounds, guidanceSystem,
								bulletFactory);
						dispatchEvent(new SocialNetworkEvent(SocialNetworkEvent.BOSS_FRIEND_CREATED, friend));
						if (soundEnabled) SmallBossFriend(enemy).playCackle();
						break;
					}
				}
				trace('Forced to return generic enemy instead of boss friend');
				return makeEnemy(TYPE_GOON, corners, blink);
				
			default:
				throw new Error('Invalid enemy type: ' + type);
		}
		
		enemy.x = newX;
		enemy.y = newY;
		if (blink) {
			enemy.blink();
		}
		
		// Play sounds.
		if (soundEnabled) {
			switch (type) {
				case TYPE_SMALL_BOSS:
					SoundController.playAlert();
					break;
				default:
					SoundController.playSpawn();
			}
		}
		
		addEnemy(enemy);
		return enemy;
	}
	
	private function addEnemy(enemy:AbstractEnemy):void {
		//app.getParent().addChildAt(enemy, 1); // Index 1? I'll regret this...
		app.getParent().addChild(enemy);
		app.subscribe(enemy);
		enemies[enemy] = true;
		enemy.addEventListener(AbstractEnemy.INJURED, onEnemyInjured);
		enemy.addEventListener(AbstractEnemy.DESTROYED, onEnemyDestroyed);
		enemy.addEventListener(AbstractEnemy.RESCUED, onEnemyRescued);
		dispatchEvent(new EnemyEvent(ENEMY_CREATED, enemy));
	}
	
	private function onEnemyInjured(e:Event):void {
		SoundController.playClank();
	}
	
	private function onEnemyDestroyed(e:Event):void {
		var enemy:AbstractEnemy = e.target as AbstractEnemy;
		removeEnemy(enemy);
		
		// Play sounds.
		if (soundEnabled) {
			if (e.target is MitosisEnemy) {
				SoundController.playSplit();
			} else if (e.target is SmallBossFriend) {
				e.target.playScream();
				SoundController.playBigBoom();
				dispatchEvent(new SocialNetworkEvent(
						SocialNetworkEvent.RESCUABLE_FRIEND_DESTROYED, enemy.friend));
			} else if (e.target is RescuableFriend) {
				e.target.playScream();
				dispatchEvent(new SocialNetworkEvent(
						SocialNetworkEvent.BOSS_FRIEND_DESTROYED, enemy.friend));
			} else {
				SoundController.playSmallBoom();
			}
		}
		
		// Dispatch events.
		if (e.target is MitosisEnemy) {
			dispatchEvent(new EnemyEvent(ENEMY_SPLIT, enemy));
		} else {
			dispatchEvent(new EnemyEvent(ENEMY_DESTOYRED, enemy));
		}
	}
	
	private function onEnemyRescued(e:Event):void {
		var enemy:AbstractEnemy = e.target as AbstractEnemy;
		removeEnemy(enemy);
		
		// Play sounds.
		if (soundEnabled) {
			SoundController.playRescue();
		}
		
		// Dispatch events.
		dispatchEvent(new SocialNetworkEvent(
				SocialNetworkEvent.RESCUABLE_FRIEND_RESCUED, enemy.friend));
		dispatchEvent(new EnemyEvent(ENEMY_RESCUED, enemy));
	}
	
	public function destroy():void {
		guidanceSystem.destroy();
		
		// We need a separate list because removing things from Dictionaries
		// creates race conditions.
		var enemiesList:Array = [];
		applyToEnemies(function(enemy:AbstractEnemy):void {
			enemiesList.push(enemy);
		});
		for (var i:int = enemiesList.length - 1; i >= 0; i--) {
			removeEnemy(enemiesList[i] as AbstractEnemy);
		}
	}	
	
	private function removeEnemy(enemy:AbstractEnemy):void {
		delete enemies[enemy];
		app.unsubscribe(enemy);
		try {
			app.getParent().removeChild(enemy);
		} catch (e:ArgumentError) {
			// This event might fire twice in one frame.
			trace('app.getParent() has no child', enemy, 'for', this);
		}
		enemy.destroy();
	}
	
}

}