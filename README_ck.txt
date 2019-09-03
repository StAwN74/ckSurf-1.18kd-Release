[INTRO]
The 'no discord' version is lighter and doesn't use either SMJansson or SteamWorks.
Use ckSurf_sl.smx + discord_api.smx (MANDATORY for ckSurf_sl to work) to have the discord version, or simply use ckSurf_sln.smx to run the light version.
Base of the discord part before integration: https://github.com/Deathknife/sourcemod-discord
Base of ckSurf plugin: https://forums.alliedmods.net/showthread.php?t=264498
This version also refers to Fluffy's Nikooo's, Marcomadeira's and z4lab's forks.

[INSTALL]
1)  Copy and paste the text contained in cfg/server_example.cfg to your own server.cfg.
    Then drop all files of this archive to your server game directory (usually csgo).
2)  Before launching the server, do not forget to add a database access by editing your file addons/sourcemod/configs/databases.cfg like so:
(...)
	"cksurf"
	{
		"driver"			"sqlite"
		"database"			"cksurf-local"
		//"user"			"root"
		//"pass"			""
	}
(...)
3)  Start the server. Using -tickrate 102.4 parameter in command start line of a csgo server is highly recommended (to avoid the ramp glitch).
4)  To have the database file cksurf-local.sq3.example working, just rename it to cksurf-local.sq3 when you relaunch your server. Replays will also work (put them back in their parent folder) IF you have the proper tickrate.
*** However, it is recommended to launch without data and replays, and to create your own zones. And not to use premade database. ***
    To create your zones, you can use the !zones command in game, or even !insertmaptiers and !insertmapzones for a faster set up (both commands work, but some maps will always require manually created zones.)
5)  Enjoy. Bugs or notes (like why Force Assign to CT was removed): see below, or see you at https://forums.alliedmods.net/.

[NOTES]
Skins are no longer applied except arms, and default ones. Feel free to add sm_skinchooser plugin. Trails are working.
I recommend using noblood plugin enabled on bhop/surf/climb maps. csgo_spawntools is also useful to fix the T side spawn located inside the ground on bhop_easy_csgo. At least.
Both plugins above are included and set up for you if you install them.
This plugin supports sm plugins unload command, unlike original version.
No more mess like CT bots spawning T spawn even after unloading the plugin. (^|°)
It is still unadvised to do so; it is never advised to load/unload plugins manually cuz they could be doing some sql operation.
Anyway, this plugin now automatically detects if the map is a surf/bhop/climb map, so you don't need such command.

[More info...]
Quote from the script:

// 1.18 version from AlliedModders forums https://forums.alliedmods.net/showthread.php?t=264498 (latest official release) was known for having memory leaks and issues.
// A lot of issues like timers were fixed by Fluffy (as well as velocity, gravity glitches, etc.), but only for MySQL use. The fork (available on GitHub) is a lot different from the original.
// After having tested all versions from AlliedMods.net and GitHub (Nikooo's, Marco's, Fluffy's, z4lab's), I decided to make my own.
// In respect for all their efforts and great implementations, errors with bots touching zones, respawning, changing clan tag, getting their weapon stripped, etc... were ALWAYS there on my Windows CS:GO server.
// This version finally has all bots, weapons, memory issues fixed, AND works with SQLite.
// Discord api has been implemented (no cross-server msg on the other hand), as well as colorvariables. I could not compete with Fluffy's chat prefix support, but hey I hate too many prefix and colors in chat anyway.
// Force CT team function was intentionally forced off (cvar is still created), and server cvars are no longer forced by plugin, which now simply uses maps configs instead.
// NB: Bots can have weapons when they respawn if you slay them sometimes; this is also intentional. Some maps like surf_mesa REALLY mess up with player weapons, and were causing issues.
// This is, in one word (or four), a 'server crash free edition' of a great plugin.
// 01/08/19

[Thanks]
Every one listed above, and everyone at AlliedMods.
Credits and license: see above, see addons/sourcemod folder.
StAwN
