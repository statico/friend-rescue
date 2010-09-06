// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.controllers {
	
import flash.events.Event;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

import mx.core.SoundAsset;
	
public class MusicController {
	
	private static const volume:SoundTransform = new SoundTransform(0.4);
	
	private static var enabled_:Boolean = true;
	private static var channel:SoundChannel;
	
	public static function set enabled(value:Boolean):void {
		enabled_ = value;
		if (!enabled_) stop();
	}
	
	public static function get enabled():Boolean {
		return enabled_;
	}
	
	public static function stop():void {
		if (channel) {
			channel.stop();
		}
	}
	
	[Embed(source='../../../../sounds/ambient.mp3')]
	private static const AmbientMP3:Class;
	private static const ambient:SoundAsset = new AmbientMP3() as SoundAsset;
	
	public static function playAmbient():void {
		stop();
		if (enabled) {
			channel = ambient.play(0, int.MAX_VALUE, volume);
		}
	}
	
	[Embed(source='../../../../sounds/maintheme2-intro.mp3')]
	private static const MainThemeIntroMP3:Class;
	private static const mainThemeIntro:SoundAsset = new MainThemeIntroMP3() as SoundAsset;
	
	[Embed(source='../../../../sounds/maintheme2-loop.mp3')]
	private static const MainThemeLoopMP3:Class;
	private static const mainThemeLoop:SoundAsset = new MainThemeLoopMP3() as SoundAsset;
	
	public static function playMainTheme():void {
		stop();
		if (enabled) {
			channel = mainThemeIntro.play(0, 0, volume);
			channel.addEventListener(Event.SOUND_COMPLETE, loopMainTheme);
		}
	}
	
	private static function loopMainTheme(e:Event):void {
		channel.removeEventListener(Event.SOUND_COMPLETE, loopMainTheme);
		channel = mainThemeLoop.play(0, int.MAX_VALUE, volume);
	}
	
}

}		
