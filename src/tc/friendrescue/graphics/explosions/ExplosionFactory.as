// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.graphics.explosions {

import flash.display.Sprite;
import flash.events.Event;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;

import tc.common.application.ISpriteRegistry;
import tc.common.application.IUpdatable;
import tc.common.util.TintUtil;

public class ExplosionFactory extends Sprite {
	
	private static const TYPE_ROCK:int = 0;
	private static const TYPE_SLIME:int = 1;
	private static const TYPE_SPARKLE:int = 2;
	private static const TYPE_FLARE:int = 3;
	
	private var app:ISpriteRegistry;
	private var bounds:Rectangle;
	private var multiplier:Number;
	
	public function ExplosionFactory(app:ISpriteRegistry, bounds:Rectangle,
			multiplier:Number = 1) {
		super();
		this.app = app;
		this.bounds = bounds;
		this.multiplier = multiplier;
		app.getParent().addChild(this);
	}
	
	public function makeSparkles(x:int, y:int):void {
		var count:int = 100 * multiplier;
		for (var i:int = 0; i < count; i++) {
			addRandomDebris(TYPE_SPARKLE, x, y, 1, TintUtil.randomTint(), false);
		}
	}
	
	public function makeTinyExplosionWithoutDebris(x:int, y:int):void {
		addExplosion(new TinyExplosion(x, y));
	}
	
	public function makeBloodyExplosion(x:int, y:int):void {
		addRandomDebris(TYPE_SLIME, x, y, 10, TintUtil.RED, false);
	}
	
	public function makeMediumFlareExplosion(x:int, y:int, tint:ColorTransform):void {
		addExplosion(new TinyExplosion(x, y));
		addRandomDebris(TYPE_FLARE, x, y, 30, tint, false);
	}
	
	public function makeBigFlareExplosion(x:int, y:int, tint:ColorTransform):void {
		addExplosion(new TinyExplosion(x, y));
		addRandomDebris(TYPE_FLARE, x, y, 50, tint, false);
	}
	
	public function makeTinyExplosion(x:int, y:int, liquid:Boolean, tint:ColorTransform):void {
		addExplosion(new TinyExplosion(x, y));
		var type:int = liquid ? TYPE_SLIME : TYPE_ROCK;
		addRandomDebris(type, x, y, Math.random() * 2, tint);
		addRandomDebris(TYPE_FLARE, x, y, Math.random() * 2 + 5, tint);
	}
	
	public function makeSmallExplosion(x:int, y:int, liquid:Boolean, tint:ColorTransform):void {
		addExplosion(new SmallExplosion(x, y));
		var type:int = liquid ? TYPE_SLIME : TYPE_ROCK;
		addRandomDebris(type, x, y, Math.random() * 2 + 5, tint);
		addRandomDebris(TYPE_FLARE, x, y, Math.random() * 2 + 10, tint);
	}
	
	public function makeMediumExplosion(x:int, y:int, liquid:Boolean, tint:ColorTransform):void {
		addExplosion(new MediumExplosion(x, y));
		var type:int = liquid ? TYPE_SLIME : TYPE_ROCK;
		addRandomDebris(type, x, y, Math.random() * 2 + 6, tint);
		addRandomDebris(TYPE_FLARE, x, y, 20, tint);
	}
	
	public function makeBigExplosion(x:int, y:int, liquid:Boolean, tint:ColorTransform):void {
		addExplosion(new BigExplosion(x, y));
		var type:int = liquid ? TYPE_SLIME : TYPE_ROCK;
		addRandomDebris(type, x, y, 75, tint);
		addRandomDebris(TYPE_FLARE, x, y, 50, tint);
	}
	
	private function addExplosion(obj:AbstractExplosion):void {
		obj.rotation = Math.random() * 360;
		app.subscribe(obj);
		addChild(obj);
		obj.addEventListener(AbstractExplosion.DESTROYED, onDestroyed);
	}
	
	private function addDebris(obj:AbstractDebris):void {
		app.subscribe(obj);
		addChild(obj);
		obj.addEventListener(AbstractDebris.DESTROYED, onDestroyed);
	}
	
	private function addRandomDebris(type:int, x:int, y:int, given:int,
			tint:ColorTransform, random:Boolean = true):void {
		var count:int = given * multiplier;
		if (count < 1) return;
		for (var i:int = 0; i < count; i++) {
			var givenTint:ColorTransform = random ? (Math.random() * 2 > 1 ? tint : null) : tint;
			switch(type) {
				case TYPE_FLARE: addDebris(new FlareDebris(x, y, bounds, givenTint)); break;
				case TYPE_ROCK: addDebris(new RockDebris(x, y, bounds, givenTint)); break;
				case TYPE_SLIME: addDebris(new SlimeDebris(x, y, bounds, givenTint)); break;
				case TYPE_SPARKLE: addDebris(new SparkleDebris(x, y, bounds, givenTint)); break;
			}
		}
	}
	
	private function onDestroyed(e:Event):void {
		var updatable:IUpdatable = e.target as IUpdatable;
		var sprite:Sprite = e.target as Sprite;
		app.unsubscribe(updatable);
		try {
			removeChild(sprite);
		} catch (e:ArgumentError) {
			// This event might fire twice in one frame.
		}
	}
	
	public function destroy():void {
		app.getParent().removeChild(this);
	}
	
}

}