// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.game {
	
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;

import tc.friendrescue.graphics.enemies.EnemyFactory;
import tc.friendrescue.ui.DataPanel;
	
public class InfiniteLevelEngine extends EventDispatcher {
	
	private var enemyFactory:EnemyFactory;
	private var dataPanel:DataPanel;
	private var level:int;
	private var timer:Timer;
	private var destroyed:Boolean;
	
	public function InfiniteLevelEngine(enemyFactory:EnemyFactory, dataPanel:DataPanel,
			target:IEventDispatcher = null) {
		super(target);
		this.enemyFactory = enemyFactory;
		this.dataPanel = dataPanel;
		level = 0;
		destroyed = false;
	}
	
	public function destroy():void {
		destroyed = true;
		if (timer != null) {
			timer.stop();
		}
	}
	
	public function getLevel():int {
		return level;
	}
	
	public function next():void {
		level++;
		trace('Level ' + level);
		
		switch (level) {
			case 1:
				//rescuableFriendWave();break; //XXX
				//smallBossFriendWave();
				//mitosisWave(500, 1);
				goonWave(1200, 5);
				//rusherWave(0, 1, true);
				dataPanel.setText("Press W, A, S and D to fire.");
				break;
			case 2:
				mitosisWave(500, 1);
				dataPanel.setText("Your ship follows the cursor.");
				break;
			case 3:
				shiftyWave(500, 1);
				dataPanel.setText("If the cursor leaves the window,\n" + 
						"you lose control of the ship.");
				break;
			case 4:
				rescuableFriendWave();
				break;
			case 5:
				randomPrimaryWave(1300, 10);
				break;
			case 6:
				enemyFactory.makeEnemy(EnemyFactory.TYPE_RESCUABLE);
				goonWave(100, 40, true);
				break;
			case 7:
				smallBossFriendWave();
				break;
			case 8:
				enemyFactory.makeEnemy(EnemyFactory.TYPE_RESCUABLE);
				randomPrimaryWave(900, 10);
				break;
			case 9:
				dataPanel.setText("Keep your reflexes up!");
				crazyPrimaryWave(14);
				break;
			default:
				dataPanel.setText('', false);
				
				var delay:Number = Math.random() * 300 + (level > 10 ? 100 : 400);
				trace('Random delay: ' + delay);
				
				if (level % 4 == 0) {
					smallBossFriendWave();
					trace('Forcing small boss');
					break;
				}
				if (level % 2 == 0) {
					trace('Adding rescuable friend');
					enemyFactory.makeEnemy(EnemyFactory.TYPE_RESCUABLE);
				}
				if (level > 15 && Math.floor(Math.random() * 3) == 0) {
					trace('Adding rusher');
					enemyFactory.makeEnemy(EnemyFactory.TYPE_RUSHER);
				}
					
				if (level < 15) {
					switch (Math.floor(Math.random() * 7)) {
						case 0:
						case 1:
						case 2:
						  // This *was* randomPrimaryWave, but it takes work to get to level 15!
							randomSecondaryWave(delay, 30);
							break;
						case 3:
							crazyPrimaryWave(30);
							break;
						case 4:
							goonWave(200, 40, true);
							break;
						case 5:
							mitosisWave(100, 10, true);
							break;
						case 6:
							shiftyWave(200, 40, true);
							break;
						default:
							trace('oops! level < 15 switch');
					}
				} else {
					switch (Math.floor(Math.random() * 22)) {
						case 0:
						case 1:
						case 2:
						case 3:
						case 4:
						case 5:
							randomSecondaryWave(delay, 15 + level);
							break;
						case 6:
						case 7:
						case 8:
							crazySecondaryWave(15 + level);
							break;
						case 9:
						case 10:
						case 11:
							goonWave(200, level * 3, true);
							break;
						case 12:
						case 13:
						case 14:
							mitosisWave(100, level, true);
							break;
						case 15:
						case 16:
						case 17:
							shiftyWave(200, 20 + level * 2, true);
							break;
						case 18:
						case 19:
						case 20:
							swooperWave(200, 5 + Math.random() * level / 3, true);
							break;
						case 21:
							rusherWave(200, 3 + Math.random() * level / 3, true);
							break;
						default:
							trace('oops! level >= 15 switch');
					}
				}
		}
	}
	
