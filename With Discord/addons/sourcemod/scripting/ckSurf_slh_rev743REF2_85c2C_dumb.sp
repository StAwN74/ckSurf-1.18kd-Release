/*=============================================
=         ckSurf - CS:GO Perfect Timer         *
*                By Elzi & Fixed by StAwN      =
=                      -                       *
*       Thanks to AlliedModders and Elzi       =
=  Thx to Baca, Marco, Nikooo, Fluffy, z4lab's *
==============================================*/
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
// GoTo function by Headline, with his acceptation https://forums.alliedmods.net/showthread.php?p=2323724
// 13/06/20

/*=============================================
=            		Includes		          =
=============================================*/

#include <sourcemod>
#include <sdkhooks>
#include <adminmenu>
#include <cstrike>
#include <smlib>
#include <geoip>
#include <basecomm>
#include <colorvariables>
#undef REQUIRE_EXTENSIONS
#include <clientprefs>
#undef REQUIRE_PLUGIN
#include <dhooks>
#include <mapchooser>
#include <ckSurf>
#include <discord>

/*====================================
=            Declarations            =
====================================*/


/*============================================
=           	 Definitions 		         =
=============================================*/

// Require new syntax and semicolons
#pragma newdecls required
#pragma semicolon 1

// Plugin info
#define VERSION "1.18kd by StAwN"
#define PLUGIN_VERSION 118kd_StAwN

// Database definitions
#define MYSQL 0
#define SQLITE 1
#define PERCENT 0x25

// Chat colors
#define WHITE 0x01
#define DARKRED 0x02
#define PURPLE 0x03
#define GREEN 0x04
#define MOSSGREEN 0x05
#define LIMEGREEN 0x06
#define RED 0x07
#define ORANGE 0x10
#define GRAY 0x08
#define YELLOW 0x09
#define DARKGREY 0x0A
#define BLUE 0x0B
#define DARKBLUE 0x0C
#define LIGHTBLUE 0x0D
#define PINK 0x0E
#define LIGHTRED 0x0F

// Trail definitions
#define BEAMLIFE 2.0
#define BONUS_BOT_TRAIL_COLOR {255, 255, 0, 255}
#define RECORD_BOT_TRAIl_COLOR {0, 0, 255, 255}
#define RGB_GREEN {0, 255, 0, 255}
#define RGB_RED {255, 0, 0, 255}
#define RGB_DARKRED {139, 0, 0, 255}
#define RGB_BLUE {0, 0, 255, 255}
#define RGB_LIGHTBLUE {178, 223, 238, 255}
#define RGB_DARKBLUE {0, 0, 139, 255}
#define RBG_YELLOW {255, 255, 0, 255}
#define RGB_GREENYELLOW {173, 255, 47, 255}
#define RGB_PURPLE {128, 0, 128, 255}
#define RGB_MAGENTA {255, 0, 255, 255}
#define RGB_PINK {238, 162, 173, 255}
#define RGB_WHITE {248, 248, 255, 255}
#define RGB_CYAN {0, 255, 255, 255}
#define RGB_SPRINGGREEN {0, 255, 127, 255}
#define RGB_OLIVE {192, 255, 62, 255}
#define RGB_ORANGE {238, 154, 0, 255}
#define RGB_GREY {145, 145, 145, 255}
#define RGB_DARKGREY {69, 69, 69, 255}

// Paths
#define CK_REPLAY_PATH "data/cKreplays/"
#define BLOCKED_LIST_PATH "configs/ckSurf/hidden_chat_commands.txt"
#define MULTI_SERVER_MAPCYCLE "configs/ckSurf/multi_server_mapcycle.txt"
#define CUSTOM_TITLE_PATH "configs/ckSurf/custom_chat_titles.txt"
#define SKILLGROUP_PATH "configs/ckSurf/skillgroups.cfg"
#define PRO_FULL_SOUND_PATH "sound/quake/holyshit.mp3"
#define PRO_RELATIVE_SOUND_PATH "*quake/holyshit.mp3"
#define CP_FULL_SOUND_PATH "sound/quake/wickedsick.mp3"
#define CP_RELATIVE_SOUND_PATH "*quake/wickedsick.mp3"
#define UNSTOPPABLE_SOUND_PATH "sound/quake/unstoppable.mp3"
#define UNSTOPPABLE_RELATIVE_SOUND_PATH "*quake/unstoppable.mp3"
#define CONFIG_DIR "sourcemod/ckSurf/map_types/"

// Checkpoint definitions
#define CPLIMIT 35			// Maximum amount of checkpoints in a map

// Zone definitions
#define ZONE_MODEL "models/props/de_train/barrel.mdl"
#define ZONEAMOUNT 9		// The amount of different type of zones	-	Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0)
#define MAXZONEGROUPS 11	// Maximum amount of zonegroups in a map
#define MAXZONES 128		// Maximum amount of zones in a map

// Ranking definitions
#define MAX_PR_PLAYERS 1066
#define MAX_SKILLGROUPS 64

// UI definitions
#define HIDE_RADAR (1 << 12)
#define HIDE_CHAT ( 1<<7 )
#define HIDE_CROSSHAIR 1<<8

// Replay definitions
#define BM_MAGIC 0xBAADF00D
#define BINARY_FORMAT_VERSION 0x01
#define ADDITIONAL_FIELD_TELEPORTED_ORIGIN (1<<0)
#define ADDITIONAL_FIELD_TELEPORTED_ANGLES (1<<1)
#define ADDITIONAL_FIELD_TELEPORTED_VELOCITY (1<<2)
#define FRAME_INFO_SIZE 15
#define AT_SIZE 10
#define ORIGIN_SNAPSHOT_INTERVAL 500
#define FILE_HEADER_LENGTH 74

// Title definitions
#define TITLE_COUNT 23		// The amount of custom titles that can be configured in custom_chat_titles.txt

/*====================================
=            Enumerations            =
====================================*/

enum FrameInfo
{
	playerButtons = 0, 
	playerImpulse, 
	Float:actualVelocity[3], 
	Float:predictedVelocity[3], 
	Float:predictedAngles[2], 
	CSWeaponID:newWeapon, 
	playerSubtype, 
	playerSeed, 
	additionalFields, 
	pause, 
}

enum AdditionalTeleport
{
	Float:atOrigin[3], 
	Float:atAngles[3], 
	Float:atVelocity[3], 
	atFlags
}

enum FileHeader
{
	FH_binaryFormatVersion = 0, 
	String:FH_Time[32], 
	String:FH_Playername[32], 
	FH_Checkpoints, 
	FH_tickCount, 
	Float:FH_initialPosition[3], 
	Float:FH_initialAngles[3], 
	Handle:FH_frames
}

enum MapZone
{
	zoneId,  				// ID within the map
	zoneType,  				// Types: Start(1), End(2), Stage(3), Checkpoint(4), Speed(5), TeleToStart(6), Validator(7), Chekcer(8), Stop(0)
	zoneTypeId, 			// ID of the same type eg. Start-1, Start-2, Start-3...
	Float:PointA[3], 
	Float:PointB[3], 
	Float:CenterPoint[3],
	String:zoneName[128], 
	zoneGroup, 
	Vis,
	Team
}

enum SkillGroup
{
	PointReq,				// Points required for next skillgroup
	NameColor,				// Color to use for name if colored chatnames is turned on
	String:RankName[32],	// Skillgroup name without colors
	String:RankNameColored[32], // Skillgroup name with colors
}

/*===================================
=            Plugin Info            =
===================================*/

public Plugin myinfo = 
{
	name = "ckSurf", 
	author = "Elzi", 
	description = "#clan.kikkeli's Surf Plugin", 
	version = VERSION, 
	url = ""
};

/*=================================
=            Variables            =
=================================*/

/*----------  Stages  ----------*/
int g_Stage[MAXZONEGROUPS][MAXPLAYERS + 1];						// Which stage is the client in
bool g_bhasStages; 		
bool WeAreOk = false;											// Is the map a surf, kz or bhop map

/*----------  Spawn locations  ----------*/
float g_fSpawnLocation[MAXZONEGROUPS][3];						// Spawn coordinates 
float g_fSpawnAngle[MAXZONEGROUPS][3];							// Spawn angle
bool g_bGotSpawnLocation[MAXZONEGROUPS]; 						// Does zonegroup have a spawn location

/*----------  Player titles  ----------*/
bool g_bflagTitles[MAXPLAYERS + 1][TITLE_COUNT]; 				// Which titles have been given for client
bool g_bflagTitles_orig[MAXPLAYERS + 1][TITLE_COUNT]; 			// Used to track which title the user gained / lost
bool g_bHasTitle[MAXPLAYERS + 1]; 								// Does the client have any titles
char g_szflagTitle_Colored[TITLE_COUNT][32]; 					// Titles with colors
char g_szflagTitle[TITLE_COUNT][32]; 							// Titles loaded from config
int g_iTitleInUse[MAXPLAYERS + 1]; 								// Which title the client is using
int g_iCustomTitleCount; 										// How many custom titles are loaded
// Chat Colors in String Format
char szWHITE[12], szDARKRED[12], szPURPLE[12], szGREEN[12], szMOSSGREEN[12], szLIMEGREEN[12], szRED[12], szGRAY[12], szYELLOW[12], szDARKGREY[12], szBLUE[12], szDARKBLUE[12], szLIGHTBLUE[12], szPINK[12], szLIGHTRED[12], szORANGE[12];
bool g_bAdminSelectedHasFlag[MAXPLAYERS + 1]; 					// Does the client the admin selected have titles?
char g_szAdminSelectedSteamID[MAXPLAYERS + 1][32]; 				// SteamID of the user admin chose when giving title
bool g_bAdminFlagTitlesTemp[MAXPLAYERS + 1][TITLE_COUNT]; 		// Which title admin chose to give in !givetitles
int g_iAdminSelectedClient[MAXPLAYERS + 1]; 					// Which clientid did the admin select
int g_iAdminEditingType[MAXPLAYERS + 1]; 						// What the admin is editing

/*----------  VIP Variables  ----------*/
// Enable VIP CVar
//bool g_bServerVipCommand;
ConVar g_hServerVipCommand;
// Trail variables
bool g_bTrailOn[MAXPLAYERS + 1]; 								// Client is using a trail
bool g_bTrailApplied[MAXPLAYERS + 1]; 							// Client has been given a title
bool g_bClientStopped[MAXPLAYERS + 1]; 							// Client is not moving
int g_iTrailColor[MAXPLAYERS + 1]; 								// Trail color the client is using
float g_fClientLastMovement[MAXPLAYERS + 1]; 					// Last time the client moved
// Auto VIP Cvar
int g_AutoVIPFlag;
bool g_bAutoVIPFlag;
ConVar g_hAutoVIPFlag = null;
// Vote Extend
char g_szUsedVoteExtend[MAXPLAYERS+1][32]; 						// SteamID's which triggered extend vote
int g_VoteExtends = 0; 											// How many extends have happened in current map
ConVar g_hVoteExtendTime; 										// Extend time CVar
ConVar g_hMaxVoteExtends; 										// Extend max count CVar

/*----------  Bonus variables  ----------*/
char g_szBonusFastest[MAXZONEGROUPS][MAX_NAME_LENGTH]; 			// Name of the #1 in the current maps bonus
char g_szBonusFastestTime[MAXZONEGROUPS][64]; 					// Fastest bonus time in 00:00:00:00 format
float g_fPersonalRecordBonus[MAXZONEGROUPS][MAXPLAYERS + 1]; 	// Clients personal bonus record in the current map
char g_szPersonalRecordBonus[MAXZONEGROUPS][MAXPLAYERS + 1][64]; // Personal bonus record in 00:00:00 format
float g_fBonusFastest[MAXZONEGROUPS]; 							// Fastest bonus time in the current map
float g_fOldBonusRecordTime[MAXZONEGROUPS];						// Old record time, for prints + counting
int g_MapRankBonus[MAXZONEGROUPS][MAXPLAYERS + 1];				// Clients personal bonus rank in the current map
int g_OldMapRankBonus[MAXZONEGROUPS][MAXPLAYERS + 1];			// Old rank in bonus
int g_bMissedBonusBest[MAXPLAYERS + 1]; 						// Has the client mbissed his best bonus time
int g_tmpBonusCount[MAXZONEGROUPS];								// Used to make sure bonus finished prints are correct
int g_iBonusCount[MAXZONEGROUPS]; 								// Amount of players that have passed the bonus in current map
int g_totalBonusCount; 											// How many total bonuses there are
bool g_bhasBonus;												// Does map have a bonus?

/*----------  Checkpoint variables  ----------*/
float g_fCheckpointTimesRecord[MAXZONEGROUPS][MAXPLAYERS + 1][CPLIMIT]; // Clients best run's times
float g_fCheckpointTimesNew[MAXZONEGROUPS][MAXPLAYERS + 1][CPLIMIT]; // Clients current run's times
float g_fCheckpointServerRecord[MAXZONEGROUPS][CPLIMIT]; 		// Server record checkpoint times
char g_szLastSRDifference[MAXPLAYERS + 1][64]; 					// Last difference to the server record checkpoint
char g_szLastPBDifference[MAXPLAYERS + 1][64]; 					// Last difference to clients own record checkpoint
float g_fLastDifferenceTime[MAXPLAYERS + 1]; 					// The time difference was shown, used to show for a few seconds in timer panel
float tmpDiff[MAXPLAYERS + 1]; 									// Used to calculate time gain / lost
int lastCheckpoint[MAXZONEGROUPS][MAXPLAYERS + 1]; 				// Used to track which checkpoint was last reached
bool g_bCheckpointsFound[MAXZONEGROUPS][MAXPLAYERS + 1]; 		// Clients checkpoints have been found?
bool g_bCheckpointRecordFound[MAXZONEGROUPS];					// Map record checkpoints found?
float g_fMaxPercCompleted[MAXPLAYERS + 1]; 						// The biggest % amount the player has reached in current map

/*----------  Advert variables  ----------*/
int g_Advert; 													// Defines which advert to play


/*----------  Maptier Variables  ----------*/
char g_sTierString[MAXZONEGROUPS][512];							// The string for each zonegroup
bool g_bTierEntryFound;											// Tier data found?
bool g_bTierFound[MAXZONEGROUPS];								// Tier data found in ZGrp
Handle AnnounceTimer[MAXPLAYERS + 1];							// Tier announce timer

/*----------  Zone Variables  ----------*/
// Client
bool g_bIgnoreZone[MAXPLAYERS + 1]; 							// Ignore end zone end touch if teleporting from inside a zone
int g_iClientInZone[MAXPLAYERS + 1][4];							// Which zone the client is in 0 = ZoneType, 1 = ZoneTypeId, 2 = ZoneGroup, 3 = ZoneID
// Zone Counts & Data
int g_mapZonesTypeCount[MAXZONEGROUPS][ZONEAMOUNT];				// Zone type count in each zoneGroup
char g_szZoneGroupName[MAXZONEGROUPS][128];						// Zone group's name
int g_mapZones[MAXZONES][MapZone];								// Map Zone array
int g_mapZonesCount;											// The total amount of zones in the map
int g_mapZoneCountinGroup[MAXZONEGROUPS];						// Map zone count in zonegroups
int g_mapZoneGroupCount;										// Zone group cound
float g_fZoneCorners[MAXZONES][8][3];							// Additional zone corners, can't store multi dimensional arrays in enums..


