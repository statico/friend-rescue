// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.events {

import flash.events.Event;

import tc.friendrescue.graphics.enemies.AbstractEnemy;

public class EnemyEvent extends Event {
	
	public var enemy:AbstractEnemy;
	
	public function EnemyEvent(type:String, enemy:AbstractEnemy,
			bubbles:Boolean=false, cancelable:Boolean=false) {
		super(type, bubbles, cancelable);
		this.enemy = enemy;	
	}
	
}

}