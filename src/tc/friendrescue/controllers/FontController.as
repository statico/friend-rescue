// Copyright (c) 2010 Ian Langworth

package tc.friendrescue.controllers {
	
public class FontController {
	
	[Embed(source='../../../../fonts/atmosphere/Atmosphere-Regular.TTF', fontName='Atmosphere')]
	private static const TitleFontTTF:Class;

	[Embed(source='../../../../fonts/TeleTekst.ttf', fontName='TeleTekst')]
	private static const MenuFontTTF:Class;
	
	[Embed(source='../../../../fonts/edit_undo/editundo.ttf', fontName='Edit Undo')]
	private static const ConsoleFontTTF:Class;
	
	[Embed(source='../../../../fonts/nokia_cellphone/nokiafc22.ttf', fontName='Nokia Cellphone')]
	private static const ScoreFontTTF:Class;
	
	public static const TITLE_FONT:String = 'Atmosphere';
	
	public static const MENU_FONT:String = 'TeleTekst';
	
	public static const SCORE_FONT:String = 'Nokia Cellphone';
	public static const SCORE_SIZE:int = 18;
	
	public static const CONSOLE_FONT:String = SCORE_FONT;
	public static const CONSOLE_SIZE:int = 8;
	
}
	
}