// Editing zones
bool g_bEditZoneType[MAXPLAYERS + 1];							// If editing zone type
char g_CurrentZoneName[MAXPLAYERS + 1][64];						// Selected zone's name
float g_Positions[MAXPLAYERS + 1][2][3];						// Selected zone's position
float g_fBonusStartPos[MAXPLAYERS + 1][2][3];					// Bonus start zone position
float g_fBonusEndPos[MAXPLAYERS + 1][2][3];						// Bonus end zone positions
float g_AvaliableScales[5] =  { 1.0, 5.0, 10.0, 50.0, 100.0 };	// Scaling options
int g_CurrentSelectedZoneGroup[MAXPLAYERS + 1];					// Currently selected zonegroup
int g_CurrentZoneTeam[MAXPLAYERS + 1];							// Current zone team TODO: Remove
int g_CurrentZoneVis[MAXPLAYERS + 1];							// Current zone visibility per team TODO: Remove
int g_CurrentZoneType[MAXPLAYERS + 1];							// Currenyly selected zone's type
int g_Editing[MAXPLAYERS + 1];									// What state of editing is happening eg. editing, creating etc.
int g_ClientSelectedZone[MAXPLAYERS + 1] =  { -1, ... };		// Currently selected zone id
int g_ClientSelectedScale[MAXPLAYERS + 1];						// Currently selected scale
int g_ClientSelectedPoint[MAXPLAYERS + 1];						// Currently selected point
int g_CurrentZoneTypeId[MAXPLAYERS + 1];						// Currently selected zone's type ID
bool g_ClientRenamingZone[MAXPLAYERS + 1];						// Is client renaming zone?
int beamColorT[] =  { 255, 0, 0, 255 };							// Zone team colors TODO: remove
int beamColorCT[] =  { 0, 0, 255, 255 };				
int beamColorN[] =  { 255, 255, 0, 255 };
int beamColorM[] =  { 0, 255, 0, 255 };
char g_szZoneDefaultNames[ZONEAMOUNT][128] =  { "Stop", "Start", "End", "Stage", "Checkpoint", "SpeedStart", "TeleToStart", "Validator", "Checker" }; // Default zone names
int g_BeamSprite;												// Zone sprites
int g_HaloSprite;

/*----------  PushFix by Mev, George & Blacky  ----------*/
/*----------  https://forums.alliedmods.net/showthread.php?t=267131  ----------*/
ConVar g_hTriggerPushFixEnable;
bool g_bPushing[MAXPLAYERS + 1];
//ConVar g_hGravityFix;

/*----------  Slope Boost Fix by Mev & Blacky  ----------*/
/*----------  https://forums.alliedmods.net/showthread.php?t=266888  ----------*/
float g_vCurrent[MAXPLAYERS + 1][3];
float g_vLast[MAXPLAYERS + 1][3];
bool g_bOnGround[MAXPLAYERS + 1];
bool g_bLastOnGround[MAXPLAYERS + 1];
bool g_bFixingRamp[MAXPLAYERS + 1];
ConVar g_hSlopeFixEnable;
//bool g_bInPushTrigger[MAXPLAYERS + 1] = false;
//bool g_bNEEDSPEED[MAXPLAYERS + 1] = false;

/*----------  Forwards  ----------*/
Handle g_MapFinishForward;
Handle g_BonusFinishForward;
Handle g_PracticeFinishForward;

/*----------  CVars  ----------*/
// Zones
int g_ZoneMenuFlag;
ConVar g_hZoneMenuFlag = null;
ConVar g_hZoneDisplayType = null; 								// How zones are displayed (lower edge, full)
ConVar g_hZonesToDisplay = null; 								// Which zones are displayed
ConVar g_hChecker; 												// Zone refresh rate
Handle g_hZoneTimer = INVALID_HANDLE;
//Zone Colors
int g_iZoneColors[ZONEAMOUNT+2][4];								// ZONE COLOR TYPES: Stop(0), Start(1), End(2), BonusStart(3), BonusEnd(4), Stage(5), 
char g_szZoneColors[ZONEAMOUNT+2][24];							// Checkpoint(6), Speed(7), TeleToStart(8), Validator(9), Chekcer(10)
ConVar g_hzoneStartColor = null;
ConVar g_hzoneEndColor = null;
ConVar g_hzoneBonusStartColor = null;
ConVar g_hzoneBonusEndColor = null;
ConVar g_hzoneStageColor = null;
ConVar g_hzoneCheckpointColor = null;
ConVar g_hzoneSpeedColor = null;
ConVar g_hzoneTeleToStartColor = null;
ConVar g_hzoneValidatorColor = null;
ConVar g_hzoneCheckerColor = null;
ConVar g_hzoneStopColor = null;
ConVar g_hAnnounceRecord;										// Announce rank type: 0 announce all, 1 announce only PB's, 3 announce only SR's
ConVar g_hCommandToEnd; 										// !end Enable / Disable
ConVar g_hWelcomeMsg = null;
ConVar g_hReplayBotPlayerModel = null;
ConVar g_hReplayBotArmModel = null; 							// Replay bot arm model
ConVar g_hPlayerModel = null; 									// Player models
ConVar g_hArmModel = null; 										// Player arm models
ConVar g_hcvarRestore = null; 									// Restore player's runs?
ConVar g_hNoClipS = null; 										// Allow noclip?
ConVar g_hReplayBot = null; 									// Replay bot?
ConVar g_hBackupReplays = null;									// Back up replay bots?
ConVar g_hReplaceReplayTime = null;								// Replace replay times, even if not SR
ConVar g_hAllowVipMute = null;									// Allow VIP's to mute?
ConVar g_hTeleToStartWhenSettingsLoaded = null;
bool g_bMapReplay; // Why two bools?
ConVar g_hBonusBot = null; 										// Bonus bot?
bool g_bMapBonusReplay[MAXZONEGROUPS];
ConVar g_hColoredNames = null; 									// Colored names in chat?
ConVar g_hPauseServerside = null; 								// Allow !pause?
ConVar g_hChallengePoints = null; 								// Allow betting points in challenges?
ConVar g_hAutoBhopConVar = null; 								// Allow autobhop?
bool g_bAutoBhop;
ConVar g_hDynamicTimelimit = null; 								// Dynamic timelimit?
ConVar g_hAdminClantag = null;									// Admin clan tag?
char g_szServerName[32];										// Server Name
ConVar g_hServerName = null;									// Server Name
ConVar g_hConnectMsg = null; 									// Connect message?
ConVar g_hDisconnectMsg = null; 								// Disconnect message?
ConVar g_hRadioCommands = null; 								// Allow radio commands?
ConVar g_hInfoBot = null; 										// Info bot?
ConVar g_hAttackSpamProtection = null; 							// Throttle shooting?
int g_AttackCounter[MAXPLAYERS + 1]; 							// Used to calculate player shots
ConVar g_hGoToServer = null; 									// Allow !gototest?
ConVar g_hAllowRoundEndCvar = null; 							// Allow round ending?
bool g_bRoundEnd; 												// Checking round end!
ConVar g_hPlayerSkinChange = null; 								// Allow changing player models?
ConVar g_hCountry = null; 										// Display countries for players?
ConVar g_hAutoRespawn = null; 									// Respawn players automatically?
ConVar g_hCvarNoBlock = null; 									// Allow player blocking?
ConVar g_hPointSystem = null; 									// Use the point system?
ConVar g_hCleanWeapons = null; 									// Clean weapons from ground?
int g_ownerOffset; 												// Used to clear weapons from ground
ConVar g_hCvarGodMode = null;									// Enable god mode?
//ConVar g_hAutoTimer = null;
ConVar g_hMapEnd = null; 										// Allow map ending?
ConVar g_hAutohealing_Hp = null; 								// Automatically heal lost HP?
ConVar g_hExtraPoints = null; 									// How many extra points for improving times?
ConVar g_hExtraPoints2 = null; 									// How many extra points for finishing a map for the first time?
// Bot Colors & effects:
ConVar g_hReplayBotColor = null; 								// Replay bot color
int g_ReplayBotColor[3];
ConVar g_hBonusBotColor = null; 								// Bonus bot color
int g_BonusBotColor[3];
//ConVar g_hBonusBotTrail = null; 								// Bonus bot trail?
//ConVar g_hRecordBotTrail = null; 								// Record bot trail?
//ConVar g_hReplayBotTrailColor = null; 							// Replay bot trail color
//int g_ReplayBotTrailColor[4];
//ConVar g_hBonusBotTrailColor = null; 							// Bonus bot trail color
//int g_BonusBotTrailColor[4];
ConVar g_hDoubleRestartCommand;									// Double !r restart
ConVar g_hStartPreSpeed = null; 								// Start zone speed cap
ConVar g_hSpeedPreSpeed = null; 								// Speed Start zone speed cap
ConVar g_hBonusPreSpeed = null; 								// Bonus start zone speed cap
ConVar g_hSoundEnabled = null; 									// Enable timer start sound
ConVar g_hSoundPath = null;										// Define start sound
//char sSoundPath[64];
ConVar g_hSpawnToStartZone = null; 								// Teleport on spawn to start zone 
ConVar g_hAnnounceRank = null; 									// Min rank to announce in chat
//ConVar g_hForceCT = null; 										// Force players CT
ConVar g_hChatSpamFilter = null; 								// Chat spam limiter
float g_fLastChatMessage[MAXPLAYERS + 1]; 						// Last message time
int g_messages[MAXPLAYERS + 1]; 								// Spam message count
ConVar g_henableChatProcessing = null; 							// Is chat processing enabled
ConVar g_hMultiServerMapcycle = null;							// Use multi server mapcycle

ConVar g_hRecordAnnounceDiscord = null;							// Web hook link to announce records to discord
ConVar g_hReportBugsDiscord = null;								// Web hook link to report bugs to discord
ConVar g_hCalladminDiscord = null;								// Web hook link to allow players to call admin to discord

ConVar g_hEstimatedStartSpeed = null;							// Used to enable server Estimated Start Speed service (needs more accuracy)

/*----------  SQL Variables  ----------*/
Handle g_hDb = null; 											// SQL driver
int g_DbType; 													// Database type
bool g_bInTransactionChain = false; 							// Used to check if SQL changes are being made
int g_failedTransactions[7]; 									// Used to track failed transactions when making database changes
bool g_bRenaming = false; 										// Used to track if sql tables are being renamed
bool g_bSettingsLoaded[MAXPLAYERS + 1]; 						// Used to track if a players settings have been loaded
bool g_bLoadingSettings[MAXPLAYERS + 1]; 						// Used to track if players settings are being loaded
bool g_bServerDataLoaded; 										// Are the servers settings loaded
char g_szRecordMapSteamID[MAX_NAME_LENGTH]; 					// SteamdID of #1 player in map, used to fetch checkpoint times
int g_iServerHibernationValue;
/*----------  User Commands  ----------*/
float g_flastClientUsp[MAXPLAYERS + 1]; 						// Throttle !usp command
float g_fLastCommandBack[MAXPLAYERS + 1];						// Throttle !back to prevent desync on record bots
bool g_insertingInformation; 									// Used to check if a admin is inserting zone or maptier information, don't allow many at the same time
bool g_bNoClip[MAXPLAYERS + 1]; 								// Client is noclipping
bool GameStartNeeded;											// Fixing bot_quota change and bot name change at GameStart (mp_restartgame or 1st bot joining AFTER a lonely player made a record)

/*----------  User Options  ----------*/
// org variables track the original setting status, on disconnect, check if changed, if so, update new settings to database
bool g_bHideChat[MAXPLAYERS + 1];								// Hides chat
bool g_borg_HideChat[MAXPLAYERS + 1];
bool g_bViewModel[MAXPLAYERS + 1]; 								// Hides viewmodel
bool g_borg_ViewModel[MAXPLAYERS + 1];
bool g_bCheckpointsEnabled[MAXPLAYERS + 1]; 					// Command to disable checkpoints
bool g_borg_CheckpointsEnabled[MAXPLAYERS + 1];
bool g_bActivateCheckpointsOnStart[MAXPLAYERS + 1]; 			// Did client enable checkpoints? Then start using them again on the next run
bool g_bEnableQuakeSounds[MAXPLAYERS + 1]; 						// Enable quake sounds?
bool g_borg_EnableQuakeSounds[MAXPLAYERS + 1];
bool g_bShowNames[MAXPLAYERS + 1]; // TODO: remove
bool g_borg_ShowNames[MAXPLAYERS + 1];
bool g_bStartWithUsp[MAXPLAYERS + 1]; // TODO: Remove
bool g_borg_StartWithUsp[MAXPLAYERS + 1];
bool g_bShowTime[MAXPLAYERS + 1]; // TODO: Remove
bool g_borg_ShowTime[MAXPLAYERS + 1];
bool g_bHide[MAXPLAYERS + 1]; 									// Hide other players?
bool g_borg_Hide[MAXPLAYERS + 1];
bool g_bShowSpecs[MAXPLAYERS + 1];								// Show spectator list?
bool g_borg_ShowSpecs[MAXPLAYERS + 1];
bool g_bGoToClient[MAXPLAYERS + 1]; 							// Allow client !gototest
bool g_borg_GoToClient[MAXPLAYERS + 1];
bool g_bAutoBhopClient[MAXPLAYERS + 1]; 						// Use auto bhop?
bool g_borg_AutoBhopClient[MAXPLAYERS + 1];
bool g_bInfoPanel[MAXPLAYERS + 1]; 								// Client is showing the info panel
bool g_borg_InfoPanel[MAXPLAYERS + 1];

/*----------  Run Variables  ----------*/
float g_fPersonalRecord[MAXPLAYERS + 1];						// Clients personal record in map
bool g_bTimeractivated[MAXPLAYERS + 1]; 						// Is clients timer running
bool g_bValidRun[MAXPLAYERS + 1];								// Used to check if a clients run is valid in validator and checker zones
bool g_bBonusFirstRecord[MAXPLAYERS + 1];						// First bonus time in map?
bool g_bBonusPBRecord[MAXPLAYERS + 1];							// Personal best time in bonus
bool g_bBonusSRVRecord[MAXPLAYERS + 1];							// New server record in bonus
char g_szBonusTimeDifference[MAXPLAYERS + 1];					// How many seconds were improved / lost in that run
float g_fStartTime[MAXPLAYERS + 1]; 							// Time when run was started
float g_fFinalTime[MAXPLAYERS + 1]; 							// Total time the run took
char g_szFinalTime[MAXPLAYERS + 1][32]; 						// Total time the run took in 00:00:00 format
float g_fPauseTime[MAXPLAYERS + 1]; 							// Time spent in !pause this run
float g_fStartPauseTime[MAXPLAYERS + 1]; 						// Time when !pause started
float g_fCurrentRunTime[MAXPLAYERS + 1]; 						// Current runtime
bool g_bMissedMapBest[MAXPLAYERS + 1]; 							// Missed personal record time?
bool g_bMapFirstRecord[MAXPLAYERS + 1];							// Was players run his first time finishing the map?
bool g_bMapPBRecord[MAXPLAYERS + 1];							// Was players run his personal best?
bool g_bMapSRVRecord[MAXPLAYERS + 1];							// Was players run the new server record?
char g_szTimeDifference[MAXPLAYERS + 1][32]; 					// Used to print the client's new times difference to record
float g_fRecordMapTime; 										// Record map time in seconds
char g_szRecordMapTime[64]; 									// Record map time in 00:00:00 format
char g_szPersonalRecord[MAXPLAYERS + 1][64]; 					// Client's peronal record in 00:00:00 format
float g_favg_maptime; 											// Average map time
float g_fAvg_BonusTime[MAXZONEGROUPS]; 							// Average bonus times TODO: Combine with g_favg_maptime
bool g_bFirstTimerStart[MAXPLAYERS + 1];						// If timer is started for the first time, print avg times
bool g_bPause[MAXPLAYERS + 1]; 									// Client has timer paused
int g_MapTimesCount; 											// How many times the map has been beaten
int g_MapRank[MAXPLAYERS + 1]; 									// Clients rank in current map
int g_OldMapRank[MAXPLAYERS + 1];								// Clients old rank
char g_szRecordPlayer[MAX_NAME_LENGTH];							// Current map's record player's name

