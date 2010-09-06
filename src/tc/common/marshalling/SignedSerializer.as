// Copyright (c) 2010 Ian Langworth

package tc.common.marshalling {

import com.adobe.crypto.MD5;
import com.adobe.serialization.json.JSON;

public class SignedSerializer {
	
	static public function sign(key:String, data:String):String {
		return MD5.hash(data + key) + data;
	}
	
	static public function unSign(key:String, raw:String):String {
		var given:String = raw.substr(0, 32);
		var data:String = raw.substr(32);
		if (given.length == 0 || data.length == 0) {
			return null;
		}
		return (given == MD5.hash(data + key)) ? data : null;
	}
	
	static public function encode(key:String, obj:Object):String {
		var json:String = JSON.encode(obj);
		return sign(key, json);
	}
	
	static public function decode(key:String, raw:String):Object {
		var json:String = unSign(key, raw);
		if (json == null) {
			return null;
		}
		return JSON.decode(json);
	}

}

}