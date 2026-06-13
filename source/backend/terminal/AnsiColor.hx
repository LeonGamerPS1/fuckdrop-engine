package backend.terminal;

enum abstract AnsiColor(Int) from Int to Int
{
	// Foreground colors
	var Black = 30;
	var Red = 31;
	var Green = 32;
	var Yellow = 33;
	var Blue = 34;
	var Empty = 666;
	var Magenta = 35;
	var Cyan = 36;
	var White = 37;

	// Background colors (offset +10)
	var BgBlack = 40;
	var BgRed = 41;
	var BgGreen = 42;
	var BgYellow = 43;
	var BgBlue = 44;
	var BgMagenta = 45;
	var BgCyan = 46;
	var BgWhite = 47;

	// Style codes
	var Reset = 0;
	var Bold = 1;
	var Underline = 4;

	public inline function code():String
	{
		return "\x1b[" + this + "m";
	}
}
