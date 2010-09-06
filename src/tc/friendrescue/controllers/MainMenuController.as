// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.controllers {
	
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.TimerEvent;
import flash.net.URLRequest;
import flash.net.navigateToURL;
import flash.utils.Timer;

import tc.common.util.ColorUtil;
import tc.friendrescue.ui.Menu;
import tc.friendrescue.ui.MenuItem;
import tc.friendrescue.ui.MenuItemWithOptions;

public class MainMenuController extends EventDispatcher {
	
	public static const START_GAME:String = 'startTheGame';
	public static const QUALITY_ADJUST:String = 'qualityAdjust';
	
	public static const QUALITY_HIGH:int = 0;
	public static const QUALITY_LOW:int = 1;
	
	public var difficultyMultiplier:int = 2;
	public var quality:int = QUALITY_HIGH;
	
	private var parent:Sprite;
	private var menu:Menu;
	private var timer:Timer;
	[Array('MenuItem')]
	private var items:Array;
	private var hue:int = 0;
	
	public function MainMenuController(parent:Sprite, target:IEventDispatcher = null) {
		super(target);
		this.parent = parent;
		items = new Array();
		
		var play:MenuItem = new MenuItem('Play');
		items.push(play);
		play.addEventListener(MenuItem.CHOOSE, function(e:Event):void {
			dispatchEvent(new Event(START_GAME));
		});
		
		var difficulty:MenuItemWithOptions =
				new MenuItemWithOptions('Difficulty:', ['Easy', 'Normal', 'Hard'], 'Normal');
		items.push(difficulty);
		difficulty.addEventListener(MenuItem.CHOOSE, function(e:Event):void {
			var item:MenuItemWithOptions = e.target as MenuItemWithOptions;
			switch (item.getSelectedValue()) {
				case 'Easy':
					difficultyMultiplier = 1;
					break;
				case 'Normal':
					difficultyMultiplier = 2;
					break;
				case 'Hard':
					difficultyMultiplier = 3;
					break;
			}
		});
		
		var speed:MenuItemWithOptions =
				new MenuItemWithOptions('Quality:', ['High', 'Low'], 'High');
		items.push(speed);
		speed.addEventListener(MenuItem.CHOOSE, function(e:Event):void {
			var item:MenuItemWithOptions = e.target as MenuItemWithOptions;
			switch (item.getSelectedValue()) {
				case 'High':
					quality = QUALITY_HIGH;
					break;
				case 'Low':
					quality = QUALITY_LOW;
					break;
			}
			dispatchEvent(new Event(QUALITY_ADJUST));
		});
		
		var music:MenuItemWithOptions =
				new MenuItemWithOptions('Music:', ['On', 'Off'], 'On');
		items.push(music);
		music.addEventListener(MenuItem.CHOOSE, function(e:Event):void {
			var item:MenuItemWithOptions = e.target as MenuItemWithOptions;
			switch (item.getSelectedValue()) {
				case 'On':
					MusicController.enabled = true;
					break;
				case 'Off':
					MusicController.enabled = false;
					break;
			}
		});
		
		var sfx:MenuItemWithOptions =
				new MenuItemWithOptions('Sound FX:', ['On', 'Off'], 'On');
		items.push(sfx);
		sfx.addEventListener(MenuItem.CHOOSE, function(e:Event):void {
			var item:MenuItemWithOptions = e.target as MenuItemWithOptions;
			switch (item.getSelectedValue()) {
				case 'On':
					SoundController.enabled = true;
					break;
				case 'Off':
					SoundController.enabled = false;
					break;
			}
		});
		
		var about:MenuItem = new MenuItem('About');
		items.push(about);
		about.addEventListener(MenuItem.CHOOSE, function(e:Event):void {
			var url:URLRequest =
					new URLRequest("http://www.tremendous-creations.com/friendrescue/");
			navigateToURL(url);
		});
		
		menu = new Menu(parent, 'Friend Rescue', play, speed, music, sfx, about);
		
		hue = 45;
		timer = new Timer(50);
		timer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void {
			var color:int = ColorUtil.HSBToRGB(hue, 100, 100);
			menu.title.setColor(color);
			for (var i:int = 0; i < items.length; i++) {
				if (items[i].highlighted) {
					items[i].setColor(ColorUtil.HSBToRGB(hue + 180, 100, 100));
				} else {
					items[i].setColor(color);
				}
			}
			hue = (hue + 5) % 360;
		});
	}
	
	public function show():void {
		parent.addChild(menu);
		menu.resetActivation();
		menu.attach(parent.stage);
		timer.start();
	}
	
	public function hide():void {
		menu.detach(parent.stage);
		parent.removeChild(menu);
		timer.stop();
	}
}

}