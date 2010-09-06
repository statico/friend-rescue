// Copyright (c) 2010 Ian Langworth

package tc.common.preloader {
	
import flash.display.Bitmap;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.media.Sound;
import flash.media.SoundTransform;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.text.TextField;
import flash.utils.Timer;
	
public class SplashScreen extends Sprite {
	
	private const white:int = 0xffffff;
	private const black:int = 0x000000;
	
	public var logo:Bitmap;
	
	private var stab:Sound;
	private var outTimer:Timer;
	private var step:int = 0;
	private var autoDismiss:Boolean;
	private var progress:TextField;
	private var tagline:TextField;
	
	public function SplashScreen(parent:Sprite, width:int, height:int,
			autoDismiss:Boolean = false) {
		super();
		this.autoDismiss = autoDismiss;
		
		// Background.
		graphics.beginFill(black);
		graphics.drawRect(0, 0, width, height);
		
		// Sound
		[Embed(source='../../../../assets/25.mp3')]
		var stabCls:Class;
		stab = new stabCls() as Sound;
		stab.play(0, 0, new SoundTransform(0.6));
		
		// Logo
		[Embed(source='../../../../assets/splash.png')]
		var logoCls:Class;
		logo = new logoCls() as Bitmap;
		logo.x = (width / 2) - (logo.width / 2);
		logo.y = (height / 2) - logo.height;
		addChild(logo);
		
		// Text
		var field:TextField = new TCTextField(width / 2, logo.y + logo.height + 10,
				'www.tremendous-creations.com');
		addChild(field);
				
		progress = new TCTextField(width / 2, field.y + field.textHeight + 10, 'x');
		addChild(progress);
		
		tagline = new TCTextField(width / 2, progress.y + progress.textHeight + 10);
		addChild(tagline);
		
		// Click handler
		addEventListener(MouseEvent.CLICK, onClick);
		
		// Begin phase one.
		dispatchEvent(new Event(Event.INIT));
		if (autoDismiss) {
			finishAfterDelay();
		}
		
		parent.addChild(this);
	}
	
	public function showProgress(percent:Number):void {
		progress.text = "Loading..." + Math.floor(percent * 100) + "%";
		
		if (percent >= 1) {
			var message:String;
			switch(Math.floor(Math.random() * 5)) {
				case 0: message = "You rock!"; break;
				case 1: message = " Sweet!"; break;
				case 2: message = "Let's go!"; break;
				case 3: message = "Get ready!"; break;
				case 4: message = "Rock on!"; break;
			}
			tagline.text = message;
		}
	}
	
	public function dismiss():void {
		if (!autoDismiss) {
			finishAfterDelay();
		}
	}
	
	private function finishAfterDelay(delay:int = 1000):void {
		outTimer = new Timer(delay, 1);
		outTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void {
			finishImmediately();
		});
		outTimer.start();
	}
	
	private function finishImmediately():void {
		parent.removeChild(this);
		dispatchEvent(new Event(Event.COMPLETE));
	}
	
	private function onClick(e:MouseEvent):void {
		var url:URLRequest = new URLRequest("http://www.tremendous-creations.com/");
		navigateToURL(url, "_blank");
	}

}

}