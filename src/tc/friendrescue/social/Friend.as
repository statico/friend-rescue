// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.social {
	
import flash.display.Bitmap;
import flash.net.URLRequest;
import flash.net.navigateToURL;

public class Friend {
	
	public static const MALE:String = 'male';
	public static const FEMALE:String = 'female';
	
	public var uid:int;
	public var name:String;
	public var sex:String;
	public var highScore:int;
	public var bitmap:Bitmap;
	public var profileUrl:String;
	
	public function Friend(uid:int, name:String, highScore:int, bitmap:Bitmap,
			sex:String, profileUrl:String = null) {
		this.uid = uid;
		this.name = name;
		this.highScore = highScore ? highScore : 0;
		this.bitmap = bitmap;
		this.sex = sex;
		this.profileUrl = profileUrl;
	}
	
	public function toString():String {
		return '[Friend uid=' + uid + ', name="' + name + '"' +
			', sex=' + sex + ', highScore=' + highScore + ']';
	}
	
	public function navigateToProfile():void {
		if (profileUrl != null) {
			navigateToURL(new URLRequest(profileUrl));
		} else {
			trace("can't navigate to URL for", this);
		}
	}

}

}