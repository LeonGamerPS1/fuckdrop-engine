package util.macro;

import sys.io.Process;

class GitMacro
{
	public static macro function getGitCommit()
	{
		var commit:String = 'unknown';

        final pos = haxe.macro.Context.currentPos();
		var process = new Process('git', ['rev-parse', 'HEAD']);

		if (process.exitCode() != 0)
		{
			var message = process.stderr.readAll().toString();
			haxe.macro.Context.warning('Could not determine current git commit ; Is this a proper Git repository?\nError: $message', pos);
		}
		else
		{
			// read the output of the process
			var commitHash:String = process.stdout.readLine();
			var commitHashSplice:String = commitHash.substr(0, 7);

            commit = commitHashSplice;
			haxe.macro.Context.info('Git Commit: $commit', pos);
		}

		process.close();

		return macro $v{commit};
	}
}
