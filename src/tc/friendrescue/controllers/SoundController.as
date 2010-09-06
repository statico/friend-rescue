// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.controllers {
	
import flash.media.SoundTransform;

import mx.core.SoundAsset;
	
public class SoundController {
	
	public static var enabled:Boolean = true;
	
	private static const volume:SoundTransform = new SoundTransform(0.4);
	
	private static function	play(sound:SoundAsset):void {
		if (enabled) {
			sound.play(0, 0, volume);
		}
	}
	
	[Embed(source='../../../../sounds/sound19.mp3')]
	private static const NewShipMP3:Class;
	private static const newShip:SoundAsset = new NewShipMP3() as SoundAsset;
	public static function playNewShip():void { play(newShip) }
	
	[Embed(source='../../../../sounds/cardoording.mp3')]
	private static const LastLifeMP3:Class;
	private static const lastLife:SoundAsset = new LastLifeMP3() as SoundAsset;
	public static function playLastLife():void { play(lastLife) }
	
	[Embed(source='../../../../sounds/implosion.mp3')]
	private static const BigBoomMP3:Class;
	private static const bigBoom:SoundAsset = new BigBoomMP3() as SoundAsset;
	public static function playBigBoom():void { play(bigBoom) }
	
	[Embed(source='../../../../sounds/shotgun.mp3')]
	private static const SmallBoomMP3:Class;
	private static const smallBoom:SoundAsset = new SmallBoomMP3() as SoundAsset;
	public static function playSmallBoom():void { play(smallBoom) }
	
	[Embed(source='../../../../sounds/squishwe.mp3')]
	private static const SplitMP3:Class;
	private static const split:SoundAsset = new SplitMP3() as SoundAsset;
	public static function playSplit():void { play(split) }
	
	[Embed(source='../../../../sounds/smallshot.mp3')]
	private static const BulletMP3:Class;
	private static const bullet:SoundAsset = new BulletMP3() as SoundAsset;
	public static function playBullet():void { play(bullet) }
	
	[Embed(source='../../../../sounds/beam01.mp3')]
	private static const SpawnMP3:Class;
	private static const spawn:SoundAsset = new SpawnMP3() as SoundAsset;
	public static function playSpawn():void { play(spawn) }
	
	[Embed(source='../../../../sounds/sound6.mp3')]
	private static const SmallClickMP3:Class;
	private static const smallClick:SoundAsset = new SmallClickMP3() as SoundAsset;
	public static function playSmallClick():void { play(smallClick) }
	
	[Embed(source='../../../../sounds/sound4.mp3')]
	private static const BigClickMP3:Class;
	private static const bigClick:SoundAsset = new BigClickMP3() as SoundAsset;
	public static function playBigClick():void { play(bigClick) }
	
	[Embed(source='../../../../sounds/snap_hi.mp3')]
	private static const SnapHiMP3:Class;
	private static const snapHi:SoundAsset = new SnapHiMP3() as SoundAsset;
	public static function playSnapHi():void { play(snapHi) }
	
	[Embed(source='../../../../sounds/snap_low.mp3')]
	private static const SnapLowMP3:Class;
	private static const snapLow:SoundAsset = new SnapLowMP3() as SoundAsset;
	public static function playSnapLow():void { play(snapLow) }
	
	[Embed(source='../../../../sounds/ping.mp3')]
	private static const PingMP3:Class;
	private static const ping:SoundAsset = new PingMP3() as SoundAsset;
	public static function playPing():void { play(ping) }
	
	[Embed(source='../../../../sounds/beam03.mp3')]
	private static const RescueMP3:Class;
	private static const rescue:SoundAsset = new RescueMP3() as SoundAsset;
	public static function playRescue():void { play(rescue) }
	
	[Embed(source='../../../../sounds/nautical015.mp3')]
	private static const ClankMP3:Class;
	private static const clank:SoundAsset = new ClankMP3() as SoundAsset;
	public static function playClank():void { play(clank) }
	
	[Embed(source='../../../../sounds/scifi002.mp3')]
	private static const PhotonMP3:Class;
	private static const photon:SoundAsset = new PhotonMP3() as SoundAsset;
	public static function playPhoton():void { play(photon) }
	
	[Embed(source='../../../../sounds/emergency030.mp3')]
	private static const AlertMP3:Class;
	private static const alert:SoundAsset = new AlertMP3() as SoundAsset;
	public static function playAlert():void { play(alert) }
	
	[Embed(source='../../../../sounds/woman-scream-1.mp3')]
	private static const WomanScreamOneMP3:Class;
	[Embed(source='../../../../sounds/woman-scream-2.mp3')]
	private static const WomanScreamTwoMP3:Class;
	[Embed(source='../../../../sounds/woman-scream-3.mp3')]
	private static const WomanScreamThreeMP3:Class;
	private static const femaleScreams:Array = [
		new WomanScreamOneMP3() as SoundAsset,
		new WomanScreamTwoMP3() as SoundAsset,
		new WomanScreamThreeMP3() as SoundAsset,
	];
	public static function playRandomFemaleScream():void {
		play(femaleScreams[Math.floor(Math.random() * femaleScreams.length)] as SoundAsset);
	}
	
	[Embed(source='../../../../sounds/man-scream-1.mp3')]
	private static const manScreamOneMP3:Class;
	[Embed(source='../../../../sounds/man-scream-2.mp3')]
	private static const manScreamTwoMP3:Class;
	[Embed(source='../../../../sounds/man-scream-3.mp3')]
	private static const manScreamThreeMP3:Class;
	private static const maleScreams:Array = [
		new manScreamOneMP3() as SoundAsset,
		new manScreamTwoMP3() as SoundAsset,
		new manScreamThreeMP3() as SoundAsset,
	];
	public static function playRandomMaleScream():void {
		play(maleScreams[Math.floor(Math.random() * maleScreams.length)] as SoundAsset);
	}

	[Embed(source='../../../../sounds/male-cackle.mp3')]
	private static const MaleCackleMP3:Class;
	private static const maleCackle:SoundAsset = new MaleCackleMP3() as SoundAsset;
	public static function playMaleCackle():void { play(maleCackle) }
	
	[Embed(source='../../../../sounds/female-cackle.mp3')]
	private static const FemaleCackleMP3:Class;
	private static const femaleCackle:SoundAsset = new FemaleCackleMP3() as SoundAsset;
	public static function playFemaleCackle():void { play(femaleCackle) }
	
	[Embed(source='../../../../sounds/emergency030.mp3')]
	private static const CheeringMP3:Class;
	private static const cheering:SoundAsset = new CheeringMP3() as SoundAsset;
	public static function playCheering():void { play(cheering) }
	
}

}