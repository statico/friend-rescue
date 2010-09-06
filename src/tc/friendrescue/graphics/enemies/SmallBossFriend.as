// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.enemies {

import flash.display.Bitmap;
import flash.geom.Rectangle;

import tc.common.util.MathUtil;
import tc.common.util.TintUtil;
import tc.friendrescue.controllers.SoundController;
import tc.friendrescue.graphics.bullets.BulletFactory;
import tc.friendrescue.social.Friend;
import tc.friendrescue.watchers.AbstractGuidanceSystem;

public class SmallBossFriend extends AbstractEnemy {
	
	[Embed(source='../../../../../graphics/small_boss.png')]
	private static const SmallBossPNG:Class;
	private static const smallBoss:Bitmap = new SmallBossPNG() as Bitmap;
	
	private static const SHOOT_RATE:int = 800;
	private static const SHOOT_VARIANCE:Number = 0.5;
	
	private var bulletFactory:BulletFactory;
	private var nextBulletTicks:int;
	
	public function SmallBossFriend(friend:Friend, bounds:Rectangle,
			guidanceSystem:AbstractGuidanceSystem, bulletFactory:BulletFactory) {
		super(smallBoss, 39, 39, 4, 200, bounds, guidanceSystem);
		this.friend = friend;
		this.bulletFactory = bulletFactory;
		
		useHitTest = true;
		armor = friend.highScore ? (friend.highScore / 300) + 1: 10;
		size = AbstractEnemy.SIZE_BIG;
		
		points = 300 + (friend.highScore ? friend.highScore * .05 : 0);
		maxSpeed = (45 + Math.random() * 10) / 800;
		acceleration = 0.004 + Math.random() * 0.006;
		tint = TintUtil.RED;
		
		nextBulletTicks = SHOOT_RATE;
	}
	
	override public function update(deltaTime:int):void {
		super.update(deltaTime);
		
		nextBulletTicks -= deltaTime;
		if (nextBulletTicks < 0) {
			nextBulletTicks = SHOOT_RATE * (Math.random() * (1 - SHOOT_VARIANCE) + (SHOOT_VARIANCE * 2));
			if (guidanceSystem.getMode() == AbstractGuidanceSystem.MODE_CHASE) {
				var r:int = rotation + 90;
				var bx:int = Math.cos(MathUtil.degreesToRadians(r)) * width * 0.3;
				var by:int = Math.sin(MathUtil.degreesToRadians(r)) * width * 0.3;
				bulletFactory.addBullet(BulletFactory.TYPE_SMALL_BOSS, x - bx, y - by, r);
			}
		}
	}
	
	override protected function setDirection(directionRadians:Number):void {
		rotation = directionRadians * 180 / Math.PI - 90;
	}
	
	override public function destroy():void {
		super.destroy();
	}
	
	public function playScream():void {
		if (friend.sex == Friend.FEMALE) {
			SoundController.playRandomFemaleScream();
		} else {
			SoundController.playRandomMaleScream();
		}
	}
	
	public function playCackle():void {
		if (friend.sex == Friend.FEMALE) {
			SoundController.playFemaleCackle();
		} else {
			SoundController.playMaleCackle();
		}
	}
	
}

}