/*----------  Replay Variables  ----------*/
bool g_bNewRecordBot; 											// Checks if the bot is new, if so, set weapon
bool g_bNewBonusBot; 											// Checks if the bot is new, if so, set weapon
Handle g_hTeleport = null; 										// Used to track teleportations
Handle g_hRecording[MAXPLAYERS + 1]; 							// Client is beign recorded
Handle g_hLoadedRecordsAdditionalTeleport = null;
Handle g_hRecordingAdditionalTeleport[MAXPLAYERS + 1];
Handle g_hBotMimicsRecord[MAXPLAYERS + 1] =  { null, ... }; 	// Is mimicing a record
Handle g_hBotTrail[2] = { null, null };							// Timer to refresh bot trails
float g_fInitialPosition[MAXPLAYERS + 1][3]; 					// Replay start position
float g_fInitialAngles[MAXPLAYERS + 1][3]; 						// Replay start angle
bool g_bValidTeleportCall[MAXPLAYERS + 1]; 						// Is teleport valid?
bool g_bNewReplay[MAXPLAYERS + 1]; 								// Don't allow starting a new run if saving a record run
bool g_bNewBonus[MAXPLAYERS + 1]; 								// Don't allow starting a new run if saving a record run
int g_BotMimicRecordTickCount[MAXPLAYERS + 1] =  { 0, ... }; 
//int g_BotActiveWeapon[MAXPLAYERS + 1] =  { -1, ... };
int g_CurrentAdditionalTeleportIndex[MAXPLAYERS + 1];
int g_RecordedTicks[MAXPLAYERS + 1];
int g_RecordPreviousWeapon[MAXPLAYERS + 1];
int g_OriginSnapshotInterval[MAXPLAYERS + 1];
bool g_createAdditionalTeleport[MAXPLAYERS+1];					// If set to true, creates additional teleport for the recording once.
int g_BotMimicTick[MAXPLAYERS + 1] =  { 0, ... };
int g_RecordBot = -1; 											// Record bot client ID
int g_BonusBot = -1; 											// Bonus bot client ID 
int g_InfoBot = -1; 											// Info bot client ID
bool g_bReplayAtEnd[MAXPLAYERS + 1]; 							// Replay is at the end
float g_fReplayRestarted[MAXPLAYERS + 1]; 						// Make replay stand still for long enough for trail to die
char g_szReplayName[128]; 										// Replay bot name
char g_szReplayTime[128]; 										// Replay bot time
char g_szBonusName[128]; 										// Replay bot name
char g_szBonusTime[128]; 										// Replay bot time
int g_BonusBotCount = 0;
int g_iCurrentBonusReplayIndex;
int g_iBonusToReplay[MAXZONEGROUPS + 1];
float g_fReplayTimes[MAXZONEGROUPS];

/*----------  Misc  ----------*/
Handle g_MapList = null; 										// Used to load the mapcycle
float g_fMapStartTime; 											// Used to check if a player just joined the server
Handle g_hSkillGroups = null;									// Array that holds SkillGroup objects in it
// Use !r twice to restart the run
float g_fErrorMessage[MAXPLAYERS + 1]; 							// Used to limit error message spam too often
float g_fClientRestarting[MAXPLAYERS + 1]; 						// Used to track the time the player took to write the second !r, if too long, reset the boolean
bool g_bClientRestarting[MAXPLAYERS + 1]; 						// Client wanted to restart run
float g_fLastTimeNoClipUsed[MAXPLAYERS + 1]; 					// Last time the client used noclip
bool g_bRespawnPosition[MAXPLAYERS + 1]; 						// Does client have a respawn location in memory?
float g_fLastSpeed[MAXPLAYERS + 1]; 							// Client's last speed, used in panels
bool g_bLateLoaded = false; 									// Was plugin loaded late?
bool g_bMapChooser; 											// Known mapchooser loaded? Used to update info bot
bool g_bClientOwnReason[MAXPLAYERS + 1]; 						// If call admin, ignore chat message
bool g_bNoClipUsed[MAXPLAYERS + 1]; 							// Has client used noclip to gain current speed
bool g_bOverlay[MAXPLAYERS + 1];								// Map finished overlay
bool g_bSpectate[MAXPLAYERS + 1]; 								// Is client spectating
bool g_bFirstTeamJoin[MAXPLAYERS + 1];							// First time client joined game, show start messages & start timers
bool g_bFirstSpawn[MAXPLAYERS + 1]; 							// First time client spawned
bool g_bSelectProfile[MAXPLAYERS + 1];
bool g_specToStage[MAXPLAYERS + 1]; 							// Is client teleporting from spectate?
float g_fTeleLocation[MAXPLAYERS + 1][3];						// Location where client is spawned from spectate
int g_ragdolls = -1; 											// Used to clear ragdolls from ground
int g_Server_Tickrate; 											// Server tickrate
int g_SpecTarget[MAXPLAYERS + 1];								// Who the client is spectating?
int g_LastButton[MAXPLAYERS + 1];								// Buttons the client is using, used to show them when specating
int g_MVPStars[MAXPLAYERS + 1]; 								// The amount of MVP's a client has  TODO: make sure this is used everywhere
int g_PlayerChatRank[MAXPLAYERS + 1]; 							// What color is client's name in chat (based on rank)
char g_pr_chat_coloredrank[MAXPLAYERS + 1][128]; 				// Clients rank, colored, used in chat
char g_pr_rankname[MAXPLAYERS + 1][32]; 						// Client's rank, non-colored, used in clantag
char g_szMapPrefix[2][32]; 										// Map's prefix, used to execute prefix cfg's
char g_szMapName[128]; 											// Current map's name
char g_szPlayerPanelText[MAXPLAYERS + 1][512];					// Info panel text when spectating
char g_szCountry[MAXPLAYERS + 1][100];							// Country codes
char g_szCountryCode[MAXPLAYERS + 1][16];						// Country codes
char g_szSteamID[MAXPLAYERS + 1][32];							// Client's steamID
char g_BlockedChatText[256][256];								// Blocked chat commands
float g_fLastOverlay[MAXPLAYERS + 1];							// Last time an overlay was displayed

// discord bugtracker
char g_sBugType[MAXPLAYERS + 1][32];
char g_sBugMsg[MAXPLAYERS + 1][256];

// Waiting for chat args
int g_iWaitingForResponse[MAXPLAYERS + 1];

/*----------  Player location restoring  ----------*/
bool g_bPositionRestored[MAXPLAYERS + 1]; 						// Clients location was restored this run
bool g_bRestorePositionMsg[MAXPLAYERS + 1]; 					// Show client restore message?
bool g_bRestorePosition[MAXPLAYERS + 1]; 						// Clients position is being restored
float g_fPlayerCordsLastPosition[MAXPLAYERS + 1][3]; 			// Client's last location, used on recovering run and coming back from spectate
float g_fPlayerLastTime[MAXPLAYERS + 1]; 						// Client's last time, used on recovering run and coming back from spec
float g_fPlayerAnglesLastPosition[MAXPLAYERS + 1][3]; 			// Client's last angles, used on recovering run and coming back from spec
float g_fPlayerCordsRestore[MAXPLAYERS + 1][3]; 				// Used in restoring players location
float g_fPlayerAnglesRestore[MAXPLAYERS + 1][3]; 				// Used in restoring players angle

/*----------  Menus  ----------*/
Menu g_menuTopSurfersMenu[MAXPLAYERS + 1] = null;
float g_fProfileMenuLastQuery[MAXPLAYERS + 1]; 					// Last time profile was queried by player, spam protection
int g_MenuLevel[MAXPLAYERS + 1];								// Tracking menu level
int g_OptionsMenuLastPage[MAXPLAYERS + 1];						// Weird options menu tricker TODO: wtf
char g_pr_szrank[MAXPLAYERS + 1][512];							// Client's rank string displayed in !profile
char g_szProfileName[MAXPLAYERS + 1][MAX_NAME_LENGTH];			// !Profile name 
char g_szProfileSteamId[MAXPLAYERS + 1][32];
// Admin
int g_AdminMenuFlag; 											// Admin flag required for !ckadmin
ConVar g_hAdminMenuFlag = null;
Handle g_hAdminMenu = null; 									// Add !ckadmin to !admin
int g_AdminMenuLastPage[MAXPLAYERS + 1]; 						// Weird admin menu trickery TODO: wtf

/*----------  Challenge variables  ----------*/ 
/**

	TODO:
	- Recode completely

 */

float g_fChallenge_RequestTime[MAXPLAYERS + 1]; 				// How long a challenge request is available
float g_fSpawnPosition[MAXPLAYERS + 1][3]; 						// Challenge start location
bool g_bChallenge_Checkpoints[MAXPLAYERS + 1]; 					// Allow checkpoints in challenge. TODO: remove
bool g_bChallenge_Abort[MAXPLAYERS + 1];						// Abort challenge
bool g_bChallenge[MAXPLAYERS + 1];
bool g_bChallenge_Request[MAXPLAYERS + 1];
int g_pr_PointUnit;
int g_Challenge_Bet[MAXPLAYERS + 1];
int g_Challenge_WinRatio[MAX_PR_PLAYERS + 1];
int g_CountdownTime[MAXPLAYERS + 1];
int g_Challenge_PointsRatio[MAX_PR_PLAYERS + 1];
char g_szChallenge_OpponentID[MAXPLAYERS + 1][32];

/*----------  Player Points  ----------*/
float g_pr_finishedmaps_perc[MAX_PR_PLAYERS + 1]; 				// % of maps the client has finished
bool g_pr_RankingRecalc_InProgress; 							// Is point recalculation in progress?
bool g_pr_Calculating[MAXPLAYERS + 1]; 							// Clients points are being calculated
bool g_bProfileRecalc[MAX_PR_PLAYERS + 1]; 						// Has this profile been recalculated?
bool g_bManualRecalc; 											// Point recalculation type
bool g_pr_showmsg[MAXPLAYERS + 1]; 								// Print the amount of gained points to chat?
bool g_bRecalcRankInProgess[MAXPLAYERS + 1]; 					// Is clients points being recalculated?
int g_pr_Recalc_ClientID = 0;									// Client ID being recalculated
int g_pr_Recalc_AdminID = -1;									// ClientID that started the recalculation
int g_pr_AllPlayers; 											// Ranked player count on server
int g_pr_RankedPlayers; 										// Player count with points
int g_pr_MapCount;												// Total map count in mapcycle
int g_pr_TableRowCount; 										// The amount of clients that get recalculated in a full recalculation
int g_pr_points[MAX_PR_PLAYERS + 1]; 							// Clients points
int g_pr_oldpoints[MAX_PR_PLAYERS + 1];							// Clients points before recalculation
int g_pr_multiplier[MAX_PR_PLAYERS + 1]; 						// How many times has the client improved on his times
int g_pr_finishedmaps[MAX_PR_PLAYERS + 1]; 						// How many maps a client has finished
int g_PlayerRank[MAXPLAYERS + 1]; 								// Players server rank
int g_MapRecordCount[MAXPLAYERS + 1];							// SR's the client has
char g_pr_szName[MAX_PR_PLAYERS + 1][64];						// Used to update client's name in database
char g_pr_szSteamID[MAX_PR_PLAYERS + 1][32];					// steamid of client being recalculated

/*----------  Practice Mode  ----------*/
float g_fCheckpointVelocity_undo[MAXPLAYERS + 1][3]; 			// Velocity at checkpoint that is on !undo
float g_fCheckpointVelocity[MAXPLAYERS + 1][3]; 				// Current checkpoints velocity
float g_fCheckpointLocation[MAXPLAYERS + 1][3]; 				// Current checkpoint location
float g_fCheckpointLocation_undo[MAXPLAYERS + 1][3]; 			// Undo checkpoints location
float g_fCheckpointAngle[MAXPLAYERS + 1][3]; 					// Current checkpoints angle
float g_fCheckpointAngle_undo[MAXPLAYERS + 1][3];				// Undo checkpoints angle
float g_fLastPlayerCheckpoint[MAXPLAYERS + 1]; 					// Don't overwrite checkpoint if spamming !cp
bool g_bCreatedTeleport[MAXPLAYERS + 1];						// Client has created atleast one checkpoint
bool g_bPracticeMode[MAXPLAYERS + 1]; 							// Client is in the practice mode


/*=========================================
=            Predefined arrays            =
=========================================*/

char EntityList[][] =  // Disable entities that often break maps
{
	"logic_timer",
	//"team_round_timer",
	//"logic_relay",
	//"trigger_momentum_timer_start",
	//"trigger_momentum_timer_stop",
};

char RadioCMDS[][] =  // Disable radio commands
{
	"coverme", "takepoint", "holdpos", "regroup", "followme", "takingfire", "go", "fallback", "sticktog", 
	"getinpos", "stormfront", "report", "roger", "enemyspot", "needbackup", "sectorclear", "inposition", 
	"reportingin", "getout", "negative", "enemydown", "cheer", "thanks", "nice", "compliment" 
};

int RGB_COLORS[][] = // Store defined RGB colors in an array
{
	RGB_GREEN, RGB_RED, RGB_DARKRED, RGB_BLUE, RGB_LIGHTBLUE, RGB_DARKBLUE, RBG_YELLOW, RGB_GREENYELLOW,
	RGB_PURPLE, RGB_MAGENTA, RGB_PINK, RGB_WHITE, RGB_CYAN, RGB_SPRINGGREEN, RGB_OLIVE, RGB_ORANGE,
	RGB_GREY, RGB_DARKGREY 
};

char RGB_COLOR_NAMES[][] =  // Store RGB color names in an array also
{
	"Green", "Red", "Darkred", "Blue", "Lightblue", "Darkblue", "Yellow", "Greenyellow", "Purple",
	"Magenta", "Pink", "White", "Cyan", "Springgreen", "Olive", "Orange", "Grey", "Darkgrey" 
};


/*=====  End of Declarations  ======*/

/*================================
=            Includes            =
================================*/

#include "ckSurf/misc_name_final_disc_2hTEST32_85_dumb.sp"
#include "ckSurf/admin.sp"
#include "ckSurf/commands_disc_rev37C.sp"
#include "ckSurf/hooks_final3_colors_disc_buy_rev743_85.sp"
#include "ckSurf/buttonpress_dumb.sp"
#include "ckSurf/sql_rev_mb4.sp"
#include "ckSurf/timer_final_revAT02_85.sp"
#include "ckSurf/replay_final5_fixed_reveCOR2_85C_dumb.sp"
#include "ckSurf/surfzones.sp"
#include "hl_goto2.sp"

/*==============================
=            Events            =
==============================*/

public void OnLibraryAdded(const char[] name)
{
	Handle tmp = FindPluginByFile("mapchooser_extended.smx");
	if ((StrEqual("mapchooser", name)) || (tmp != null && GetPluginStatus(tmp) == Plugin_Running))
		g_bMapChooser = true;
	if (tmp != null)
		CloseHandle(tmp);
	
	//botmimic 2
	if (StrEqual(name, "dhooks") && g_hTeleport == null)
	{
		// Optionally setup a hook on CBaseEntity::Teleport to keep track of sudden place changes
		Handle hGameData = LoadGameConfigFile("sdktools.games");
		if (hGameData == null)
			return;
		int iOffset = GameConfGetOffset(hGameData, "Teleport");
		CloseHandle(hGameData);
		if (iOffset == -1)
			return;
		
		g_hTeleport = DHookCreate(iOffset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, DHooks_OnTeleport);
		if (g_hTeleport == null)
			return;
		DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
		DHookAddParam(g_hTeleport, HookParamType_ObjectPtr);
		DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
		if (GetEngineVersion() == Engine_CSGO)
			DHookAddParam(g_hTeleport, HookParamType_Bool);
		
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
				OnClientPutInServer(i);
		}
	}
}

