# ckSurf-1.18kd-Release 🌍
  ***! Recent update (jan 2023) - Test server at steam://connect/82.66.111.1:27016 !***  
  
  Latest version of a great Surf & Kz modes plugin, server crash AND map change fixed.  
  Player moves, acceleration and framerates are just neat with this plugin, either at 85 or 102.4 tickrate.  
  I know GoKz and KZTimer now have perfectly set up servers and addons, and I support them, but at the time, they were not on and hey, I love ckSurf.  
  It's like a light version of those two (no low gravity or sideways modes currently).  
  Available for any server tickrate. And you can play on regular maps ! 🔫  
  Find me / Discuss here: https://forums.alliedmods.net/member.php?u=107052. More info in the included Readme.  
  Taking no credit except the fixing part of a good ol' car, see below:  
  - Replays related crashs fixed. Bots' trails removed like in other forks, for performance.  
  - Player & admin commands related issues fixed. Some rcon commands (with client 0) were fuzzy.  
  - Weapons and bots management reviewed (some maps give weapons, some remove them) to avoid errors & maps crashs. Stress tests have been done. ;)  
  - Hooks/events updated, plugin now supports any kind of map & bots don't mess up with mp_restartgame.  
  - Timer handles and client indexes fixed. As for the commands and hooks, it was leading to weird situations.  

Notes: 'sm_clear' player console warning (start/end of run) is normal and harmless. It's a fix for a checkpoint plugin I also used, and figured out it could prevent an exploit, so I left it here.  
	   [DEV]On 5th feb 2023, my included compiler still works, it also works with newer compilers (1.9+).  
	   But new syntax is on a perpetual routine...[/DEV]  

Now you have colored start speed, and a [test server] (steam://connect/82.66.111.1:27016)  
Thanks to ZZK community and Freak.exe for testing, and support. Thx to Elzi / jonitaikaponi for the original idea.  
Thanks to Headline for his sm_goto:  https://forums.alliedmods.net/showthread.php?p=2323724  
My other plugins: http://www.sourcemod.net/plugins.php?cat=0&mod=-1&title=&author=St00ne&description=&search=1

# Install 🏄
  - Copy cfg/server_example.cfg content to your server.cfg, then upload all files. scripting, gamedata and extensions folders are not the latest, please back up your own.  
  - Create a database entry in addons/sourcemod/configs/databases.cfg like so (you should set your user & password):
  https://nsa40.casimages.com/img/2019/10/10/191010010823736378.png
  - Start the server. Using -tickrate 102.4 parameter in command start line of a csgo surf server is recommended to avoid ramp glitch.
  Also consider using start /AboveNormal like said here: https://support.steampowered.com/kb_article.php?ref=5386-HMJI-5162

# Changelog 👺
  - 28/01/23: Updated some include files to a newer syntax (smlib: effects & entities, checkpoints.inc: see Notes, ckSurf: buttonpress, sql, misc).  
			  Updated replay code to fix bots messed up at spawn.  
			  Updated Hud to new colored msgs.  
  
  - 06/07/20: Fixed PlayReplay error log.  
  
  - 20/06/20: Fixed bot custom skin if ck_custom_models was 1. Reset the 0.1 second timer. Code cleaned a little.  
  
  - 09-13/06/20: Fixed bots quota, plugin doesn't mix their IDs anymore. Reaload map if you have any quota pb.  
  Fixed lag on player quit/death!!  
  
  - 08/06/20: Added 'Estimated Start Speed' in player chat. Fixed the timer after going to spectator team (mb).  
  
  - 02/06/20: Fixed ragdoll removal, a lil' translation mistyping, & round end/match start on regular maps.  
  Added a raw "FakeClientCommandEx sm_clear" to prevent cheats whith another checkpoint plugin, adding a harmless console warning (sry though).  
  Discovered you should not try mp_restartgame on surf_summer (laggy).  
  
  - 16/01/20: Fixed weapon buy on regular maps like de_dust2,  and 'checkSpawns' log error. Plugin uses maps configs (cfg/sourcemod/ckSurf/map_types/) for respawn and round end. ck_autorespawn and ck_round_end are thus obsolete.  
  
  - Note: In plugins/disabled, there's a ckSurf_slh_rev smx file (ckSurf_slnh_rev for non discord users).  
    You can use the this version instead of the regular one, if you have properly set sv_hibernate_when_empty 0 in server.cfg and in server's launch command parameters.  
    It will never check and never change your hibernation status to write data in your database, which I recommend.