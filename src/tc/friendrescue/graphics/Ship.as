// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics {
	
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import flash.utils.Timer;

import tc.common.application.ISpriteRegistry;
import tc.common.application.IUpdatable;
import tc.common.graphics.DirectionalBitmap;
import tc.common.util.MathUtil;
import tc.common.util.TintUtil;
import tc.friendrescue.controllers.KeyboardController;
import tc.friendrescue.controllers.SoundController;
import tc.friendrescue.events.DirectionEvent;
import tc.friendrescue.graphics.bullets.BulletFactory;
import tc.friendrescue.graphics.exhaust.ExhaustFactory;
import tc.friendrescue.watchers.IToggleable;

public class Ship extends DirectionalBitmap implements IToggleable, IUpdatable {
    
	[Embed(source='../../../../graphics/ship.png')]
	private static const ShipPNG:Class;
	private static const ship:Bitmap = new ShipPNG() as Bitmap;
	
	public static const MOVE_PIXELS:Number = 250 / 1000;
	public static const TURN_DEGREES:Number = 2000 / 1000; 
	public static const INVINCIBLE_PERIOD:int = 5;
	
	public static const DIED:String = 'shipWentKablooeyEvent';
	public static const STARTED:String = 'aNewShipHasBeenCreated';
	
	private static const tint:ColorTransform = TintUtil.CYAN;
	    
	private static const FLASH_TIME:int = 150;
	private static const flashFilter:GlowFilter = new GlowFilter(0x00ffff);
	
	public var vulnerable:Boolean;
	    
	private var particleFactory:ExhaustFactory;
	private var keyboardController:KeyboardController;
	private var bulletFactory:BulletFactory;
	private var active:Boolean;
	private var app:ISpriteRegistry;
	private var leftBound:int;
	private var topBound:int;
	private var rightBound:int;
	private var bottomBound:int;
	private var flashTicksRemaining:int;
	
	public function Ship(app:ISpriteRegistry, bounds:Rectangle, bulletFactory:BulletFactory) {
		super(ship, 25, 25, 16);
		this.app = app;
		this.bulletFactory = bulletFactory;
		
		leftBound = bounds.x;
		topBound = bounds.y;
		rightBound = leftBound + bounds.width;
		bottomBound = topBound + bounds.height;
		
		var parent:Sprite = app.getParent();
		particleFactory = new ExhaustFactory(app);
		bulletFactory = new BulletFactory(app);
		keyboardController = new KeyboardController(parent.stage);
		parent.addChild(this);
	}
	
	public function isVulnerable():Boolean {
		return vulnerable;
	}
	
	public function isActive():Boolean {
		return active;
	}
	
	public function getTint():ColorTransform {
		return tint;
	}
	
	public function restart():void {
		SoundController.playNewShip();
	
		x = stage.stageWidth / 2
		y = stage.stageHeight / 2
		active = true;
		vulnerable = false;
		alpha = 1;
		
		var blinkTimer:Timer = new Timer(100, INVINCIBLE_PERIOD * 2); // Step must be even.
		blinkTimer.addEventListener(TimerEvent.TIMER, function(e:Event):void {
			alpha = alpha ? 0 : 100;
		});
		blinkTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:Event):void {
			vulnerable = true;
		});
		blinkTimer.start();
		
		app.subscribe(this);
		keyboardController.addEventListener(KeyboardController.FIRE_BULLET, onFireBullet);
		dispatchEvent(new Event(STARTED));
	}
	
	public function flash():void {
		filters = [flashFilter];
		flashTicksRemaining = FLASH_TIME;
	}
	
	public function explode():void {
		SoundController.playBigBoom();
		
		active = false;
		vulnerable = false;
		alpha = 0;
		
		app.unsubscribe(this);
		keyboardController.removeEventListener(KeyboardController.FIRE_BULLET, onFireBullet);
		dispatchEvent(new Event(DIED));
	}	
	
	public function destroy():void {
		app.getParent().removeChild(this);
		app.unsubscribe(this);
		keyboardController.removeEventListener(KeyboardController.FIRE_BULLET, onFireBullet);
	}
	
	override public function update(deltaTime:int):void {
		super.update(deltaTime);
		var distanceToCursor:Number = MathUtil.distance(x, y, stage.mouseX, stage.mouseY);
		var radiusX:int = width >> 1;
		var radiusY:int = height >> 1;
		
		if (distanceToCursor > 10) {
			particleFactory.makeExhaust(x, y, pseudoRotation + Math.random() * 90 - 45);
			if (parent) parent.addChild(this); // Make sure we're above the exhaust.
			
			// Stolen from http://www.kirupa.com/forum/archive/index.php/t-203063.html
			var rotationRadians:Number = MathUtil.angle(x, y, stage.mouseX, stage.mouseY)
			pseudoRotation = MathUtil.radiansToDegrees(rotationRadians);
			x += Math.cos(rotationRadians) * deltaTime * MOVE_PIXELS;
			y += Math.sin(rotationRadians) * deltaTime * MOVE_PIXELS;
		}
		if (x + radiusX > rightBound) {
			x = rightBound - radiusX;
		}
		if (x - radiusX < leftBound) {
			x = leftBound + radiusX;
		}
		if (y + radiusY > bottomBound) {
			y = bottomBound - radiusY;
		}
		if (y - radiusY < topBound) {
			y = topBound + radiusY;
		}
		
		// Update flash.
		flashTicksRemaining -= deltaTime;
		if (filters.length && flashTicksRemaining <= 0) {
			filters = null;
		}
	}
	
	private function onFireBullet(e:DirectionEvent):void {
		bulletFactory.addBullet(BulletFactory.TYPE_SHIP, x, y, e.getDirection());
	}
}

}