public void OnPluginEnd()
{
	//remove clan tags
	for (int x = 1; x <= MaxClients; x++)
	{
		if (IsValidClient(x))
		{
			SetEntPropEnt(x, Prop_Send, "m_bSpotted", 1);
			SetEntProp(x, Prop_Send, "m_iHideHUD", 0);
			SetEntProp(x, Prop_Send, "m_iAccount", 1);
			CS_SetClientClanTag(x, "");
			OnClientDisconnect(x);
		}
	}
	
	//set server convars back to default
	//ServerCommand("mp_respawn_on_death_ct 0;mp_respawn_on_death_t 0;mp_respawnwavetime_ct 10.0;mp_respawnwavetime_t 10.0;bot_zombie 0;mp_ignore_round_win_conditions 0;sv_infinite_ammo 0;mp_do_warmup_period 1;mp_playercashawards 1;mp_teamcashawards 1");
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "adminmenu"))
		g_hAdminMenu = null;
	if (StrEqual(name, "dhooks"))
		g_hTeleport = null;
	//if (StrEqual(name, "discord-api"))
		//SetFailState("<ckSurf> discord_api removed, you need to use the no discord version of ckSurf in this case.");
}

public void OnMapStart()
{
	WeAreOk = false;
	
	GameStartNeeded = false;
	//Will be set to true when CSRoundEnd_GameStart is fired to prevent dbl round start trigger (yes it happens, round start, round end+roundstart)
	
	// Get mapname
	GetCurrentMap(g_szMapName, 128);
	
	//get map tag
	ExplodeString(g_szMapName, "_", g_szMapPrefix, 2, 32);
	
	// Workshop fix
	char mapPieces[6][128];
	int lastPiece = ExplodeString(g_szMapName, "/", mapPieces, sizeof(mapPieces), sizeof(mapPieces[]));
	Format(g_szMapName, sizeof(g_szMapName), "%s", mapPieces[lastPiece - 1]);
	
	//if (g_bLateLoaded)
	//{
		//OnAutoConfigsBuffered();
		//WeAreOk = true;
		//No more need, it launches twice autoconfig
	//}
	
	// de_ maps spawn fix
	if(WeAreOk || (StrContains(g_szMapName, "surf_", false) != -1) || (StrContains(g_szMapName, "bhop_", false) != -1) || (StrContains(g_szMapName, "xc_", false) != -1) || (StrContains(g_szMapName, "kz_", false) != -1) || (StrContains(g_szMapName, "bkz_", false) != -1))
	{
		g_bRoundEnd = false;
		
		g_RecordBot = -1;
		g_BonusBot = -1;
		g_InfoBot = -1;
		g_BonusBotCount = 0;
		
		SetCashState();
		
		// Load spawns
		if (!g_bRenaming && !g_bInTransactionChain)
			CreateTimer(0.1, TimercheckSpawnPoints, _, TIMER_FLAG_NO_MAPCHANGE);

		if (!g_bRenaming && !g_bInTransactionChain && IsServerProcessing())
			db_selectMapZones();
		
		for (int i = 0; i < MAXZONEGROUPS; i++)
		{
			g_bTierFound[i] = false;
			g_fBonusFastest[i] = 9999999.0;
			g_bCheckpointRecordFound[i] = false;
		}
		
		//timers
		CreateTimer(0.1, CKTimer1, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
		CreateTimer(1.0, CKTimer2, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
		CreateTimer(60.0, AttackTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
		CreateTimer(600.0, PlayerRanksTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
		g_hZoneTimer = CreateTimer(GetConVarFloat(g_hChecker), BeamBoxAll, _, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
		
		g_hLoadedRecordsAdditionalTeleport = CreateTrie();
		
		//main.cfg & replays
		CreateTimer(1.0, DelayedStuff, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
		
		//AutoBhop?
		if (GetConVarBool(g_hAutoBhopConVar))
			g_bAutoBhop = true;
		else
			g_bAutoBhop = false;

		g_Advert = 0;
		CreateTimer(180.0, AdvertTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
		
		int iEnt1;
		
		//Removing some map entities (see line 712 and then)
		for (int i = 0; i < sizeof(EntityList); i++)
		{
			while ((iEnt1 = FindEntityByClassname(iEnt1, EntityList[i])) != -1)
			{
				AcceptEntityInput(iEnt1, "Disable");
				AcceptEntityInput(iEnt1, "Kill");
			}
		}
		
		// PushFix by Mev, George, & Blacky
		// https://forums.alliedmods.net/showthread.php?t=267131
		iEnt1 = -1;
		while ((iEnt1 = FindEntityByClassname(iEnt1, "trigger_push")) != -1)
		{
			SDKHook(iEnt1, SDKHook_Touch, OnTouchPushTrigger);
			//SDKHook(iEnt1, SDKHook_EndTouch, OnEndTouchPushTrigger);
		}
		
		// Trigger Gravity Fix
		//iEnt1 = -1;
		//while ((iEnt1 = FindEntityByClassname(iEnt1, "trigger_gravity")) != -1)
		//{
			//SDKHook(iEnt1, SDKHook_EndTouch, OnEndTouchGravityTrigger);
		//}
		
		//OnConfigsExecuted();

		// Set default values
		//g_insertingInformation = false;
		//g_fMapStartTime = GetGameTime();
		//g_bRoundEnd = false;
		
		//for (int i = 0; i < MAXPLAYERS+1; i++)
			//g_szUsedVoteExtend[i][0] = '\0';

		//g_VoteExtends = 0;
		
		// load configs
		loadHiddenChatCommands();
		loadCustomTitles();
		
		CheatFlag("bot_zombie", false, true);
		CheatFlag("bot_mimic", false, true);
		
		//g_BonusBotCount = 0;
		
		CreateTimer(30.0, CheckThoseLovelyBots, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
		
		WeAreOk = true;
	}

	/** Start Loading Server Settings:
	* 1. Load zones (db_selectMapZones)
	* 2. Get map record time (db_GetMapRecord_Pro)
	* 3. Get the amount of players that have finished the map (db_viewMapProRankCount)
	* 4. Get the fastest bonus times (db_viewFastestBonus)
	* 5. Get the total amount of players that have finsihed the bonus (db_viewBonusTotalCount)
	* 6. Get map tier (db_selectMapTier)
	* 7. Get record checkpoints (db_viewRecordCheckpointInMap)
	* 8. Calculate average run time (db_CalcAvgRunTime)
	* 9. Calculate averate bonus time (db_CalcAvgRunTimeBonus)
	* 10. Calculate player count (db_CalculatePlayerCount)
	* 11. Calculate player count with points (db_CalculatePlayersCountGreater0) 
	* 12. Get spawn locations (db_selectSpawnLocations)
	* 13. Clear latest records (db_ClearLatestRecords)
	* 14. Get dynamic timelimit (db_GetDynamicTimelimit)
	* -> loadAllClientSettings
	*/
	
	//sv_pure 1 could lead to problems with the ckSurf models
	//ServerCommand("sv_pure 0");
	
	//reload language files
	LoadTranslations("ckSurf.phrases");
	
	//precache
	InitPrecache();
	
	// Set default values
	g_insertingInformation = false;
	g_fMapStartTime = GetGameTime();

	for (int i = 1; i <= MaxClients; i++)
		g_szUsedVoteExtend[i][0] = '\0';
	
	g_VoteExtends = 0;
}

public Action CheckThoseLovelyBots(Handle timer)
{
	if (!WeAreOk)
		return Plugin_Stop;
	
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			if (IsFakeClient(i))
			{
				//Move InfoBot and any other accidental bot to spec
				if (i != g_BonusBot && i != g_RecordBot)
					ChangeClientTeam (i, 1);
			}
		}
	}
	return Plugin_Continue; // TIMER_FLAG_NO_MAPCHANGE so it's fine
}

public Action DelayedStuff(Handle timer)
{
	if (FileExists("cfg/sourcemod/ckSurf/main.cfg"))
		ServerCommand("exec sourcemod/ckSurf/main.cfg");
	else
		SetFailState("<ckSurf> cfg/sourcemod/ckSurf/main.cfg not found.");
		
	//LoadReplays();
	//LoadInfoBot();
	CreateTimer (3.0, LoadReplaysFullTimer, _, TIMER_FLAG_NO_MAPCHANGE);
	CreateTimer (5.0, RefreshInfoBot2, _, TIMER_FLAG_NO_MAPCHANGE);
	//return Plugin_Handled;
}

public void OnMapEnd()
{
	g_bServerDataLoaded = false;
	for (int i = 0; i < MAXZONEGROUPS; i++)
		Format(g_sTierString[i], 512, "");
	
	g_RecordBot = -1;
	g_BonusBot = -1;
	g_InfoBot = -1;
	g_BonusBotCount = 0;
	
	db_Cleanup();

	if (g_hSkillGroups != null)
		CloseHandle(g_hSkillGroups);
	g_hSkillGroups = null;

	if (g_hBotTrail[0] != null)
		CloseHandle(g_hBotTrail[0]);
	g_hBotTrail[0] = null;

	if (g_hBotTrail[1] != null)
		CloseHandle(g_hBotTrail[1]);
	g_hBotTrail[1] = null;
	
	Format(g_szMapName, sizeof(g_szMapName), "");
}

public void OnConfigsExecuted()
{
	if (!LibraryExists("discord-api"))
		SetFailState("<ckSurf> discord_api missing, you need to use the no discord version of ckSurf in this case.");
	
	// Load spawns
	//if (!g_bRenaming && !g_bInTransactionChain)
		//checkSpawnPoints();

	//if (!g_bRenaming && !g_bInTransactionChain && IsServerProcessing())
		//db_selectMapZones();
	
	//for (int i = 0; i < MAXZONEGROUPS; i++)
	//{
		//g_bTierFound[i] = false;
		//g_fBonusFastest[i] = 9999999.0;
		//g_bCheckpointRecordFound[i] = false;
	//}
	
	//timers
	//CreateTimer(0.1, CKTimer1, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	//CreateTimer(1.0, CKTimer2, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	//CreateTimer(60.0, AttackTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	//CreateTimer(600.0, PlayerRanksTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	//g_hZoneTimer = CreateTimer(GetConVarFloat(g_hChecker), BeamBoxAll, _, TIMER_REPEAT);
	
	if (WeAreOk)
	{
		if (!GetConVarBool(g_hMultiServerMapcycle))
			readMapycycle();
		else
			readMultiServerMapcycle();
	}
	
	// Count the amount of bonuses and then set skillgroups
	if (!g_bRenaming && !g_bInTransactionChain)
		db_selectBonusCount();
	
	//ServerCommand("sv_pure 0");

	//if (GetConVarBool(g_hAllowRoundEndCvar))
		//ServerCommand("mp_ignore_round_win_conditions 0");
	//else
		//ServerCommand("mp_ignore_round_win_conditions 1");

	//if (GetConVarBool(g_hAutoRespawn))
		//ServerCommand("mp_respawn_on_death_ct 1;mp_respawn_on_death_t 1;mp_respawnwavetime_ct 3.0;mp_respawnwavetime_t 3.0");
	//else
		//ServerCommand("mp_respawn_on_death_ct 0;mp_respawn_on_death_t 0");

	//ServerCommand("sv_infinite_ammo 2;mp_do_warmup_period 0;mp_warmuptime 0;mp_match_can_clinch 0;mp_match_end_changelevel 1;mp_halftime 0;bot_zombie 1;mp_do_warmup_period 0");
}


public void OnAutoConfigsBuffered()
{
	// From Berni's Map configs
	ExecuteMapSpecificConfigs();
	SetServerTags();
}

public void ExecuteMapSpecificConfigs()
{
	char currentMap[64];
	GetCurrentMap(currentMap, 64);
	
	//int arraySize2 = ByteCountToCells(PLATFORM_MAX_PATH);
	//Handle adt_configs = CreateArray(arraySize2);
	Handle adt_configs = CreateArray(PLATFORM_MAX_PATH);
	
	char cfgdir[PLATFORM_MAX_PATH];
	
	Format(cfgdir, sizeof(cfgdir), "cfg/%s", CONFIG_DIR);
	
	Handle dir = OpenDirectory(cfgdir);
	
	if (dir == INVALID_HANDLE)
	{
		LogMessage("Error iterating folder %s, folder doesn't exist !", cfgdir);
		return;
	}
	
	char configFile[PLATFORM_MAX_PATH];
	char explode[2][64];
	FileType fileType;
	
	while (ReadDirEntry(dir, configFile, sizeof(configFile), fileType))
	{
		if (fileType == FileType_File)
		{
			ExplodeString(configFile, ".", explode, 2, sizeof(explode[]));
			if (StrEqual(explode[1], "cfg", false))
			{
				if (strncmp(currentMap, explode[0], strlen(explode[0]), false) == 0)
				{
					PushArrayString(adt_configs, configFile);
				}
			}
		}
	}
	
	SortADTArray(adt_configs, Sort_Ascending, Sort_String);
	
	int size = GetArraySize(adt_configs);
	
	for (int i=0; i < size; ++i)
	{
		GetArrayString(adt_configs, i, configFile, sizeof(configFile));
		LogMessage("Executing map specific config: %s", configFile);
		ServerCommand("exec %s%s", CONFIG_DIR, configFile);
	}
	
	CloseHandle(dir);
	return;
}

public void OnClientPutInServer(int client)
{
	if (!IsValidClient(client))
		return;
	
	if (!WeAreOk)
		return;
	
	//defaults - need to check if some are for bots too, otherwise, add a condition!
	if (!IsFakeClient(client))
		SetClientDefaults(client);
	
	//g_bNEEDSPEED[client] = false;
	
	//SDKHooks
	SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	SDKHook(client, SDKHook_PostThinkPost, Hook_PostThinkPost);
	SDKHook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
	SDKHook(client, SDKHook_PreThink, OnPlayerThink);
	//SDKHook(client, SDKHook_PreThinkPost, OnPlayerThink);
	//SDKHook(client, SDKHook_Think, OnPlayerThink);
	//SDKHook(client, SDKHook_PostThink, OnPlayerThink);
	//SDKHook(client, SDKHook_PostThinkPost, OnPlayerThink);
	
	if (IsFakeClient(client))
	{
		g_hRecordingAdditionalTeleport[client] = CreateArray(view_as<int>(AdditionalTeleport));
		CS_SetMVPCount(client, 1);
		PrintToServer ("[CK] New Bot entered the game.");
		return; // Bots wont be processed further
	}
	else
		g_MVPStars[client] = 0;
	
	//client country
	GetCountry(client);
	
	if (LibraryExists("dhooks"))
		DHookEntity(g_hTeleport, false, client);
	
	//get client steamID
	GetClientAuthId(client, AuthId_Steam2, g_szSteamID[client], MAX_NAME_LENGTH, true);
	
	// ' char fix
	FixPlayerName(client);
	
	//position restoring
	if (GetConVarBool(g_hcvarRestore) && !g_bRenaming && !g_bInTransactionChain)
		db_selectLastRun(client);
	
	//console info
	PrintConsoleInfo(client);
	
	// Not for bots, done elsewhere
	if (g_bLateLoaded && IsPlayerAlive(client) && !IsFakeClient(client))
		PlayerSpawn(client);
	
	if (g_bTierFound[0])
		AnnounceTimer[client] = CreateTimer(20.0, AnnounceMap, client, TIMER_FLAG_NO_MAPCHANGE);
	
	if (!g_bRenaming && !g_bInTransactionChain && g_bServerDataLoaded && !g_bSettingsLoaded[client] && !g_bLoadingSettings[client])
	{
		/**
			Start loading client settings
			1. Load client map record (db_viewPersonalRecords)
			2. Load client rank in map (db_viewMapRankPro)
			3. Load client bonus record (db_viewPersonalBonusRecords)
			4. Load client points (db_viewPlayerPoints)
			5. Load player rank in server (db_GetPlayerRank)
			6. Load client options (db_viewPlayerOptions)
			7. Load client titles (db_viewPersonalFlags)
			8. Load client checkpoints (db_viewCheckpoints)
		*/
		g_bLoadingSettings[client] = true;
		db_viewPersonalRecords(client, g_szSteamID[client], g_szMapName);
	}
}

public void OnClientAuthorized(int client)
{
	if (GetConVarBool(g_hConnectMsg) && !IsFakeClient(client))
	{
		char s_Country[32], s_clientName[32], s_address[32];
		GetClientIP(client, s_address, 32);
		GetClientName(client, s_clientName, 32);
		Format(s_Country, 100, "Unknown");
		GeoipCountry(s_address, s_Country, 100);
		if (!strcmp(s_Country, NULL_STRING))
			Format(s_Country, 100, "Unknown", s_Country);
		else
			if (StrContains(s_Country, "United", false) != -1 || 
			StrContains(s_Country, "Republic", false) != -1 || 
			StrContains(s_Country, "Federation", false) != -1 || 
			StrContains(s_Country, "Island", false) != -1 || 
			StrContains(s_Country, "Netherlands", false) != -1 || 
			StrContains(s_Country, "Isle", false) != -1 || 
			StrContains(s_Country, "Bahamas", false) != -1 || 
			StrContains(s_Country, "Maldives", false) != -1 || 
			StrContains(s_Country, "Philippines", false) != -1 || 
			StrContains(s_Country, "Vatican", false) != -1)
		{
			Format(s_Country, 100, "The %s", s_Country);
		}
		
		if (StrEqual(s_Country, "Unknown", false) || StrEqual(s_Country, "Localhost", false))
		{
			for (int i = 1; i <= MaxClients; i++)
				if (IsValidClient(i) && i != client)
					PrintToChat(i, "%t", "Connected1", WHITE, MOSSGREEN, s_clientName, WHITE);
		}
		else
		{
			for (int i = 1; i <= MaxClients; i++)
				if (IsValidClient(i) && i != client)
					PrintToChat(i, "%t", "Connected2", WHITE, MOSSGREEN, s_clientName, WHITE, GREEN, s_Country);
		}
	}
}

public void OnClientDisconnect(int client)
{
	if (AnnounceTimer[client] != null)
	{
		KillTimer(AnnounceTimer[client]);
		AnnounceTimer[client] = null;
	}
	//in StopRecording & StopPlayerMimic
	//if (g_hRecordingAdditionalTeleport[client] != null)
	//{
		//CloseHandle(g_hRecordingAdditionalTeleport[client]);
		//g_hRecordingAdditionalTeleport[client] = null;
	//}
	//if (g_hBotMimicsRecord[client] != null)
	//{
		//CloseHandle(g_hBotMimicsRecord[client]);
		//g_hBotMimicsRecord[client] = null;
	//}
	
	g_fPlayerLastTime[client] = -1.0;
	if (!IsFakeClient(client) && g_fStartTime[client] != -1.0 && g_bTimeractivated[client])
	{
		if (g_bPause[client])
		{
			g_fPauseTime[client] = GetGameTime() - g_fStartPauseTime[client];
			g_fPlayerLastTime[client] = GetGameTime() - g_fStartTime[client] - g_fPauseTime[client];
		}
		else
			g_fPlayerLastTime[client] = g_fCurrentRunTime[client];
	}
	
	SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit);
	SDKUnhook(client, SDKHook_PostThinkPost, Hook_PostThinkPost);
	SDKUnhook(client, SDKHook_OnTakeDamage, Hook_OnTakeDamage);
	SDKUnhook(client, SDKHook_PreThink, OnPlayerThink);
	//SDKUnhook(client, SDKHook_PreThinkPost, OnPlayerThink);
	//SDKUnhook(client, SDKHook_Think, OnPlayerThink);
	//SDKUnhook(client, SDKHook_PostThink, OnPlayerThink);
	//SDKUnhook(client, SDKHook_PostThinkPost, OnPlayerThink);
	
	// Stop trail
	g_bTrailOn[client] = false;
	
	if (client == g_RecordBot)
	{
		if (g_hBotTrail[0] != null)
			CloseHandle(g_hBotTrail[0]);
		g_hBotTrail[0] = null;
		StopPlayerMimic(client);
		g_RecordBot = -1;
		return;
	}
	
	if (client == g_BonusBot)
	{
		if (g_hBotTrail[1] != null)
			CloseHandle(g_hBotTrail[1]);
		g_hBotTrail[1] = null;
		StopPlayerMimic(client);
		g_BonusBot = -1;
		return;
	}
	
	if (client == g_InfoBot)
	{
		//StopPlayerMimic(client); // This bot is never in this situation
		g_InfoBot = -1;
		return;
	}
	
	//Database	
	if (IsValidClient(client) && !g_bRenaming)
	{
		if (!IsFakeClient(client))
		{
			if (!g_bIgnoreZone[client] && !g_bPracticeMode[client])
				db_insertLastPosition(client, g_szMapName, g_Stage[g_iClientInZone[client][2]][client], g_iClientInZone[client][2]);
			
			db_updatePlayerOptions(client);
		}
	}
	
	//g_bNEEDSPEED[client] = false;
	
	// Stop recording
	if (g_hRecording[client] != null)
		StopRecording(client);
}

public void OnSettingChanged(Handle convar, const char[] oldValue, const char[] newValue)
{
	if (convar == g_hServerName)
	{
		GetConVarString(g_hServerName, g_szServerName, sizeof(g_szServerName));	
	}
	else if (convar == g_hReplayBot)
	{
		if (GetConVarBool(g_hReplayBot))
		{
			ConVar hBotQuota6 = FindConVar("bot_quota");
			ServerCommand("bot_quota %i", GetConVarInt(hBotQuota6)+1);
			CloseHandle(hBotQuota6);
			//These timers don't touch bot_quota
			CreateTimer(1.0, RefreshBot2, _, TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i))
				{
					if (IsFakeClient(i))
					{
						if (i == g_RecordBot)
						{
							//You can't kick a player like that, see https://sm.alliedmods.net/api/ at KickClient 
							//So we need a routine
							StopPlayerMimic(i);
							g_RecordBot = -1;
							//KickClient(i);
							//If bot_quota is already 0, -1 works... but then +1 won't add bots
							ConVar hBotQuota1 = FindConVar("bot_quota");
							if (GetConVarInt(hBotQuota1) > 0)
								ServerCommand("bot_quota %i", GetConVarInt(hBotQuota1)-1);
							CloseHandle(hBotQuota1);
							g_bTrailOn[i] = false;
							//Reload if we kicked wrong bot, AFTER we have set quota. -> No invalid user error when client kicked
							if (GetConVarBool(g_hBonusBot))
							{
								CreateTimer(1.6, RefreshBonusBot2, _, TIMER_FLAG_NO_MAPCHANGE);
							}
							if (GetConVarBool(g_hInfoBot))
							{
								CreateTimer(2.5, RefreshInfoBot2, _, TIMER_FLAG_NO_MAPCHANGE);
							}
						}
					}
				}
			}
		}
	}
	else if (convar == g_hBonusBot)
	{
		if (GetConVarBool(g_hBonusBot))
		{
			ConVar hBotQuota5 = FindConVar("bot_quota");
			ServerCommand("bot_quota %i", GetConVarInt(hBotQuota5)+1);
			CloseHandle(hBotQuota5);
			CreateTimer(1.0, RefreshBonusBot2, _, TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i))
				{
					if (IsFakeClient(i))
					{
						if (i == g_BonusBot)
						{
							StopPlayerMimic(i);
							g_BonusBot = -1;
							//if (g_BonusBotCount == 0)
								//g_BonusBot = -1;
							//KickClient(i);
							ConVar hBotQuota2 = FindConVar("bot_quota");
							if (GetConVarInt(hBotQuota2) > 0)
								ServerCommand("bot_quota %i", GetConVarInt(hBotQuota2)-1);
							CloseHandle(hBotQuota2);
							g_bTrailOn[i] = false;
							if (GetConVarBool(g_hReplayBot))
							{
								CreateTimer(1.6, RefreshBot2, _, TIMER_FLAG_NO_MAPCHANGE);
							}
							if (GetConVarBool(g_hInfoBot))
							{
								CreateTimer(2.5, RefreshInfoBot2, _, TIMER_FLAG_NO_MAPCHANGE);
							}
						}
					}
				}
			}
		}
	}
	else if (convar == g_hAdminClantag)
	{
		if (GetConVarBool(g_hAdminClantag))
		{
			for (int i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
					CreateTimer(0.1, SetClanTag, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			for (int i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
					CreateTimer(0.1, SetClanTag, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else if (convar == g_hAutoRespawn)
	{
		if (GetConVarBool(g_hAutoRespawn))
		{
			ServerCommand("mp_respawn_on_death_ct 1;mp_respawn_on_death_t 1;mp_respawnwavetime_ct 3.0;mp_respawnwavetime_t 3.0");
		}
		else
		{
			ServerCommand("mp_respawn_on_death_ct 0;mp_respawn_on_death_t 0");
		}
	}
	else if (convar == g_hPlayerSkinChange)
	{
		if (GetConVarBool(g_hPlayerSkinChange))
		{
			char szBuffer[256];
			for (int i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
				{
					if (i == g_RecordBot || i == g_BonusBot)
					{
						// Player Model
						GetConVarString(g_hReplayBotPlayerModel, szBuffer, 256);
						SetEntityModel(i, szBuffer);
						// Arm Model
						GetConVarString(g_hReplayBotArmModel, szBuffer, 256);
						SetEntPropString(i, Prop_Send, "m_szArmsModel", szBuffer);
						//SetEntityModel(i, szBuffer);
					}
					else
					{
						GetConVarString(g_hArmModel, szBuffer, 256);
						SetEntPropString(i, Prop_Send, "m_szArmsModel", szBuffer);

						GetConVarString(g_hPlayerModel, szBuffer, 256);
						SetEntityModel(i, szBuffer);
					}
				}
		}
	}
	else if (convar == g_hPointSystem)
	{
		if (GetConVarBool(g_hPointSystem))
		{
			for (int i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
					CreateTimer(0.1, SetClanTag, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			for (int i = 1; i <= MaxClients; i++)
				if (IsValidClient(i))
				{
					Format(g_pr_rankname[i], 128, "");
					CreateTimer(0.1, SetClanTag, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
				}
		}
	}
	else if (convar == g_hCvarNoBlock)
	{
		if (GetConVarBool(g_hCvarNoBlock))
		{
			for (int client = 1; client <= MAXPLAYERS; client++)
				if (IsValidEntity(client))
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
			
		}
		else
		{
			for (int client = 1; client <= MAXPLAYERS; client++)
				if (IsValidEntity(client))
					SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 5, 4, true);
		}
	}
	else if (convar == g_hCleanWeapons)
	{
		if (GetConVarBool(g_hCleanWeapons))
		{
			char szclass[32];
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i))
				{
					if (IsPlayerAlive(i))
					{
						for (int j = 0; j < 4; j++)
						{
							int weapon = GetPlayerWeaponSlot(i, j);
							if (weapon != -1 && j != 2)
							{
								GetEdictClassname(weapon, szclass, sizeof(szclass));
								RemovePlayerItem(i, weapon);
								RemoveEdict(weapon);
								int equipweapon = GetPlayerWeaponSlot(i, 2);
								if (equipweapon != -1)
									EquipPlayerWeapon(i, equipweapon);
							}
						}
					}
				}
			}
		}
	}
	else if (convar == g_hAutoBhopConVar)
	{
		g_bAutoBhop = view_as<bool>(StringToInt(newValue[0]));
	}
	else if (convar == g_hCountry)
	{
		if (GetConVarBool(g_hCountry))
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i))
				{
					GetCountry(i);
					if (GetConVarBool(g_hPointSystem))
						CreateTimer(0.5, SetClanTag, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
				}
			}
		}
		else
		{
			if (GetConVarBool(g_hPointSystem))
				for (int i = 1; i <= MaxClients; i++)
					if (IsValidClient(i))
						CreateTimer(0.5, SetClanTag, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	else if (convar == g_hInfoBot)
	{
		if (GetConVarBool(g_hInfoBot))
		{
			ConVar hBotQuota7 = FindConVar("bot_quota");
			ServerCommand("bot_quota %i", GetConVarInt(hBotQuota7)+1);
			CloseHandle(hBotQuota7);
			CreateTimer(1.6, RefreshInfoBot2, _, TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i))
				{
					if (IsFakeClient(i))
					{
						if (i == g_InfoBot)
						{
							g_InfoBot = -1;
							//KickClient(i);
							ConVar hBotQuota0 = FindConVar("bot_quota");
							if (GetConVarInt(hBotQuota0) > 0)
								ServerCommand("bot_quota %i", GetConVarInt(hBotQuota0)-1);
							CloseHandle(hBotQuota0);
							if (GetConVarBool(g_hReplayBot))
							{
								CreateTimer(1.6, RefreshBot2, _, TIMER_FLAG_NO_MAPCHANGE);
							}
							if (GetConVarBool(g_hBonusBot))
							{
								CreateTimer(2.5, RefreshBonusBot2, _, TIMER_FLAG_NO_MAPCHANGE);
							}
						}
					}
				}
			}
		}
	}
	else if (convar == g_hReplayBotPlayerModel)
	{
		char szBuffer[256];
		GetConVarString(g_hReplayBotPlayerModel, szBuffer, 256);
		PrecacheModel(szBuffer, true);
		AddFileToDownloadsTable(szBuffer);
		if (IsValidClient(g_RecordBot))
			SetEntityModel(g_RecordBot, szBuffer);
		if (IsValidClient(g_BonusBot))
			SetEntityModel(g_BonusBot, szBuffer);
	}
	else if (convar == g_hReplayBotArmModel)
	{
		char szBuffer[256];
		GetConVarString(g_hReplayBotArmModel, szBuffer, 256);
		PrecacheModel(szBuffer, true);
		AddFileToDownloadsTable(szBuffer);
		if (IsValidClient(g_RecordBot))
			SetEntPropString(g_RecordBot, Prop_Send, "m_szArmsModel", szBuffer);
		if (IsValidClient(g_BonusBot))
			SetEntPropString(g_RecordBot, Prop_Send, "m_szArmsModel", szBuffer);

	}
	else if (convar == g_hPlayerModel)
	{
		char szBuffer[256];
		GetConVarString(g_hPlayerModel, szBuffer, 256);

		PrecacheModel(szBuffer, true);
		AddFileToDownloadsTable(szBuffer);
		if (!GetConVarBool(g_hPlayerSkinChange))
			return;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i))
			{
				if (!IsFakeClient(i))
					SetEntityModel(i, szBuffer);
			}
		}
	}
	else if (convar == g_hArmModel)
	{
		char szBuffer[256];
		GetConVarString(g_hArmModel, szBuffer, 256);

		PrecacheModel(szBuffer, true);
		AddFileToDownloadsTable(szBuffer);
		if (!GetConVarBool(g_hPlayerSkinChange))
			return;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i))
			{
				if (!IsFakeClient(i))
				SetEntPropString(i, Prop_Send, "m_szArmsModel", szBuffer);
			}
		}
	}
	else if (convar == g_hReplayBotColor)
	{
		char color[256];
		Format(color, 256, "%s", newValue[0]);
		GetRGBColor(0, color);
	}
	else if (convar == g_hBonusBotColor)
	{
		char color[256];
		Format(color, 256, "%s", newValue[0]);
		GetRGBColor(1, color);
	}
	//else if (convar == g_hReplayBotTrailColor)
	//{
		//char color[24];
		//Format(color, 24, "%s", newValue);
		//StringRGBtoInt(color, g_ReplayBotTrailColor);
	//}
	//else if (convar == g_hBonusBotTrailColor)
	//{
		//char color[24];
		//Format(color, 24, "%s", newValue);
		//StringRGBtoInt(color, g_BonusBotTrailColor);
	//}
	else if (convar == g_hzoneStartColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[1]);
	}
	else if (convar == g_hzoneEndColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[2]);
	}
	else if (convar == g_hzoneCheckerColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[10]);
	}
	else if (convar == g_hzoneBonusStartColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[3]);
	}
	else if (convar == g_hzoneBonusEndColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[4]);
	}
	else if (convar == g_hzoneStageColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[5]);
	}
	else if (convar == g_hzoneCheckpointColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[6]);
	}
	else if (convar == g_hzoneSpeedColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[7]);
	}
	else if (convar == g_hzoneTeleToStartColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[8]);
	}
	else if (convar == g_hzoneValidatorColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[9]);
	}
	else if (convar == g_hzoneStopColor)
	{
		char color[24];
		Format(color, 28, "%s", newValue[0]);
		StringRGBtoInt(color, g_iZoneColors[0]);
	}
	//else if (convar == g_hRecordBotTrail) {
		//if (GetConVarBool(g_hRecordBotTrail) && IsValidClient(g_RecordBot) && g_hBotTrail[0] == null)
		//{
			//g_hBotTrail[0] = CreateTimer(5.0 , ReplayTrailRefresh, GetClientUserId(g_RecordBot), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		//}
		//else
		//{
			//if (g_hBotTrail[0] != null)
				//CloseHandle(g_hBotTrail[0]);
			//g_hBotTrail[0] = null;
		//}
	//}
	//else if (convar == g_hBonusBotTrail) {
		//if (GetConVarBool(g_hBonusBotTrail) && IsValidClient(g_BonusBot) && g_hBotTrail[1] == null)
		//{
			//g_hBotTrail[1] = CreateTimer(5.0 , ReplayTrailRefresh, GetClientUserId(g_BonusBot), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		//}
		//else
		//{
			//if (g_hBotTrail[1] != null)
				//CloseHandle(g_hBotTrail[1]);
			//g_hBotTrail[1] = null;
		//}
	//}
	else if (convar == g_hAutoVIPFlag) {
		AdminFlag flag;
		g_bAutoVIPFlag = FindFlagByChar(newValue[0], flag);
		g_AutoVIPFlag = FlagToBit(flag);
		if (!g_bAutoVIPFlag)
			PrintToServer("[ckSurf] Invalid flag for ck_autovip_flag");
	}
	else if (convar == g_hZoneMenuFlag) {
		AdminFlag flag;
		bool validFlag;
		validFlag = FindFlagByChar(newValue[0], flag);
		
		if (!validFlag)
		{
			PrintToServer("[ckSurf] Invalid flag for ck_zonemenu_flag");
			g_ZoneMenuFlag = ADMFLAG_ROOT;
		}
		else
			g_ZoneMenuFlag = FlagToBit(flag);
	}
	else if (convar == g_hAdminMenuFlag) {
		AdminFlag flag;
		bool validFlag;
		validFlag = FindFlagByChar(newValue[0], flag);
		
		if (!validFlag)
		{
			PrintToServer("[ckSurf] Invalid flag for ck_adminmenu_flag");
			g_AdminMenuFlag = ADMFLAG_GENERIC;
		}
		else
			g_AdminMenuFlag = FlagToBit(flag);
	}
	
	if (g_hZoneTimer != INVALID_HANDLE)
	{
		KillTimer(g_hZoneTimer);
		g_hZoneTimer = INVALID_HANDLE;
	}
	
	
	g_hZoneTimer = CreateTimer(GetConVarFloat(g_hChecker), BeamBoxAll, _, TIMER_REPEAT);
	
}

