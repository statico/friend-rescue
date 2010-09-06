// Copyright (c) 2010 Ian Langworth

package {
	
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.utils.Timer;

import tc.common.application.GameApplication;
import tc.common.application.ISpriteRegistry;
import tc.common.proxies.ListenableNumber;
import tc.friendrescue.controllers.KeyboardController;
import tc.friendrescue.controllers.MainMenuController;
import tc.friendrescue.controllers.MusicController;
import tc.friendrescue.controllers.SoundController;
import tc.friendrescue.events.EnemyEvent;
import tc.friendrescue.game.BackgroundGame;
import tc.friendrescue.game.InfiniteLevelEngine;
import tc.friendrescue.graphics.DestinationCursor;
import tc.friendrescue.graphics.Ship;
import tc.friendrescue.graphics.Wall;
import tc.friendrescue.graphics.bullets.BulletFactory;
import tc.friendrescue.graphics.enemies.EnemyFactory;
import tc.friendrescue.social.AbstractSocialNetwork;
import tc.friendrescue.social.Facebook;
import tc.friendrescue.social.FakeSocialNetwork;
import tc.friendrescue.social.Friend;
import tc.friendrescue.social.Leaderboard;
import tc.friendrescue.social.SocialNetworkEvent;
import tc.friendrescue.ui.ConsoleBackground;
import tc.friendrescue.ui.DataPanel;
import tc.friendrescue.ui.GameOver;
import tc.friendrescue.ui.LifeMeter;
import tc.friendrescue.ui.ScoreMeter;
import tc.friendrescue.ui.SocialNetworkLoader;
import tc.friendrescue.watchers.AbstractGuidanceSystem;
import tc.friendrescue.watchers.BulletAndEnemyWatcher;
import tc.friendrescue.watchers.ShipWatcher;
import tc.friendrescue.watchers.TargetingGuidanceSystem;

// Sync width and height with Preloader.
[SWF(width='500', height='500', backgroundColor='0x000000')]
[Frame(factoryClass='Preloader')]
public class FriendRescue extends MovieClip {
	
	private static const INITIAL_LIVES:Number = 3;
	private static const COPYRIGHT:String =  "(C) 2008 Tremendous Creations";
	
	private static const HIGH_PARTICLE_MULTIPLIER:Number = 1;
	private static const LOW_PARTICLE_MULTIPLIER:Number = 0.2;
	private static const HIGH_QUALITY_FPS:int = 60;
	private static const LOW_QUALITY_FPS:int = 35;
	
	private var app:ISpriteRegistry;
	private var bg:ConsoleBackground;
	private var bgGame:BackgroundGame;
	private var menuController:MainMenuController;
	private var lives:ListenableNumber;
	private var lifeMeter:LifeMeter;
	private var score:ListenableNumber;
	private var scoreMeter:ScoreMeter;
	private var cursor:DestinationCursor;
	private var ship:Ship;
	private var enemyFactory:EnemyFactory;
	private var levelEngine:InfiniteLevelEngine;
	private var bulletAndEnemyWatcher:BulletAndEnemyWatcher;
	private var shipWatcher:ShipWatcher;
	private var socialNetwork:AbstractSocialNetwork;
	private var leaderBoard:Leaderboard;
	private var wall:Wall;
	private var dataPanel:DataPanel;
	private var particleMultiplier:Number;
	
	public function FriendRescue() {
		trace('-----------------------------------------------------');
		super();
		
		// When the preloader finishes it will add us.
		addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
	}
	
	private function onAddedToStage(e:Event):void {
		stage.quality = StageQuality.LOW;
		
		// The secret parameter "localhost" lets us work in local development by
		// using a fake social network. It's called localhost to throw off hackers.
		var development:Boolean = root.loaderInfo.parameters.localhost != null;
		if (root.loaderInfo.parameters.fb_sig != null) {
			socialNetwork = new Facebook(development, root);
		} else if (development) {
			socialNetwork = new FakeSocialNetwork(development);
		} else {
			graphics.beginFill(0xff0000);
			graphics.lineStyle(0, 0, 0);
			graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			return;
		}
		trace('Social network:', socialNetwork);
		
		stage.frameRate = HIGH_QUALITY_FPS;
		
		app = new GameApplication(this as Sprite);
		bg = new ConsoleBackground(app);
		cursor = new DestinationCursor(app);
		bgGame = new BackgroundGame(app);
		
		dataPanel = new DataPanel(app);
		
		function next():void {
			particleMultiplier = HIGH_PARTICLE_MULTIPLIER;
			menuController = new MainMenuController(app.getParent());
			menuController.addEventListener(MainMenuController.START_GAME, function(e:Event):void {
				startNewGame();
			});
			menuController.addEventListener(MainMenuController.QUALITY_ADJUST, function(e:Event):void {
				switch(menuController.quality) {
					case MainMenuController.QUALITY_HIGH:
						particleMultiplier = HIGH_PARTICLE_MULTIPLIER;
						stage.frameRate = HIGH_QUALITY_FPS;
						break;
					case MainMenuController.QUALITY_LOW:
						particleMultiplier = LOW_PARTICLE_MULTIPLIER;
						stage.frameRate = LOW_QUALITY_FPS;
						break;
				}
			});
			startMainMenu();
		}
		
		if (socialNetwork) {
			var loader:SocialNetworkLoader = new SocialNetworkLoader(app, socialNetwork);
			loader.addEventListener(Event.COMPLETE, function(e:Event):void {
				loader.destroy();
				next();
			});
			loader.load();
		} else {
			next();
		}
	}
	
	private function onRescuableFriendCreated(e:SocialNetworkEvent):void {
		if (e.data != null) {
			var friend:Friend = e.data as Friend;
			var pronoun:String = (friend.sex == Friend.MALE ? 'him' : 'her');
			dataPanel.setText("Rescue " + friend.name + "...\n" + 
					"Don't shoot " + pronoun + "!", true, friend.bitmap);
		}
	}
	
	private function onRescuableFriendRescued(e:SocialNetworkEvent):void {
		if (e.data != null) {
			var friend:Friend = e.data as Friend;
			var verb:String;
			switch (Math.floor(Math.random() * 2)) {
				case 0: verb = 'rescued';
				case 1: verb = 'saved';
			}
			dataPanel.setText('You ' + verb + ' ' + friend.name + '!');
		}
	}
	
	private function onRescuableFriendDestroyed(e:SocialNetworkEvent):void {
		if (e.data != null) {
			var friend:Friend = e.data as Friend;
			var verb:String;
			switch (Math.floor(Math.random() * 4)) {
				case 0: verb = 'fried';
				case 1: verb = 'destroyed';
				case 2: verb = 'blasted';
				case 3: verb = 'zapped';
			}
			dataPanel.setText('You ' + verb + ' ' + friend.name + '!');
		}
	}
	
	private function onBossFriendCreated(e:SocialNetworkEvent):void {
		if (e.data != null) {
			var friend:Friend = e.data as Friend;
			dataPanel.setText(friend.name + ' is attacking!', true, friend.bitmap);
		}
	}
	
	private function onBossFriendDestroyed(e:SocialNetworkEvent):void {
		if (e.data != null) {
			var friend:Friend = e.data as Friend;
			var verb:String;
			switch (Math.floor(Math.random() * 4)) {
				case 0: verb = 'defeated';
				case 1: verb = 'beat';
				case 2: verb = 'blasted';
				case 3: verb = 'crushed';
			}
			dataPanel.setText('You ' + verb + ' ' + friend.name + '!');
		}
	}
	
	private function startMainMenu():void {
		MusicController.playAmbient();
		bgGame.show();
		menuController.show();
		dataPanel.setText("High score: " + socialNetwork.getHighScore() +
				"\n" + COPYRIGHT, false);
		leaderBoard = new Leaderboard(app, socialNetwork);
		cursor.moveToFront();
	}
	
	private function startNewGame():void {
		MusicController.playMainTheme();
		menuController.hide();
		bgGame.hide();
		leaderBoard.destroy();
		
		lives = new ListenableNumber();
		lifeMeter = new LifeMeter(this, lives);
		lives.setValue(INITIAL_LIVES);
		
		score = new ListenableNumber();
		scoreMeter = new ScoreMeter(this, score);
		score.setValue(0);
		
		wall = new Wall(app);
		wall.alarmActivated = true;
		wall.addEventListener(Wall.WALL_ACTIVATED, onWallActivated);
		wall.addEventListener(Wall.WALL_DEACTIVATED, onWallDeactivated);
		
		cursor.moveToFront();
		
		var bulletFactory:BulletFactory = new BulletFactory(app);
		
		ship = new Ship(app, wall.bounds, bulletFactory);
		ship.addEventListener(Ship.DIED, function(e:Event):void {
			lives.subtract(1);
			if (lives.getValue() > 0) {
				var delay:Timer = new Timer(2000, 1);
				delay.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void {
					if (lives.getValue() == 1) {
						lifeMeter.blink();
					}
					ship.restart();
				});
				delay.start();
			} else {
				endGame();
			}
		});
		ship.restart();
		
		var guidanceSystem:AbstractGuidanceSystem = new TargetingGuidanceSystem(
				ship, ship, bulletFactory);
		enemyFactory = new EnemyFactory(app, ship, wall, bulletFactory,
				guidanceSystem, socialNetwork);
				
		function addPoints(e:EnemyEvent):void {
			score.add(e.enemy.getPoints());
		}
		function onDestroyed(e:EnemyEvent):void {
			if (e.enemy.friend && socialNetwork) {
				if (e.enemy.isFriendly()) {
					socialNetwork.recordFriendAsDestroyed(e.enemy.friend);
				} else {
					socialNetwork.recordFriendAsDefeated(e.enemy.friend);
					addPoints(e);
				}
			} else if (!e.enemy.isFriendly()) {
				addPoints(e);
			}
		}
		function onRescued(e:EnemyEvent):void {
			addPoints(e);
			if (socialNetwork) {
				socialNetwork.recordFriendAsRescued(e.enemy.friend);
			}
		}
		enemyFactory.addEventListener(EnemyFactory.ENEMY_SPLIT, addPoints);
		enemyFactory.addEventListener(EnemyFactory.ENEMY_DESTOYRED, onDestroyed);
		enemyFactory.addEventListener(EnemyFactory.ENEMY_RESCUED, onRescued);
		enemyFactory.addEventListener(SocialNetworkEvent.RESCUABLE_FRIEND_CREATED, onRescuableFriendCreated);
		enemyFactory.addEventListener(SocialNetworkEvent.RESCUABLE_FRIEND_RESCUED, onRescuableFriendRescued);
		enemyFactory.addEventListener(SocialNetworkEvent.RESCUABLE_FRIEND_DESTROYED, onRescuableFriendDestroyed);
		enemyFactory.addEventListener(SocialNetworkEvent.BOSS_FRIEND_CREATED, onBossFriendCreated);
		enemyFactory.addEventListener(SocialNetworkEvent.BOSS_FRIEND_DESTROYED, onBossFriendDestroyed);
		
		bulletAndEnemyWatcher = new BulletAndEnemyWatcher(app,
				bulletFactory, enemyFactory, wall, particleMultiplier);
		shipWatcher = new ShipWatcher(app, ship, bulletFactory, enemyFactory, wall,
				particleMultiplier);
		
		levelEngine = new InfiniteLevelEngine(enemyFactory, dataPanel);
		levelEngine.addEventListener(Event.COMPLETE, onLevelComplete);
		levelEngine.next();
		
		if (socialNetwork) {
			socialNetwork.recordGameBegin();
		}
			
		// XXX Cheat tests
		var cheatHandler:Function = function(e:KeyboardEvent):void {
			switch (e.charCode) {
				case '7'.charCodeAt(0):
					enemyFactory.makeEnemy(EnemyFactory.TYPE_SHIFTY);
					dataPanel.setText('CHEAT: more enemies');
					break;
				case '8'.charCodeAt(0):
					ship.vulnerable = false;
					dataPanel.setText('CHEAT: invincible');
					break;
				case '9'.charCodeAt(0):
					ship.vulnerable = true;
					dataPanel.setText('CHEAT: vulnerable');
					break;
				case '0'.charCodeAt(0):
					SoundController.playRandomFemaleScream();
					break;
				case '-'.charCodeAt(0):
					SoundController.playRandomMaleScream();
					break;
				case '='.charCodeAt(0):
					levelEngine.next();
					break;
			}
		};
		stage.addEventListener(KeyboardEvent.KEY_DOWN, cheatHandler);
	}
	
	private function onWallActivated(e:Event):void {
		KeyboardController.enabled = false;
	}
	
	private function onWallDeactivated(e:Event):void {
		KeyboardController.enabled = true;
	}
	
	private function onLevelComplete(e:Event):void {
		levelEngine.next();
	}
	
	private function endGame():void {
		wall.alarmActivated = false;
		
		// Save high score and game stats.
		if (socialNetwork) {
			socialNetwork.recordGameEnd(levelEngine.getLevel(), scoreMeter.getValue());
		}
			
		// Show game over screen and wait for mouse click.
		var gameOver:GameOver = new GameOver(app.getParent());
		dataPanel.setText('Game Over');
		
		gameOver.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
			SoundController.playBigClick();
			
			// Remove game bits in reverse order.
			gameOver.destroy();
			levelEngine.removeEventListener(Event.COMPLETE, onLevelComplete);
			levelEngine.destroy();
			shipWatcher.destroy();
			bulletAndEnemyWatcher.destroy();
			enemyFactory.destroy();
			wall.removeEventListener(Wall.WALL_ACTIVATED, onWallActivated);
			wall.removeEventListener(Wall.WALL_DEACTIVATED, onWallDeactivated);
			wall.destroy();
			ship.destroy();
			scoreMeter.destroy();
			lifeMeter.destroy();
			
			// Show the main menu.
			startMainMenu();
		});
		
		addChild(gameOver);
		cursor.moveToFront();
	}
	
}

}
