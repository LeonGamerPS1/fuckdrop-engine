package shitengine.backend.data;

typedef MusicMetaData =
{
	var ?artist:String;
	var ?songName:String;
	var ?looped:Bool;
	var timingChanges:Array<MusicTimeChangePoint>;
}
