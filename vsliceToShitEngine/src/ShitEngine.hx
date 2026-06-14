typedef PreviewWindow =
{
	var startTime:Float;
	var endTime:Float;
}

typedef SongMetaDataRAW =
{
	var songDisplayName:String;
	var previewBPM:Float;
	var previewWindow:PreviewWindow;
	var volume:Float;
	var icon:String;
	var difficulties:Array<String>;
	var charter:String;
	var artist:String;
	var version:Int;
	var generatedBy:String;
	
}

typedef MusicTimeChangePoint =
	{
		var time:Float;
		var bpm:Float;
	}
typedef SongCharacterData =
{
	var boyfriend:String;
	var gf:String;
	var dad:String;
	var instPath:String;
	var playerVocals:Array<String>;
	var enemyVocals:Array<String>;
}

typedef SongChartDataR =
{
	public var characters:SongCharacterData; // for preloading lol
	public var stage:String;

	public var speed:Float;
	public var offset:Float;
	public var timingChanges:Array<MusicTimeChangePoint>;
	public var noteStyle:String;
	public var album:String;
	public var stickerPack:String;

	public var startPreview:Float;
	public var endPreview:Float;
	public var notes:Array<SongNoteData>;
	public var bpm:Float;
	@:optional
	public var events:Array<SongEventData>;
}

typedef SongNoteData =
{
	var l:Int; // lane, dad: 0 1 2 3, BF: 4 5 6 7
	var lms:Float; // length in MS
	var tms:Float; //  time/songPos
	@:optional var t:String; // type
}

typedef SwagSectionXMLBFXML =
{
	var sectionNotes:Array<Dynamic>;
	var lengthInSteps:Int;
	var typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Float;
	var changeBPM:Bool;
	var altAnim:Bool;
}

typedef SongEventData =
{
	var t:Int;
	var v:Array<Dynamic>;
	var n:String;
}

// Pussy fucked
class ShitEngine {
    public function new(value) {
        
    }
}