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

# Install:
  - Copy cfg/server_example.cfg content to your server.cfg, then upload all files. Keep your cleaner extension if it works.
  - Create a database entry in addons/sourcemod/configs/databases.cfg like so (you should set your user & password):
  https://nsa40.casimages.com/img/2019/10/10/191010010823736378.png
  - Start the server. Using -tickrate 102.4 parameter in command start line of a csgo surf server is recommended to avoid ramp glitch.
  Also consider using start /AboveNormal like said here: https://support.steampowered.com/kb_article.php?ref=5386-HMJI-5162

# Changelog:
  - 16/01/20: ck_surf sl, slh, sln, slnh .sp & .smx updated (8 files) and also scripting/cksurf/misc and hooks .sp (6 files).
    - > Fixed checkSpawns log error, and weapon buy on regular maps.
    - > A second log error has recently been reported to me (at RecordReplay callback when all velocities are null, i.e idle player). If it was due to the error above, it is now fixed.
    - > Remember, there is a ckSurf_slh (and a ckSurf_slnh for non discord users) smx version in plugins/disabled. 
    If you have properly set sv_hibernate_when_empty 0 in server.cfg and at launch (+sv_hibernate_when_empty 0), you can use the -slh (or -slnh) version instead of the regular one.  
    It will never check and never change your hibernation status, and I recommend using it.

# To Do:
If someone can help reduce handles (~1.1k handles running versus 40 or 100 for smaller plugins), this would be appreciated.

# <p align="center">🏄</p>
