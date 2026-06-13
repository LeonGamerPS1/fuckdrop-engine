package backend.gameplay;

import backend.data.SongChartData;
import backend.data.SongMetaData;

class SongLoader
{
	public static function loadSong(songFolderName:String, ?songDifficulty:String)
	{
		var songFolder = 'data/songs/$songFolderName';
		var metaPath = '$songFolder/meta.json';
		if (!OpenFLAssets.exists(Paths.getPath(metaPath), TEXT))
			throw "SongLoader: Failed to find metadata " + metaPath;

		if (OpenFLAssets.exists(Paths.getPath('$songFolder/meta-$songDifficulty.json'), TEXT))
			metaPath = '$songFolder/meta-$songDifficulty.json';

		var songDataOBJ:SongChartData;
		var songMetaData:SongMetaData = SongMetaData.frompath(Paths.getPath(metaPath));
		if (!songMetaData.data.difficulties.contains(songDifficulty))
		{
			FlxG.log.warn("Failed to find difficulty "
				+ '"$songDifficulty" for song ${songMetaData.data.songDisplayName}. Selecting first diff available ${songMetaData.data.difficulties[0]}');
			songDifficulty = songMetaData.data.difficulties[0];
		}

		songDataOBJ = SongChartData.frompath(Paths.getPath('$songFolder/charts/$songDifficulty.json'), null, true);
		songDataOBJ.meta = songMetaData;
		// for  audios lol
		songDataOBJ.songFolder = songFolder;
		songDataOBJ.diff = songDifficulty;
		return songDataOBJ;
	}
}
