Don't use them. This is a ready to go version. These files are here for reference only.

Install: see README_ck.txt or check the fast install steps below:

1- copy cfg/server_example.cfg content to your server.cfg, then upload all files. Keep your cleaner extension if it works.

2- create a database entry in addons/sourcemod/configs/databases.cfg like so:

"Databases"
{
(...)
	"cksurf"
	{
		"driver"			"sqlite"
		"database"			"cksurf-local"
		//"user"			"root"
		//"pass"			""
	}
(...)
}

3- Start the server. Using -tickrate 102.4 parameter in command start line of a csgo server is highly recommended (to avoid ramp glitch).
   Also consider using start /AboveNormal like said here: https://support.steampowered.com/kb_article.php?ref=5386-HMJI-5162
