// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.enemies {
	
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import flash.utils.Timer;

import tc.common.application.IUpdatable;
import tc.common.graphics.AnimatedBitmap;
import tc.common.util.MathUtil;
import tc.common.util.SpriteUtil;
import tc.friendrescue.events.EnemyEvent;
import tc.friendrescue.social.Friend;
import tc.friendrescue.watchers.AbstractGuidanceSystem;

public class AbstractEnemy extends AnimatedBitmap implements IUpdatable {
	
	public static const INJURED:String = 'enemyHasTakenABullet';
	public static const DESTROYED:String = 'enemyHasGoneKaboomEvent';
	public static const RESCUED:String = 'friendlyEnemyHasBeenRescued';
	
	public static const SIZE_TINY:int = 0;
	public static const SIZE_SMALL:int = 1;
	public static const SIZE_MEDIUM:int = 2;
	public static const SIZE_BIG:int = 3;
	
	private static const FLASH_TIME:int = 150;
	private static const flashFilter:GlowFilter = new GlowFilter(0x00ff00, 1, 10, 10);
	
	public var useHitTest:Boolean;
	public var friend:Friend;
	public var madeOfLiquid:Boolean;
	
	protected var armor:int;
	protected var points:int;
	protected var maxSpeed:Number;
	protected var acceleration:Number;
	protected var avoidsBullets:Boolean;
	protected var size:int;
	protected var friendly:Boolean;
	protected var guidanceSystem:AbstractGuidanceSystem;
	protected var vx:Number = 0;
	protected var vy:Number = 0;
	protected var tint:ColorTransform;
	
	private var rate:Number = 0;
	private var leftBound:int;
	private var topBound:int;
	private var rightBound:int;
	private var bottomBound:int;
	private var flashTicksRemaining:int;
	
	public function AbstractEnemy(spriteSheet:Bitmap, cellWidth:int, cellHeight:int,
			cellCount:int, speed:int, bounds:Rectangle,
			guidanceSystem:AbstractGuidanceSystem) {
		super(spriteSheet, cellWidth, cellHeight, cellCount, speed);
		this.guidanceSystem = guidanceSystem;
		
		useHitTest = false;
		armor = 1;
		avoidsBullets = false;
		size = SIZE_MEDIUM;
		friendly = false;
		tint = null;
		madeOfLiquid = false;
		
		leftBound = bounds.x;
		topBound = bounds.y;
		rightBound = leftBound + bounds.width;
		bottomBound = topBound + bounds.height;
	}
	
	// Can be overridden if a subclass wants to point itself.
	protected function setDirection(directionRadians:Number):void { }
	
	public function hasArmor():Boolean {
		return armor > 0;
	}
	
	public function injure():void {
		armor--;
		if (hasArmor()) {
			dispatchEvent(new EnemyEvent(INJURED, this));
		}
	}
	
	public function isFriendly():Boolean {
		return friendly;
	}
	
	public function getSize():int {
		return size;
	}
	
	public function getPoints():int {
		return points;
	}
	
	public function getTint():ColorTransform {
		return tint;
	}
	
	override public function update(deltaTime:int):void {
		super.update(deltaTime);
		
		var distance:int = SpriteUtil.distance(this, guidanceSystem.getTarget());
		var direction:Number = Math.atan2(this.y - guidanceSystem.getTarget().y,
				this.x - guidanceSystem.getTarget().x);
    
		// Gravitate toward the player if the player is present, otherwise gravitate
		// away from the center. If we're close, just decelerate.
		if (distance > width * .3) {
	    vx += MathUtil.fakeCos(direction) * acceleration;
	    vy += MathUtil.fakeSin(direction) * acceleration;
		} else {
	    vx *= acceleration;
	    vy *= acceleration;
		}
    
    // Gravitate away from bullets and other things.
    if (avoidsBullets) {
			var directionToAvoid:Number;
			var distanceToAvoid:Number;
			
			var self:AbstractEnemy = this; // 'this' isn't propagated.
    	guidanceSystem.applyAvoiders(function(obj:DisplayObject):void {
    		if (SpriteUtil.distance(self, obj) < 130) {
	    		directionToAvoid = Math.atan2(self.y - obj.y, self.x - obj.x);
	    		// Weird -- our MathUtil.fakeCos doesn't work well here.
	    		vx -= Math.cos(directionToAvoid) * acceleration * 10;
	    		vy -= Math.sin(directionToAvoid) * acceleration * 10;
	    	}
    	});
    }
    
    // Make sure we don't exceed maxSpeed.
    vx = Math.max(Math.min(maxSpeed, vx), -maxSpeed);
    vy = Math.max(Math.min(maxSpeed, vy), -maxSpeed);

    // Update the real X,Y coords.
		switch (guidanceSystem.getMode()) {
			case AbstractGuidanceSystem.MODE_CHASE:
				x -= vx * deltaTime;
				y -= vy * deltaTime;
				break;
			case AbstractGuidanceSystem.MODE_AVOID:
				x += vx * deltaTime;
				y += vy * deltaTime;
				break;
			default:
				// Go about our business...
		}
		
		// Check edges.
		var radiusX:int = width >> 1;
		var radiusY:int = height >> 1;
		if (x + radiusX > rightBound) {
			x = rightBound - radiusX;
			vx *= -1;
			playWallHit();
		}
		if (x - radiusX < leftBound) {
			x = leftBound + radiusX;
			vx *= -1;
			playWallHit();
		}
		if (y + radiusY > bottomBound) {
			y = bottomBound - radiusY;
			vy *= -1;
			playWallHit();
		}
		if (y - radiusY < topBound) {
			y = topBound + radiusY;
			vy *= -1;
			playWallHit();
		}
		
		// Update flash.
		flashTicksRemaining -= deltaTime;
		if (filters.length && flashTicksRemaining <= 0) {
			filters = null;
		}
		
		// An enemy might want to rotate itself to face the target.
		setDirection(direction);
	}
	
	private function playWallHit():void {
		return; // XXX
		if (Math.random() * 10 < 1) {
			if (Math.random() * 2 < 1) {
				SoundController.playSnapHi();
			} else {
				SoundController.playSnapLow();
			}
		}
	}
	
	public function flash():void {
		filters = [flashFilter];
		flashTicksRemaining = FLASH_TIME;
	}
	
	public function blink(count:int = 3):void {
		var blinkTimer:Timer = new Timer(50, count * 2); // Step must be even.
		blinkTimer.addEventListener(TimerEvent.TIMER, function(e:Event):void {
			alpha = alpha ? 0 : 100;
		});
		blinkTimer.start();
	}
	
	public function destroy():void {
		if (parent != null) {
			dispatchEvent(new EnemyEvent(DESTROYED, this));
		}
	}
	
	public function rescue():void {
		if (parent != null) {
			dispatchEvent(new EnemyEvent(RESCUED, this));
		}
	}
	
}

}