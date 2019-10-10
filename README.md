# ckSurf-1.18kd-Release
  Last seen version of a great plugin, server crashs fixed.
  No memory leak, no need to fully unload plugin on regular maps.
  Find me / Discuss here: https://forums.alliedmods.net/member.php?u=107052. More info in the included Readme.
  Taking no credit except the fixing part of a good ol' car, see below:
  - Replay related crashs fixed
  - Player & admin commands related issues fixed
  - Weapons, bots and respawn management reviewed to avoid errors & map crashs
  - Hooks/events updated and plugin supports any kind of map
  - Timer handles and client indexes fixed

# Install:
  - Copy cfg/server_example.cfg content to your server.cfg
  - Create a database entry in addons/sourcemod/configs/databases.cfg like so (set your user & pw):
  https://nsa40.casimages.com/img/2019/10/10/191010010823736378.png
  - Start the server. Using -tickrate 102.4 parameter in command start line of a surf csgo server is recommended to avoid ramp glitch.
  Also consider using start /AboveNormal like said here: https://support.steampowered.com/kb_article.php?ref=5386-HMJI-5162
