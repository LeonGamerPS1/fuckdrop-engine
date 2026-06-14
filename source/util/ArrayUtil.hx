package util;

class ArrayUtil
{
	public static function countOf<T>(array:Array<T>, value:T)
	{
		var i = 0;
		for (guh in array)
			if (guh == value)
				i++;
		return i;
	}
}