	private function goonWave(delay:Number, count:Number, corners:Boolean = false):void {
		trace('Goons - delay=' + delay + ' count=' + count + ' corners=' + corners);
		repeatThenComplete(delay, count, function():Sprite {
			return enemyFactory.makeEnemy(EnemyFactory.TYPE_GOON, corners);
		});
	}

	private function mitosisWave(delay:Number, count:Number, corners:Boolean = false):void {
		trace('Mitosis - delay=' + delay + ' count=' + count + ' corners=' + corners);
		repeatThenComplete(delay, count, function():Sprite {
			return enemyFactory.makeEnemy(EnemyFactory.TYPE_MITOSIS, corners);
		});
	}

	private function shiftyWave(delay:Number, count:Number, corners:Boolean = false):void {
		trace('Shifty - delay=' + delay + ' count=' + count + ' corners=' + corners);
		repeatThenComplete(delay, count, function():Sprite {
			return enemyFactory.makeEnemy(EnemyFactory.TYPE_SHIFTY, corners);
		});
	}

	private function swooperWave(delay:Number, count:Number, corners:Boolean = false):void {
		trace('Swooper - delay=' + delay + ' count=' + count + ' corners=' + corners);
		repeatThenComplete(delay, count, function():Sprite {
			return enemyFactory.makeEnemy(EnemyFactory.TYPE_SWOOPER, corners);
		});
	}

	private function rusherWave(delay:Number, count:Number, corners:Boolean = false):void {
		trace('Rusher - delay=' + delay + ' count=' + count + ' corners=' + corners);
		repeatThenComplete(delay, count, function():Sprite {
			return enemyFactory.makeEnemy(EnemyFactory.TYPE_RUSHER, corners);
		});
	}

	private function randomPrimaryWave(delay:Number, count:Number, corners:Boolean = false):void {
		trace('Random primary - delay=' + delay + ' count=' + count + ' corners=' + corners);
		repeatThenComplete(delay, count, function():Sprite {
			return enemyFactory.makeRandomPrimaryEnemy(corners);
		});
	}
	
	private function crazyPrimaryWave(count:Number):void {
		trace('Crazy primary - count=' + count);
		repeatThenComplete(0, count, function():Sprite {
			return enemyFactory.makeRandomPrimaryEnemy(false);
		});
	}
	
	private function randomSecondaryWave(delay:Number, count:Number, corners:Boolean = false):void {
		trace('Random secondary - delay=' + delay + ' count=' + count + ' corners=' + corners);
		repeatThenComplete(delay, count, function():Sprite {
			return enemyFactory.makeRandomSecondaryEnemy(corners);
		});
	}
	
	private function crazySecondaryWave(count:Number):void {
		trace('Crazy secondary - count=' + count);
		repeatThenComplete(0, count, function():Sprite {
			return enemyFactory.makeRandomSecondaryEnemy(false);
		});
	}
	
	private function rescuableFriendWave():void {
		trace('Rescuable friend');
		repeatThenComplete(300, 1, function():Sprite {
			return enemyFactory.makeEnemy(EnemyFactory.TYPE_RESCUABLE);
		});
	}
	
	private function smallBossFriendWave():void {
		trace('Boss friend');
		enemyFactory.makeEnemy(EnemyFactory.TYPE_SMALL_BOSS);
		randomPrimaryWave(1000, 10, true);
	}
	
	private function repeatThenComplete(delay:Number, count:Number, func:Function):void {
		var remaining:Number = count;
		
		// If we're on a higher level, start the next level early, possibly.
		if (level > 15 && Math.random() > 0.5) {
			trace('This level will end early.');
			remaining--;
		}
		
		// Set up the new level timer.
		timer = new Timer(delay, count);
		timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
			
			// Call the given function using the InfiniteLevelEngine instance as 'this'.
			var enemy:Sprite = func.call(this);
			
			// Keep track of when a generated enemy has been removed. When all the
			// enemies are gone, start the next level.
			enemy.addEventListener(Event.REMOVED, function(e:Event):void {
				remaining--;
				if (remaining <= 0 && !destroyed) {
					dispatchEvent(new Event(Event.COMPLETE));
					trace('Level ' + level + ' complete.');
				}
			});
		});
		timer.start();
	}

}

}