public void OnPluginStart()
{
	LoadTranslations("common.phrases");
	gcv_bPluginEnabled = CreateConVar("hl_goto_enabled", "1", "Enables and disables the goto addon", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gcv_bBotsEnabled = CreateConVar("hl_goto_allow_bots", "1", "Enables and disables the ability to use sm_goto on bots (sm_bring blocked anyway)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gcv_bIgnoreImmunity = CreateConVar("hl_goto_ignore_immunity", "0", "Enable to ignore immunity permissions with sm_goto and sm_bring", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	gcv_sFlagString = CreateConVar("hl_goto_flags", "a", "Flag for sm_goto and sm_bring commands access (default is vip)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	RegConsoleCmd("sm_goto", Command_Goto2, "Go to a player");
	RegConsoleCmd("sm_bring", Command_Bring, "Teleport a player to you");
	RegConsoleCmd("sm_telemenu", Command_TeleMenu, "Opens the Teleport Menu");
	
	g_BonusBotCount = 0;
	
	g_bServerDataLoaded = false;
	
	//Get Server Tickate
	float fltickrate = 1.0 / GetTickInterval();
	if (fltickrate > 65)
	{
		if (fltickrate < 102)
			g_Server_Tickrate = 85;
		else if (fltickrate < 128)
			g_Server_Tickrate = 102;
		else
			g_Server_Tickrate = 128;
	}
	else
		g_Server_Tickrate = 64;
	
	//language file
	LoadTranslations("ckSurf.phrases");
	
	CreateConVar("ckSurf_version", VERSION, "ckSurf Version.", FCVAR_DONTRECORD | FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY);
	
	// Discord
	
	g_hRecordAnnounceDiscord = CreateConVar("ck_announce_records_discord", "", "Web hook link to announce records to discord, keep empty to disable");
	g_hReportBugsDiscord = CreateConVar("ck_report_discord", "", "Web hook link to report bugs to discord, keep empty to disable");
	g_hCalladminDiscord = CreateConVar("ck_calladmin_discord", "", "Web hook link to allow players to call admin to discord, keep empty to disable");
	
	g_hEstimatedStartSpeed = CreateConVar("ck_estimated_startspeed", "1", "Set on 1 to enable estimated start speed display to a player starting a new run", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	g_hServerName = CreateConVar("ck_server_name", "ckSurf | Surf Plugin", "Determines the server name displayed in the timer text whilst in the start zone", FCVAR_NOTIFY);
	g_hConnectMsg = CreateConVar("ck_connect_msg", "1", "on/off - Enables a player connect message with country", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hAllowRoundEndCvar = CreateConVar("ck_round_end", "0", "on/off - Allows to end the current round (deprecated, forced off via map configs)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hDisconnectMsg = CreateConVar("ck_disconnect_msg", "1", "on/off - Enables a custom player disconnect message in chat - Deprecated, normal msg instead.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hMapEnd = CreateConVar("ck_map_end", "1", "on/off - Allows map changes after the timelimit has run out (mp_timelimit must be greater than 0)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hColoredNames = CreateConVar("ck_colored_chatnames", "0", "on/off Colors players names based on their rank in chat.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hNoClipS = CreateConVar("ck_noclip", "1", "on/off - Allows players to use noclip", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	//g_hAutoTimer = CreateConVar("ck_auto_timer", "0", "on/off - Timer automatically starts when a player joins a team, dies or uses !start/!r", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hGoToServer = CreateConVar("ck_goto", "1", "on/off - Allows players to use the !gototest command", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCommandToEnd = CreateConVar("ck_end", "1", "on/off - Allows players to use the !end command", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hCvarGodMode = CreateConVar("ck_godmode", "1", "on/off - unlimited hp", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hPauseServerside = CreateConVar("ck_pause", "1", "on/off - Allows players to use the !pause command", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hcvarRestore = CreateConVar("ck_restore", "1", "on/off - Restoring of time and last position after reconnect", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hAttackSpamProtection = CreateConVar("ck_attack_spam_protection", "1", "on/off - max 40 shots; +5 new/extra shots per minute; 1 he/flash counts like 9 shots", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hRadioCommands = CreateConVar("ck_use_radio", "0", "on/off - Allows players to use radio commands", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hAutohealing_Hp = CreateConVar("ck_autoheal", "50", "Sets HP amount for autohealing (requires ck_godmode 0)", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	g_hChallengePoints = CreateConVar("ck_challenge_points", "1", "on/off - Allows players to bet points on their challenges", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hDynamicTimelimit = CreateConVar("ck_dynamic_timelimit", "0", "on/off - Sets a suitable timelimit by calculating the average run time (This method requires ck_map_end 1, greater than 5 map times and a default timelimit in your server config for maps with less than 5 times", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hExtraPoints = CreateConVar("ck_ranking_extra_points_improvements", "15.0", "Gives players x extra points for improving their time.", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	g_hExtraPoints2 = CreateConVar("ck_ranking_extra_points_firsttime", "50.0", "Gives players x extra points for finishing a map for the first time.", FCVAR_NOTIFY, true, 0.0, true, 100.0);
	g_hWelcomeMsg = CreateConVar("ck_welcome_msg", "Welcome! This server is using {lime}ckSurf", "Welcome message (supported color tags: {default}, {darkred}, {green}, {lightgreen}, {blue} {olive}, {lime}, {red}, {purple}, {grey}, {yellow}, {lightblue}, {steelblue}, {darkblue}, {pink}, {lightred})", FCVAR_NOTIFY);
	g_hChecker = CreateConVar("ck_zone_checker", "5.0", "The duration in seconds when the beams around zones are refreshed.", FCVAR_NOTIFY);
	g_hZoneDisplayType = CreateConVar("ck_zone_drawstyle", "1", "0 = Do not display zones, 1 = display the lower edges of zones, 2 = display whole zones", FCVAR_NOTIFY);
	g_hZonesToDisplay = CreateConVar("ck_zone_drawzones", "1", "Which zones are visible for players. 1 = draw start & end zones, 2 = draw start, end, stage and bonus zones, 3 = draw all zones.", FCVAR_NOTIFY);
	g_hStartPreSpeed = CreateConVar("ck_pre_start_speed", "320.0", "The maximum prespeed for start zones. 0.0 = No cap", FCVAR_NOTIFY, true, 0.0, true, 3500.0);
	g_hSpeedPreSpeed = CreateConVar("ck_pre_speed_speed", "3000.0", "The maximum prespeed for speed start zones. 0.0 = No cap", FCVAR_NOTIFY, true, 0.0, true, 3500.0);
	g_hBonusPreSpeed = CreateConVar("ck_pre_bonus_speed", "320.0", "The maximum prespeed for bonus start zones. 0.0 = No cap", FCVAR_NOTIFY, true, 0.0, true, 3500.0);
	g_hSpawnToStartZone = CreateConVar("ck_spawn_to_start_zone", "1", "1 = Automatically spawn to the start zone when the client joins the team.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hSoundEnabled = CreateConVar("ck_startzone_sound_enabled", "1", "Enables the sound after leaving the start zone.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hSoundPath = CreateConVar("ck_startzone_sound_path", "buttons\\button3.wav", "The path to the sound file that plays after the client leaves the start zone..", FCVAR_NOTIFY);
	g_hAnnounceRank = CreateConVar("ck_min_rank_announce", "0", "Higher ranks than this won't be announced to the everyone on the server. 0 = Announce all records.", FCVAR_NOTIFY, true, 0.0);
	g_hAnnounceRecord = CreateConVar("ck_chat_record_type", "0", "0: Announce all times to chat, 1: Only announce PB's to chat, 2: Only announce SR's to chat", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	//g_hForceCT = CreateConVar("ck_force_players_ct", "0", "Forces all players to join the CT team. (Forced off, in this version)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hChatSpamFilter = CreateConVar("ck_chat_spamprotection_time", "1.0", "The frequency in seconds that players are allowed to send chat messages. 0.0 = No chat cap.", FCVAR_NOTIFY, true, 0.0);
	g_henableChatProcessing = CreateConVar("ck_chat_enable", "1", "(1 / 0) Enables or disables ckSurfs chat processing.", FCVAR_NOTIFY);
	g_hMultiServerMapcycle = CreateConVar("ck_multi_server_mapcycle", "0", "0 = Use mapcycle.txt to load servers maps, 1 = use configs/ckSurf/multi_server_mapcycle.txt to load maps", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hTriggerPushFixEnable = CreateConVar("ck_triggerpushfix_enable", "1", "Enables trigger push fix.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	//g_hGravityFix = CreateConVar("ck_gravityfix_enable", "1", "Enables trigger gravity fix", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hSlopeFixEnable = CreateConVar("ck_slopefix_enable", "1", "Enables slope fix.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hServerVipCommand = CreateConVar("ck_enable_vip", "1", "(0 / 1) Enables the !vip command. Requires a server restart.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hVoteExtendTime = CreateConVar("ck_vote_extend_time", "10.0", "The time in minutes that is added to the remaining map time if a vote extend is successful.", FCVAR_NOTIFY, true, 0.0);
	g_hMaxVoteExtends = CreateConVar("ck_max_vote_extends", "3", "The max number of VIP vote extends", FCVAR_NOTIFY, true, 0.0);
	g_hDoubleRestartCommand = CreateConVar("ck_double_restart_command", "1", "(1 / 0) Requires 2 successive !r commands to restart the player to prevent accidental usage.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hBackupReplays = CreateConVar("ck_replay_backup", "1", "(1 / 0) Back up replay files, when they are being replaced", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hReplaceReplayTime = 	CreateConVar("ck_replay_replace_faster", "1", "(1 / 0) Replace record bots if a players time is faster than the bot, even if the time is not a server record.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hAllowVipMute = CreateConVar("ck_vip_mute", "1", "(1 / 0) Allows VIP's to mute players", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	g_hTeleToStartWhenSettingsLoaded = CreateConVar("ck_teleportclientstostart", "1", "(1 / 0) Teleport players automatically back to the start zone, when their settings have been loaded.", FCVAR_NOTIFY, true, 0.0, true, 1.0);

	//g_hBonusBotTrail = CreateConVar("ck_bonus_bot_trail", "1", "(1 / 0) Enables a trail on the bonus bot.", FCVAR_NOTIFY);
	//HookConVarChange(g_hBonusBotTrail, OnSettingChanged);
	//g_hRecordBotTrail = CreateConVar("ck_record_bot_trail", "1", "(1 / 0) Enables a trail on the record bot.", FCVAR_NOTIFY);
	//HookConVarChange(g_hRecordBotTrail, OnSettingChanged);
	g_hPointSystem = CreateConVar("ck_point_system", "1", "on/off - Player point system", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hPointSystem, OnSettingChanged);
	g_hPlayerSkinChange = CreateConVar("ck_custom_models", "0", "on/off - Allows ckSurf to change the models of players and bots", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hPlayerSkinChange, OnSettingChanged);
	g_hReplayBotPlayerModel = CreateConVar("ck_replay_bot_skin", "models/player/tm_professional_var1.mdl", "Replay pro bot skin", FCVAR_NOTIFY);
	HookConVarChange(g_hReplayBotPlayerModel, OnSettingChanged);
	g_hReplayBotArmModel = CreateConVar("ck_replay_bot_arm_skin", "models/weapons/t_arms_professional.mdl", "Replay pro bot arm skin", FCVAR_NOTIFY);
	HookConVarChange(g_hReplayBotArmModel, OnSettingChanged);
	g_hPlayerModel = CreateConVar("ck_player_skin", "models/player/ctm_sas_varianta.mdl", "Player skin", FCVAR_NOTIFY);
	HookConVarChange(g_hPlayerModel, OnSettingChanged);
	g_hArmModel = CreateConVar("ck_player_arm_skin", "models/weapons/ct_arms_sas.mdl", "Player arm skin", FCVAR_NOTIFY);
	HookConVarChange(g_hArmModel, OnSettingChanged);
	g_hAutoBhopConVar = CreateConVar("ck_auto_bhop", "1", "on/off - AutoBhop on surf_ maps", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hAutoBhopConVar, OnSettingChanged);
	g_hCleanWeapons = CreateConVar("ck_clean_weapons", "1", "on/off - Removes all weapons on the ground", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hCleanWeapons, OnSettingChanged);
	g_hCountry = CreateConVar("ck_country_tag", "1", "on/off - Country clan tag", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hCountry, OnSettingChanged);
	g_hAutoRespawn = CreateConVar("ck_autorespawn", "1", "on/off - Auto respawn (deprecated, forced on via map configs)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hAutoRespawn, OnSettingChanged);
	g_hCvarNoBlock = CreateConVar("ck_noblock", "1", "on/off - Player no blocking", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hCvarNoBlock, OnSettingChanged);
	g_hAdminClantag = CreateConVar("ck_admin_clantag", "1", "on/off - Admin clan tag (necessary flag: b - z)", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hAdminClantag, OnSettingChanged);
	g_hReplayBot = CreateConVar("ck_replay_bot", "1", "on/off - Bots mimic the local map record", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hReplayBot, OnSettingChanged);
	g_hBonusBot = CreateConVar("ck_bonus_bot", "1", "on/off - Bots mimic the local bonus record", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hBonusBot, OnSettingChanged);
	g_hInfoBot = CreateConVar("ck_info_bot", "0", "on/off - provides information about nextmap and timeleft in his player name", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	HookConVarChange(g_hInfoBot, OnSettingChanged);

	g_hReplayBotColor = CreateConVar("ck_replay_bot_color", "52 91 248", "The default replay bot color - Format: \"red green blue\" from 0 - 255.", FCVAR_NOTIFY);
	HookConVarChange(g_hReplayBotColor, OnSettingChanged);
	char szRBotColor[256];
	GetConVarString(g_hReplayBotColor, szRBotColor, 256);
	GetRGBColor(0, szRBotColor);

	g_hBonusBotColor = CreateConVar("ck_bonus_bot_color", "255 255 20", "The bonus replay bot color - Format: \"red green blue\" from 0 - 255.", FCVAR_NOTIFY);
	HookConVarChange(g_hBonusBotColor, OnSettingChanged);
	szRBotColor = "";
	GetConVarString(g_hBonusBotColor, szRBotColor, 256);
	GetRGBColor(1, szRBotColor);
	
	//g_hReplayBotTrailColor = CreateConVar("ck_replay_bot_trail_color", "52 91 248", "The trail color for the replay bot - Format: \"red green blue\" from 0 - 255.", FCVAR_NOTIFY);
	//HookConVarChange(g_hReplayBotTrailColor, OnSettingChanged);
	//char szTrailColor[24];
	//GetConVarString(g_hReplayBotTrailColor, szTrailColor, 24);
	//StringRGBtoInt(szTrailColor, g_ReplayBotTrailColor);
	
	//g_hBonusBotTrailColor = CreateConVar("ck_bonus_bot_trail_color", "255 255 20", "The trail color for the bonus bot - Format: \"red green blue\" from 0 - 255.", FCVAR_NOTIFY);
	//HookConVarChange(g_hBonusBotTrailColor, OnSettingChanged);
	//szTrailColor = "";
	//GetConVarString(g_hBonusBotTrailColor, szTrailColor, 24);
	//StringRGBtoInt(szTrailColor, g_BonusBotTrailColor);

	g_hzoneStartColor = CreateConVar("ck_zone_startcolor", "000 255 000", "The color of START zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneStartColor, g_szZoneColors[1], 24);
	StringRGBtoInt(g_szZoneColors[1], g_iZoneColors[1]);
	HookConVarChange(g_hzoneStartColor, OnSettingChanged);
	
	g_hzoneEndColor = CreateConVar("ck_zone_endcolor", "255 000 000", "The color of END zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneEndColor, g_szZoneColors[2], 24);
	StringRGBtoInt(g_szZoneColors[2], g_iZoneColors[2]);
	HookConVarChange(g_hzoneEndColor, OnSettingChanged);
	
	g_hzoneCheckerColor = CreateConVar("ck_zone_checkercolor", "255 255 000", "The color of CHECKER zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneCheckerColor, g_szZoneColors[10], 24);
	StringRGBtoInt(g_szZoneColors[10], g_iZoneColors[10]);
	HookConVarChange(g_hzoneCheckerColor, OnSettingChanged);
	
	g_hzoneBonusStartColor = CreateConVar("ck_zone_bonusstartcolor", "000 255 255", "The color of BONUS START zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneBonusStartColor, g_szZoneColors[3], 24);
	StringRGBtoInt(g_szZoneColors[3], g_iZoneColors[3]);
	HookConVarChange(g_hzoneBonusStartColor, OnSettingChanged);
	
	g_hzoneBonusEndColor = CreateConVar("ck_zone_bonusendcolor", "255 000 255", "The color of BONUS END zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneBonusEndColor, g_szZoneColors[4], 24);
	StringRGBtoInt(g_szZoneColors[4], g_iZoneColors[4]);
	HookConVarChange(g_hzoneBonusEndColor, OnSettingChanged);
	
	g_hzoneStageColor = CreateConVar("ck_zone_stagecolor", "000 000 255", "The color of STAGE zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneStageColor, g_szZoneColors[5], 24);
	StringRGBtoInt(g_szZoneColors[5], g_iZoneColors[5]);
	HookConVarChange(g_hzoneStageColor, OnSettingChanged);
	
	g_hzoneCheckpointColor = CreateConVar("ck_zone_checkpointcolor", "000 000 255", "The color of CHECKPOINT zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneCheckpointColor, g_szZoneColors[6], 24);
	StringRGBtoInt(g_szZoneColors[6], g_iZoneColors[6]);
	HookConVarChange(g_hzoneCheckpointColor, OnSettingChanged);
	
	g_hzoneSpeedColor = CreateConVar("ck_zone_speedcolor", "255 000 000", "The color of SPEED zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneSpeedColor, g_szZoneColors[7], 24);
	StringRGBtoInt(g_szZoneColors[7], g_iZoneColors[7]);
	HookConVarChange(g_hzoneSpeedColor, OnSettingChanged);
	
	g_hzoneTeleToStartColor = CreateConVar("ck_zone_teletostartcolor", "255 255 000", "The color of TELETOSTART zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneTeleToStartColor, g_szZoneColors[8], 24);
	StringRGBtoInt(g_szZoneColors[8], g_iZoneColors[8]);
	HookConVarChange(g_hzoneTeleToStartColor, OnSettingChanged);
	
	g_hzoneValidatorColor = CreateConVar("ck_zone_validatorcolor", "255 255 255", "The color of VALIDATOR zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneValidatorColor, g_szZoneColors[9], 24);
	StringRGBtoInt(g_szZoneColors[9], g_iZoneColors[9]);
	HookConVarChange(g_hzoneValidatorColor, OnSettingChanged);
	
	g_hzoneStopColor = CreateConVar("ck_zone_stopcolor", "000 000 000", "The color of CHECKER zones \"red green blue\" from 0 - 255", FCVAR_NOTIFY);
	GetConVarString(g_hzoneStopColor, g_szZoneColors[0], 24);
	StringRGBtoInt(g_szZoneColors[0], g_iZoneColors[0]);
	HookConVarChange(g_hzoneStopColor, OnSettingChanged);
	
	g_hAutoVIPFlag = CreateConVar("ck_autovip_flag", "a", "Automatically give players with this admin flag the VIP title. Invalid or not set, disables auto VIP.", FCVAR_NOTIFY);
	char szFlag[24];
	AdminFlag bufferFlag;
	GetConVarString(g_hAutoVIPFlag, szFlag, 24);
	g_bAutoVIPFlag = FindFlagByChar(szFlag[0], bufferFlag);
	g_AutoVIPFlag = FlagToBit(bufferFlag);
	HookConVarChange(g_hAutoVIPFlag, OnSettingChanged);

	bool validFlag;
	g_hAdminMenuFlag = CreateConVar("ck_adminmenu_flag", "b", "Admin flag required to open the !ckadmin menu. Invalid or not set, requires flag b. Requires a server restart.", FCVAR_NOTIFY);
	GetConVarString(g_hAdminMenuFlag, szFlag, 24);
	validFlag = FindFlagByChar(szFlag[0], bufferFlag);
	if (!validFlag)
	{
		PrintToServer("[ckSurf] Invalid flag for ck_adminmenu_flag.");
		g_AdminMenuFlag = ADMFLAG_GENERIC;
	}
	else
		g_AdminMenuFlag = FlagToBit(bufferFlag);
	HookConVarChange(g_hAdminMenuFlag, OnSettingChanged);
	
	g_hZoneMenuFlag = CreateConVar("ck_zonemenu_flag", "z", "Admin flag required to open the !zones menu. Invalid or not set, requires flag z. Requires a server restart.", FCVAR_NOTIFY);
	GetConVarString(g_hZoneMenuFlag, szFlag, 24);
	validFlag = FindFlagByChar(szFlag[0], bufferFlag);
	if (!validFlag)
	{
		PrintToServer("[ckSurf] Invalid flag for ck_zonemenu_flag.");
		g_ZoneMenuFlag = ADMFLAG_ROOT;
	}
	else
		g_ZoneMenuFlag = FlagToBit(bufferFlag);
	HookConVarChange(g_hZoneMenuFlag, OnSettingChanged);
	
	GetConVarString(g_hServerName, g_szServerName, sizeof(g_szServerName));
	HookConVarChange(g_hServerName, OnSettingChanged);
	
	db_setupDatabase();

	//RegConsoleCmd("sm_rtimes", Command_rTimes, "[ckSurf] spawns a usp silencer");

	//client commands
	RegConsoleCmd("sm_usp", Client_Usp, "[ckSurf] spawns a usp silencer");
	RegConsoleCmd("sm_avg", Client_Avg, "[ckSurf] prints in chat the average time of the current map");
	RegConsoleCmd("sm_accept", Client_Accept, "[ckSurf] allows you to accept a challenge request");
	RegConsoleCmd("sm_hidechat", Client_HideChat, "[ckSurf] hides your ingame chat");
	RegConsoleCmd("sm_hideweapon", Client_HideWeapon, "[ckSurf] hides your weapon model");
	RegConsoleCmd("sm_disarm", Client_HideWeapon, "[ckSurf] hides your weapon model");
	RegConsoleCmd("sm_gototest", Client_GoTo, "[ckSurf] teleports you to a selected player");
	RegConsoleCmd("sm_sound", Client_QuakeSounds, "[ckSurf] on/off quake sounds");
	RegConsoleCmd("sm_surrender", Client_Surrender, "[ckSurf] surrender your current challenge");
	RegConsoleCmd("sm_bhop", Client_AutoBhop, "[ckSurf] on/off autobhop");
	RegConsoleCmd("sm_help2", Client_RankingSystem, "[ckSurf] Explanation of the ckSurf ranking system");
	RegConsoleCmd("sm_flashlight", Client_Flashlight, "[ckSurf] on/off flashlight");
	RegConsoleCmd("sm_maptop", Client_MapTop, "[ckSurf] displays local map top for a given map");
	RegConsoleCmd("sm_hidespecs", Client_HideSpecs, "[ckSurf] hides spectators from menu/panel");
	RegConsoleCmd("sm_compare", Client_Compare, "[ckSurf] compare your challenge results");
	RegConsoleCmd("sm_wr", Client_Wr, "[ckSurf] prints records in chat");
	RegConsoleCmd("sm_abort", Client_Abort, "[ckSurf] abort your current challenge");
	RegConsoleCmd("sm_spec", Client_Spec, "[ckSurf] chooses a player who you want to spectate and switch you to spectators");
	RegConsoleCmd("sm_watch", Client_Spec, "[ckSurf] chooses a player who you want to spectate and switch you to spectators");
	RegConsoleCmd("sm_spectate", Client_Spec, "[ckSurf] chooses a player who you want to spectate and switch you to spectators");
	RegConsoleCmd("sm_challenge", Client_Challenge, "[ckSurf] allows you to start a race against others");
	RegConsoleCmd("sm_helpmenu", Client_Help, "[ckSurf] help menu which displays all ckSurf commands");
	RegConsoleCmd("sm_help", Client_Help, "[ckSurf] help menu which displays all ckSurf commands");
	RegConsoleCmd("sm_profile", Client_Profile, "[ckSurf] opens a player profile");
	RegConsoleCmd("sm_rank", Client_Profile, "[ckSurf] opens a player profile");
	RegConsoleCmd("sm_options", Client_OptionMenu, "[ckSurf] opens options menu");
	RegConsoleCmd("sm_top", Client_Top, "[ckSurf] displays top rankings (Top 100 Players, Top 50 overall)");
	RegConsoleCmd("sm_topSurfers", Client_Top, "[ckSurf] displays top rankings (Top 100 Players, Top 50 overall)");
	RegConsoleCmd("sm_bonustop", Client_BonusTop, "[ckSurf] displays top rankings of the bonus");
	RegConsoleCmd("sm_btop", Client_BonusTop, "[ckSurf] displays top rankings of the bonus");
	RegConsoleCmd("sm_stop", Client_Stop, "[ckSurf] stops your timer");
	RegConsoleCmd("sm_ranks", Client_Ranks, "[ckSurf] prints in chat the available player ranks");
	RegConsoleCmd("sm_pause", Client_Pause, "[ckSurf] on/off pause (timer on hold and movement frozen)");
	RegConsoleCmd("sm_showsettings", Client_Showsettings, "[ckSurf] shows ckSurf server settings");
	RegConsoleCmd("sm_latest", Client_Latest, "[ckSurf] shows latest map records");
	RegConsoleCmd("sm_showtime", Client_Showtime, "[ckSurf] on/off - timer text in panel/menu");
	RegConsoleCmd("sm_hide", Client_Hide, "[ckSurf] on/off - hides other players");
	RegConsoleCmd("sm_togglecheckpoints", ToggleCheckpoints, "[ckSurf] on/off - Enable player checkpoints");
	RegConsoleCmd("+noclip", NoClip, "[ckSurf] Player noclip on");
	RegConsoleCmd("-noclip", UnNoClip, "[ckSurf] Player noclip off");
	RegConsoleCmd("sm_nc", Command_ckNoClip, "[ckSurf] Player noclip on/off");
	
	// Teleportation commands
	RegConsoleCmd("sm_stages", Command_SelectStage, "[ckSurf] Opens up the stage selector");
	RegConsoleCmd("sm_r", Command_Restart, "[ckSurf] Teleports player back to the start");
	RegConsoleCmd("sm_restart", Command_Restart, "[ckSurf] Teleports player back to the start");
	RegConsoleCmd("sm_start", Command_Restart, "[ckSurf] Teleports player back to the start");
	RegConsoleCmd("sm_b", Command_ToBonus, "[ckSurf] Teleports player back to the start");
	RegConsoleCmd("sm_bonus", Command_ToBonus, "[ckSurf] Teleports player back to the start");
	RegConsoleCmd("sm_bonuses", Command_ListBonuses, "[ckSurf] Displays a list of bonuses in current map");
	RegConsoleCmd("sm_s", Command_ToStage, "[ckSurf] Teleports player to the selected stage");
	RegConsoleCmd("sm_stage", Command_ToStage, "[ckSurf] Teleports player to the selected stage");
	RegConsoleCmd("sm_end", Command_ToEnd, "[ckSurf] Teleports player to the end zone");
	
	// Titles
	RegConsoleCmd("sm_title", Command_SetTitle, "[ckSurf] Displays player's titles");
	RegConsoleCmd("sm_titles", Command_SetTitle, "[ckSurf] Displays player's titles");
	
	if(GetConVarBool(g_hServerVipCommand))
	{
		RegConsoleCmd("sm_vip", Command_Vip, "[ckSurf] VIP's commands and effects.");
		RegConsoleCmd("sm_effects", Command_Vip, "[ckSurf] VIP's commands and effects.");
		RegConsoleCmd("sm_effect", Command_Vip, "[ckSurf] VIP's commands and effects.");
	}
	
	// MISC
	RegConsoleCmd("sm_tier", Command_Tier, "[ckSurf] Prints information on the current map");
	RegConsoleCmd("sm_maptier", Command_Tier, "[ckSurf] Prints information on the current map");
	RegConsoleCmd("sm_mapinfo", Command_Tier, "[ckSurf] Prints information on the current map");
	RegConsoleCmd("sm_mi", Command_Tier, "[ckSurf] Prints information on the current map");
	RegConsoleCmd("sm_m", Command_Tier, "[ckSurf] Prints information on the current map");
	RegConsoleCmd("sm_difficulty", Command_Tier, "[ckSurf] Prints information on the current map");
	RegConsoleCmd("sm_btier", Command_bTier, "[ckSurf] Prints tier information on current map's bonuses");
	RegConsoleCmd("sm_bonusinfo", Command_bTier, "[ckSurf] Prints tier information on current map's bonuses");
	RegConsoleCmd("sm_bi", Command_bTier, "[ckSurf] Prints tier information on current map's bonuses");
	RegConsoleCmd("sm_howto", Command_HowTo, "[ckSurf] Displays a youtube video on how to surf");
	RegConsoleCmd("sm_ve", Command_VoteExtend, "[ckSurf] Vote to extend the map");
	RegConsoleCmd("sm_vmute", Command_MutePlayer, "[ckSurf] Mute a player");


	// Teleport to the start of the stage
	RegConsoleCmd("sm_stuck", Command_Teleport, "[ckSurf] Teleports player back to the start of the stage");
	RegConsoleCmd("sm_back", Command_Teleport, "[ckSurf] Teleports player back to the start of the stage");
	RegConsoleCmd("sm_rs", Command_Teleport, "[ckSurf] Teleports player back to the start of the stage");
	RegConsoleCmd("sm_play", Command_Teleport, "[ckSurf] Teleports player back to the start");
	RegConsoleCmd("sm_spawn", Command_Teleport, "[ckSurf] Teleports player back to the start");
	
	// Player Checkpoints
	RegConsoleCmd("sm_teleport", Command_goToPlayerCheckpoint, "[ckSurf] Teleports player to his last checkpoint");
	RegConsoleCmd("sm_tele", Command_goToPlayerCheckpoint, "[ckSurf] Teleports player to his last checkpoint");
	RegConsoleCmd("sm_prac", Command_goToPlayerCheckpoint, "[ckSurf] Teleports player to his last checkpoint");
	RegConsoleCmd("sm_practice", Command_goToPlayerCheckpoint, "[ckSurf] Teleports player to his last checkpoint");
	
	RegConsoleCmd("sm_cp", Command_createPlayerCheckpoint, "[ckSurf] Creates a checkpoint, where the player can teleport back to");
	RegConsoleCmd("sm_checkpoint", Command_createPlayerCheckpoint, "[ckSurf] Creates a eckpoint, where the player can teleport back to");
	RegConsoleCmd("sm_undo", Command_undoPlayerCheckpoint, "[ckSurf] Undoes the players lchast checkpoint.");
	RegConsoleCmd("sm_normal", Command_normalMode, "[ckSurf] Switches player back to normal mode.");
	RegConsoleCmd("sm_n", Command_normalMode, "[ckSurf] Switches player back to normal mode.");
	
	RegAdminCmd("sm_ckadmin", Admin_ckPanel, g_AdminMenuFlag, "[ckSurf] Displays the ckSurf menu panel");
	RegAdminCmd("sm_refreshprofile", Admin_RefreshProfile, g_AdminMenuFlag, "[ckSurf] Recalculates player profile for given steam id");
	RegAdminCmd("sm_resetchallenges", Admin_DropChallenges, ADMFLAG_ROOT, "[ckSurf] Resets all player challenges (drops table challenges) - requires z flag");
	RegAdminCmd("sm_resettimes", Admin_DropAllMapRecords, ADMFLAG_ROOT, "[ckSurf] Resets all player times (drops table playertimes) - requires z flag");
	RegAdminCmd("sm_resetranks", Admin_DropPlayerRanks, ADMFLAG_ROOT, "[ckSurf] Resets the all player points  (drops table playerrank - requires z flag)");
	RegAdminCmd("sm_resetmaptimes", Admin_ResetMapRecords, ADMFLAG_ROOT, "[ckSurf] Resets player times for given map - requires z flag");
	RegAdminCmd("sm_resetplayerchallenges", Admin_ResetChallenges, ADMFLAG_ROOT, "[ckSurf] Resets (won) challenges for given steamid - requires z flag");
	RegAdminCmd("sm_resetplayertimes", Admin_ResetRecords, ADMFLAG_ROOT, "[ckSurf] Resets pro map times (+extrapoints) for given steamid with or without given map - requires z flag");
	RegAdminCmd("sm_resetplayermaptime", Admin_ResetMapRecord, ADMFLAG_ROOT, "[ckSurf] Resets pro map time for given steamid and map - requires z flag");
	RegAdminCmd("sm_deleteproreplay", Admin_DeleteMapReplay, ADMFLAG_ROOT, "[ckSurf] Deletes pro replay for a given map - requires z flag");
	RegAdminCmd("sm_resetextrapoints", Admin_ResetExtraPoints, ADMFLAG_ROOT, "[ckSurf] Resets given extra points for all players with or without given steamid");
	RegAdminCmd("sm_deletecheckpoints", Admin_DeleteCheckpoints, ADMFLAG_ROOT, "[ckSurf] Reset checkpoints on the current map");
	RegAdminCmd("sm_insertmaptiers", Admin_InsertMapTiers, ADMFLAG_ROOT, "[ckSurf] Insert premade maptier information into the database (ONLY RUN THIS ONCE)");
	RegAdminCmd("sm_insertmapzones", Admin_InsertMapZones, ADMFLAG_ROOT, "[ckSurf] Insert premade map zones into the database (ONLY RUN THIS ONCE)");
	RegAdminCmd("sm_zones", Command_Zones, g_ZoneMenuFlag, "[ckSurf] Opens up the zone creation menu.");
	RegAdminCmd("sm_admintitles", Admin_giveTitle, ADMFLAG_ROOT, "[ckSurf] Gives a player a title");
	RegAdminCmd("sm_admintitle", Admin_giveTitle, ADMFLAG_ROOT, "[ckSurf] Gives a player a title");
	RegAdminCmd("sm_givetitle", Admin_giveTitle, ADMFLAG_ROOT, "[ckSurf] Gives a player a title");
	RegAdminCmd("sm_removetitles", Admin_deleteTitles, ADMFLAG_ROOT, "[ckSurf] Removes player's all titles");
	RegAdminCmd("sm_removetitle", Admin_deleteTitle, ADMFLAG_ROOT, "[ckSurf] Removes specific title from a player");
	
	RegAdminCmd("sm_addmaptier", Admin_insertMapTier, g_AdminMenuFlag, "[ckSurf] Changes maps tier");
	RegAdminCmd("sm_amt", Admin_insertMapTier, g_AdminMenuFlag, "[ckSurf] Changes maps tier");
	RegAdminCmd("sm_addspawn", Admin_insertSpawnLocation, g_AdminMenuFlag, "[ckSurf] Changes the position !r takes players to");
	RegAdminCmd("sm_delspawn", Admin_deleteSpawnLocation, g_AdminMenuFlag, "[ckSurf] Removes custom !r position");
	RegAdminCmd("sm_clearassists", Admin_ClearAssists, g_AdminMenuFlag, "[ckSurf] Clears assist points (map progress) from all players");
	
	// Discord
	RegConsoleCmd("sm_bug", Command_Bug, "[ckSurf] report a bug to our discord");
	RegConsoleCmd("sm_calladmin", Command_Calladmin, "[ckSurf] sends a message to the staff");
	
	//chat command listener
	AddCommandListener(Say_Hook, "say");
	HookUserMessage(GetUserMessageId("SayText2"), SayText2, true);
	AddCommandListener(Say_Hook, "say_team");
	
	//exec ckSurf.cfg
	AutoExecConfig(true, "ckSurf");
	
	//misc
	g_ownerOffset = FindSendPropInfo("CBaseCombatWeapon", "m_hOwnerEntity");
	g_ragdolls = FindSendPropInfo("CCSPlayer", "m_hRagdoll");
	
	//add to admin menu
	Handle tpMenu;
	if (LibraryExists("adminmenu") && ((tpMenu = GetAdminTopMenu()) != null))
		OnAdminMenuReady(tpMenu);
	
	//hooks
	HookEvent("player_spawn", Event_OnPlayerSpawn, EventHookMode_Post);
	//HookEvent("player_spawn", Event_OnPlayerSpawnPRE, EventHookMode_Pre);
	HookEvent("player_death", Event_OnPlayerDeath, EventHookMode_Post);
	HookEvent("round_start", Event_OnRoundStart, EventHookMode_Post);
	HookEvent("round_end", Event_OnRoundEnd, EventHookMode_PostNoCopy);
	HookEvent("player_hurt", Event_OnPlayerHurt, EventHookMode_Pre);
	HookEvent("weapon_fire", Event_OnFire, EventHookMode_Pre);
	HookEvent("player_team", Event_OnPlayerTeam, EventHookMode_Post);
	HookEvent("round_announce_match_start", Event_OnMatchStartCS, EventHookMode_Post);
	HookEvent("round_freeze_end", Event_OnFreezeEnd, EventHookMode_Post);
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);
	
	//mapcycle array
	int arraySize = ByteCountToCells(PLATFORM_MAX_PATH);
	g_MapList = CreateArray(arraySize);
	
	//add command listeners	
	AddCommandListener(Command_JoinTeam, "jointeam");
	AddCommandListener(Command_ext_Menu, "radio1");
	AddCommandListener(Command_ext_Menu, "radio2");
	AddCommandListener(Command_ext_Menu, "radio3");
	
	//hook radio commands
	for (int g; g < sizeof(RadioCMDS); g++)
		AddCommandListener(BlockRadio, RadioCMDS[g]);
	
	//button sound hook
	//AddNormalSoundHook(NormalSHook_callback);
	
	//nav files
	CreateNavFiles();
	
	// Botmimic 2
	// https://forums.alliedmods.net/showthread.php?t=180114
	// Optionally setup a hook on CBaseEntity::Teleport to keep track of sudden place changes
	//CheatFlag("bot_zombie", false, true);
	//CheatFlag("bot_mimic", false, true);
	//g_hLoadedRecordsAdditionalTeleport = CreateTrie();
	
	Handle hGameData = LoadGameConfigFile("sdktools.games");
	if (hGameData == null)
	{
		SetFailState("GameConfigFile sdkhooks.games was not found.");
		return;
	}
	int iOffset = GameConfGetOffset(hGameData, "Teleport");
	CloseHandle(hGameData);
	if (iOffset == -1)
		return;
	
	if (LibraryExists("dhooks"))
	{
		g_hTeleport = DHookCreate(iOffset, HookType_Entity, ReturnType_Void, ThisPointer_CBaseEntity, DHooks_OnTeleport);
		if (g_hTeleport == null)
			return;
		DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
		DHookAddParam(g_hTeleport, HookParamType_ObjectPtr);
		DHookAddParam(g_hTeleport, HookParamType_VectorPtr);
		DHookAddParam(g_hTeleport, HookParamType_Bool);
	}
	
	// Forwards
	g_MapFinishForward = CreateGlobalForward("ckSurf_OnMapFinished", ET_Event, Param_Cell, Param_Float, Param_String, Param_Cell, Param_Cell);
	g_BonusFinishForward = CreateGlobalForward("ckSurf_OnBonusFinished", ET_Event, Param_Cell, Param_Float, Param_String, Param_Cell, Param_Cell, Param_Cell);
	g_PracticeFinishForward = CreateGlobalForward("ckSurf_OnPracticeFinished", ET_Event, Param_Cell, Param_Float, Param_String);
	
	if (g_bLateLoaded)
	{
		CreateTimer(3.0, LoadPlayerSettings, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
	}
	
	Format(szWHITE, 12, "%c", WHITE);
	Format(szDARKRED, 12, "%c", DARKRED);
	Format(szPURPLE, 12, "%c", PURPLE);
	Format(szGREEN, 12, "%c", GREEN);
	Format(szMOSSGREEN, 12, "%c", MOSSGREEN);
	Format(szLIMEGREEN, 12, "%c", LIMEGREEN);
	Format(szRED, 12, "%c", RED);
	Format(szGRAY, 12, "%c", GRAY);
	Format(szYELLOW, 12, "%c", YELLOW);
	Format(szDARKGREY, 12, "%c", DARKGREY);
	Format(szBLUE, 12, "%c", BLUE);
	Format(szDARKBLUE, 12, "%c", DARKBLUE);
	Format(szLIGHTBLUE, 12, "%c", LIGHTBLUE);
	Format(szPINK, 12, "%c", PINK);
	Format(szLIGHTRED, 12, "%c", LIGHTRED);
	Format(szORANGE, 12, "%c", ORANGE);
}

public Action Event_PlayerDisconnect(Handle event, const char[] name, bool dontBroadcast)
{
	if (!WeAreOk)
		return Plugin_Continue;
	
	int clientid = GetEventInt(event, "userid");
	int client = GetClientOfUserId(clientid);
	
	if (IsValidClient(client))
	{
		if (IsFakeClient(client))
		{
			//No more 'user id invalid' at player kick -> Happy (bots get released from their task properly now)
			if (client == g_InfoBot || client == g_RecordBot || client == g_BonusBot)
			{
					PrintToServer ("[CK] A CK BOT has been KICKED.");
			}
		}
	}
	return Plugin_Continue;
}

/*=====  End of Events  ======*/

/*===============================
=            Natives            =
===============================*/

public int Native_GetTimerStatus(Handle plugin, int numParams)
{
	return g_bTimeractivated[GetNativeCell(1)];
}

public int Native_StopTimer(Handle plugin, int numParams)
{
	Client_Stop(GetNativeCell(1), 0);
}

public int Native_GetCurrentTime(Handle plugin, int numParams)
{
	return view_as<int>(g_fCurrentRunTime[GetNativeCell(1)]);
}

public int Native_EmulateStartButtonPress(Handle plugin, int numParams)
{
	CL_OnStartTimerPress(GetNativeCell(1));
}

public int Native_EmulateStopButtonPress(Handle plugin, int numParams)
{
	CL_OnEndTimerPress(GetNativeCell(1));
}

public int Native_ClientIsVIP(Handle plugin, int numParams)
{
	return view_as<bool>(g_bflagTitles[GetNativeCell(1)][0]);
}

public int Native_GetServerRank(Handle plugin, int numParams)
{
	return g_PlayerRank[GetNativeCell(1)];
}

public int Native_SafeTeleport(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (IsValidClient(client))
	{
		float fDestination[3], Angle[3], Vel[3];
		GetNativeArray(2, fDestination, 3);
		GetNativeArray(3, Angle, 3);
		GetNativeArray(4, Vel, 3);

		teleportEntitySafe(client, fDestination, Angle, Vel, GetNativeCell(5));

		return true;
	}
	else
		return false;
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("ckSurf");
	CreateNative("ckSurf_GetTimerStatus", Native_GetTimerStatus);
	CreateNative("ckSurf_StopTimer", Native_StopTimer);
	CreateNative("ckSurf_EmulateStartButtonPress", Native_EmulateStartButtonPress);
	CreateNative("ckSurf_EmulateStopButtonPress", Native_EmulateStopButtonPress);
	CreateNative("ckSurf_GetCurrentTime", Native_GetCurrentTime);
	CreateNative("ckSurf_ClientIsVIP", Native_ClientIsVIP);
	CreateNative("ckSurf_GetServerRank", Native_GetServerRank);
	CreateNative("ckSurf_SafeTeleport", Native_SafeTeleport);
	g_bLateLoaded = late;
	return APLRes_Success;
}

/*=====  End of Natives  ======*/

// END //