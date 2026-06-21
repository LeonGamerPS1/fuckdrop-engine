package shitengine.backend;

#if DISCORD_ALLOWED
#if cpp
import cpp.ConstCharStar;
#end
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
import lime.app.Application;
import sys.thread.Thread;
#end

class DiscordClient
{
	public static function init()
	{
		#if DISCORD_ALLOWED
		final handlers:DiscordEventHandlers = new DiscordEventHandlers();
		handlers.ready = cpp.Function.fromStaticFunction(onReady);
		handlers.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		handlers.errored = cpp.Function.fromStaticFunction(onError);
		Discord.Initialize("1497941741289078955", cpp.RawPointer.addressOf(handlers), false, null);

		Thread.create(function():Void
		{
			while (true)
			{
				#if DISCORD_DISABLE_IO_THREAD
				Discord.UpdateConnection();
				#end

				Discord.RunCallbacks();

				Sys.sleep(1);
			}
		});

		Application.current.onExit.add((e) ->
		{
			Application.current.window.x = 0;

			Sys.println('Shutting down Discord RPC...');

			Discord.Shutdown();
		}, true, 9999);
		#end
	}

	#if cpp
	private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		Sys.println('Discord: Disconnected ($errorCode:$message)');
	}

	private static function onError(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		Sys.println('Discord: Error ($errorCode:$message)');
	}

	private static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void
	{
		final username:String = request[0].username;
		final globalName:String = request[0].username;
		final discriminator:Int = Std.parseInt(request[0].discriminator);

		if (discriminator != 0)
			Sys.println('Discord: Connected to user ${username}#${discriminator} ($globalName)');
		else
			Sys.println('Discord: Connected to user @${username} ($globalName)');

		changePresence();
	}
	#end

	public static function changePresence(?details:String = 'Booting up../Title', ?state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool = false,
			?endTimestamp:Float = 0)
	{
		#if DISCORD_ALLOWED
		var startTimestamp:Float = 0;
		if (hasStartTimestamp)
			startTimestamp = Date.now().getTime();
		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		presence.details = details;
		presence.state = state;
		presence.largeImageKey = 'monarch';
		presence.largeImageText = "Engine Version: " + Main.version;
		presence.smallImageKey = smallImageKey;
		// Obtained times are in milliseconds so they are divided so Discord can use it
		presence.startTimestamp = Std.int(startTimestamp / 1000);
		presence.endTimestamp = Std.int(endTimestamp / 1000);
		#end
		updatePresence();

		// trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}

	#if DISCORD_ALLOWED
	static var presence = new DiscordRichPresence();
	#end

	public static function updatePresence()
	{
		#if DISCORD_ALLOWED Discord.UpdatePresence(cpp.RawConstPointer.addressOf(presence)); #end
	}
}
