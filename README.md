# ckSurf-1.18kd-Release
  Last seen version of a great plugin, server crash fixed.
  No memory leak, no need to fully unload plugin on regular maps.
  Find me / Discuss here: https://forums.alliedmods.net/member.php?u=107052. More info in the included Readme.
  Taking no credit except the fixing part of a good ol' car, see below:
  - Replays related crashs fixed
  - Player & admin commands related issues fixed
  - Weapons and bots management reviewed to avoid errors & map crashs
  - Hooks/events updated, plugin now supports any kind of map
  - Timer handles and client indexes fixed

# Install 🏄
  - Copy cfg/server_example.cfg content to your server.cfg, then upload all files. Keep your own cleaner extension version if it works, as I will not update it.
  - Create a database entry in addons/sourcemod/configs/databases.cfg like so (you should set your user & password):
  https://nsa40.casimages.com/img/2019/10/10/191010010823736378.png
  - Start the server. Using -tickrate 102.4 parameter in command start line of a csgo surf server is recommended to avoid ramp glitch.
  Also consider using start /AboveNormal like said here: https://support.steampowered.com/kb_article.php?ref=5386-HMJI-5162

# Changelog
  - 04/03/20: Fixed a couple of handles not closing.
  - 16/01/20: Fixed weapon buy on regular maps like de_dust2,  and 'checkSpawns' log error.
  - Note: In plugins/disabled, there is a ckSurf_slh smx file (ckSurf_slnh for non discord users).  
    You can use the this version instead of the regular one, if you have properly set sv_hibernate_when_empty 0 in server.cfg and in server's launch command parameters.  
    It will never check and never change your hibernation status, which I recommend.
