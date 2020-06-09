public Action SayText2(UserMsg msg_id, Handle bf, int[] players, int playersNum, bool reliable, bool init)
{
	if (!reliable)return Plugin_Continue;
	char buffer[25];
	if (GetUserMessageType() == UM_Protobuf)
	{
		PbReadString(bf, "msg_name", buffer, sizeof(buffer));
		if (StrEqual(buffer, "#Cstrike_Name_Change"))
			return Plugin_Handled;
	}
	else
	{
		BfReadChar(bf);
		BfReadChar(bf);
		BfReadString(bf, buffer, sizeof(buffer));
		
		if (StrEqual(buffer, "#Cstrike_Name_Change"))
			return Plugin_Handled;
	}
	return Plugin_Continue;
}

//attack spam protection
public Action Event_OnFire(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client > 0 && IsClientInGame(client) && GetConVarBool(g_hAttackSpamProtection))
	{
		char weapon[64];
		GetEventString(event, "weapon", weapon, 64);
		if (StrContains(weapon, "knife", true) == -1 && g_AttackCounter[client] < 41)
		{
			if (g_AttackCounter[client] < 41)
			{
				g_AttackCounter[client]++;
				if (StrContains(weapon, "grenade", true) != -1 || StrContains(weapon, "flash", true) != -1)
				{
					g_AttackCounter[client] = g_AttackCounter[client] + 9;
					if (g_AttackCounter[client] > 41)
						g_AttackCounter[client] = 41;
				}
			}
		}
	}
	return Plugin_Continue;
}

// - PlayerSpawn -
public void Event_OnPlayerSpawn(Handle event, const char[] name, bool dontBroadcast)
{
	if (!WeAreOk)
		//return Plugin_Continue;
		return;
	
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if (!IsValidClient(client))
	{
		return;
	}
	
	else
	{
		if (!IsFakeClient(client))
		{
			g_SpecTarget[client] = -1;
			g_bPause[client] = false;
			g_bFirstTimerStart[client] = true;
			SetEntityMoveType(client, MOVETYPE_WALK);
			SetEntityRenderMode(client, RENDER_NORMAL);
		}
		
		//strip weapons
		if (IsValidClient(client)) // Already set!
		{
			if ((GetClientTeam(client) > 1) && !IsFakeClient(client))
			{
				StripAllWeapons(client);
				GivePlayerItem(client, "weapon_usp_silencer");
				//if (!g_bStartWithUsp[client])
				//{
					//int weapon = GetPlayerWeaponSlot(client, 2);
					//if (weapon != -1 && !IsFakeClient(client))
						//SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
				//}
			}
		}

		//NoBlock
		if (GetConVarBool(g_hCvarNoBlock) || IsFakeClient(client))
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 2, 4, true);
		else
			SetEntData(client, FindSendPropInfo("CBaseEntity", "m_CollisionGroup"), 5, 4, true);
		
		//botmimic2		
		if (g_hBotMimicsRecord[client] != null && IsFakeClient(client))
		{
			g_BotMimicTick[client] = 0;
			g_CurrentAdditionalTeleportIndex[client] = 0;
		}
		
		if (IsFakeClient(client))
		{
			if (client == g_InfoBot)
				CS_SetClientClanTag(client, "");
			else if (client == g_RecordBot)
				CS_SetClientClanTag(client, "MAP REPLAY");
			else if (client == g_BonusBot)
				CS_SetClientClanTag(client, "BONUS REPLAY");
			return;
			//Are you sure, they will not get skins, etc.
		}
		
		//SDKHook(client, SDKHook_SetTransmit, Hook_SetTransmit);
		
		//change player skin
		if (GetConVarBool(g_hPlayerSkinChange) && (GetClientTeam(client) > 1))
		{
			char szBuffer[256];
			//GetConVarString(g_hArmModel, szBuffer, 256);
			//SetEntPropString(client, Prop_Send, "m_szArmsModel", szBuffer);

			GetConVarString(g_hPlayerModel, szBuffer, 256);
			SetEntityModel(client, szBuffer);
			CreateTimer(1.0, SetArmsModel, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
		
		//1st spawn & t/ct
		if (!IsFakeClient(client) && g_bFirstSpawn[client] && (GetClientTeam(client) > 1))
		{
			float fLocation[3];
			GetClientAbsOrigin(client, fLocation);
			if (setClientLocation(client, fLocation) == -1)
			{
				g_iClientInZone[client][2] = 0;
				g_bIgnoreZone[client] = false;
			}

			StartRecording(client);
			CreateTimer(1.5, CenterMsgTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			g_bFirstSpawn[client] = false;
		}
		
		if (!IsFakeClient(client))
		{
			//get start pos for challenge
			GetClientAbsOrigin(client, g_fSpawnPosition[client]);
			
			//restore position
			if (!g_specToStage[client])
			{
				
				if ((GetClientTeam(client) > 1))
				{
					if (g_bRestorePosition[client])
					{
						g_bPositionRestored[client] = true;
						teleportEntitySafe(client, g_fPlayerCordsRestore[client], g_fPlayerAnglesRestore[client], NULL_VECTOR, false);
						g_bRestorePosition[client] = false;
					}
					else
					{
						if (g_bRespawnPosition[client])
						{
							teleportEntitySafe(client, g_fPlayerCordsRestore[client], g_fPlayerAnglesRestore[client], NULL_VECTOR, false);
							g_bRespawnPosition[client] = false;
						}
						else
						{
							g_bTimeractivated[client] = false;
							g_fStartTime[client] = -1.0;
							g_fCurrentRunTime[client] = -1.0;
							
							// Spawn client to the start zone.
							if (GetConVarBool(g_hSpawnToStartZone))
								Command_Restart(client, 1);	
						}
					}
				}
			}
			else
			{
				Array_Copy(g_fTeleLocation[client], g_fPlayerCordsRestore[client], 3);
				Array_Copy(NULL_VECTOR, g_fPlayerAnglesRestore[client], 3);
				SetEntPropVector(client, Prop_Data, "m_vecVelocity", view_as<float>( { 0.0, 0.0, -100.0 } ));
				teleportEntitySafe(client, g_fTeleLocation[client], NULL_VECTOR, view_as<float>( { 0.0, 0.0, -100.0 } ), false);
				g_specToStage[client] = false;
			}
			
			//hide radar
			CreateTimer(0.1, HideHud, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			
			//set clantag
			CreateTimer(1.5, SetClanTag, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			
			//set speclist
			Format(g_szPlayerPanelText[client], 512, "");
			
			//get speed & origin
			g_fLastSpeed[client] = GetSpeed(client);
		}
	}
	return;
	//return Plugin_Continue; // for a pre hook mode
}

public void PlayerSpawn(int client)
{	
	if (!IsValidClient(client))
		return;
}

public Action Say_Hook(int client, const char[] command, int argc)
{
	if (!WeAreOk)
		return Plugin_Continue;
	
	//Call Admin - Own Reason
	if (g_bClientOwnReason[client])
	{
		g_bClientOwnReason[client] = false;
		return Plugin_Continue;
	}
	
	char sText[1024];
	GetCmdArgString(sText, sizeof(sText));
	
	StripQuotes(sText);
	TrimString(sText);
	
	if (IsValidClient(client))
	{
		if (g_ClientRenamingZone[client])
		{
			Admin_renameZone(client, sText);
			return Plugin_Handled;
		}
	}
	
	if (!GetConVarBool(g_henableChatProcessing))
		return Plugin_Continue;
	
	if (IsValidClient(client))
	{
		if (client > 0)
			if (BaseComm_IsClientGagged(client))
			return Plugin_Handled;

		//blocked commands
		for (int i = 0; i < sizeof(g_BlockedChatText); i++)
		{
			if (StrEqual(g_BlockedChatText[i], sText, true))
			{
				
				return Plugin_Handled;
			}
		}
		
		// !s and !stage commands
		if (StrContains(sText, "!s", false) == 0 || StrContains(sText, "!stage", false) == 0)
			return Plugin_Handled;
		
		// !b and !bonus commands
		if (StrContains(sText, "!b", false) == 0 || StrContains(sText, "!bonus", false) == 0)
			return Plugin_Handled;
		
		//empty message
		if (StrEqual(sText, " ") || !sText[0])
			return Plugin_Handled;

		if (checkSpam(client))
			return Plugin_Handled;
		
		parseColorsFromString(sText, 1024);
		
		//lowercase
		if ((sText[0] == '/') || (sText[0] == '!'))
		{
			if (IsCharUpper(sText[1]))
			{
				for (int i = 0; i <= strlen(sText); ++i)
					sText[i] = CharToLower(sText[i]);
				FakeClientCommand(client, "say %s", sText);
				return Plugin_Handled;
			}
		}
		
		//chat trigger?
		if ((IsChatTrigger() && sText[0] == '/') || (sText[0] == '@' && (GetUserFlagBits(client) & ADMFLAG_ROOT || GetUserFlagBits(client) & ADMFLAG_GENERIC)))
		{
			return Plugin_Continue;
		}

		char szName[64];
		GetClientName(client, szName, 64);

		//log the chat of the player to the server so that tools such as HLSW/HLSTATX see it and also it remains logged in the log file
		WriteChatLog(client, "say", sText);
		PrintToServer("%s: %s", szName, sText);

		parseColorsFromString(szName, 64);
		
		if (GetConVarBool(g_hPointSystem) && GetConVarBool(g_hColoredNames))
			setNameColor(szName, g_PlayerChatRank[client], 64);
		
		if (GetClientTeam(client) == 1)
		{
			PrintSpecMessageAll(client);
			return Plugin_Handled;
		}
		else
		{
			char szChatRank[64];
			Format(szChatRank, 64, "%s", g_pr_chat_coloredrank[client]);
			
			if (GetConVarBool(g_hCountry) && (GetConVarBool(g_hPointSystem) || (StrEqual(g_pr_rankname[client], "ADMIN", false) && GetConVarBool(g_hAdminClantag))))
			{
				if (IsPlayerAlive(client))
					CPrintToChatAll("{green}%s{default} %s {teamcolor}%s{default}: %s", g_szCountryCode[client], szChatRank, szName, sText);
				else
					CPrintToChatAll("{green}%s{default} %s {teamcolor}*DEAD* %s{default}: %s", g_szCountryCode[client], szChatRank, szName, sText);
				return Plugin_Handled;
			}
			else
			{
				if (GetConVarBool(g_hPointSystem) || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && GetConVarBool(g_hAdminClantag)))
				{
					if (IsPlayerAlive(client))
						CPrintToChatAll("%s {teamcolor}%s{default}: %s", szChatRank, szName, sText);
					else
						CPrintToChatAll("%s {teamcolor}*DEAD* %s{default}: %s", szChatRank, szName, sText);
					return Plugin_Handled;
				}
				else
					if (GetConVarBool(g_hCountry))
				{
					if (IsPlayerAlive(client))
						CPrintToChatAll("[{green}%s{default}] {teamcolor}%s{default}: %s", g_szCountryCode[client], szName, sText);
					else
						CPrintToChatAll("[{green}%s{default}] {teamcolor}*DEAD* %s{default}: %s", g_szCountryCode[client], szName, sText);
					return Plugin_Handled;
				}
			}
		}
	}
	return Plugin_Continue;
}

public void Event_OnPlayerTeam(Handle event, const char[] name, bool dontBroadcast)
{
	if (!WeAreOk)
		return;
		//return Plugin_Continue;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!IsValidClient(client))
		return;
	//Letting this for bot too?
	if (IsFakeClient(client))
		return;
	
	int team = GetEventInt(event, "team");
	
	//Trying to check if bot here, and kick it to fix surf_summer double bot, but it may spam console
	//if (IsFakeClient(client) && (GameStartNeeded))
	//{
		//KickClient(client);
		//return Plugin_Continue;
		//return;
	//}
	
	if (team == 1)
	{	
		SpecListMenuDead(client);
		if (!g_bFirstSpawn[client])
		{
			GetClientAbsOrigin(client, g_fPlayerCordsRestore[client]);
			GetClientEyeAngles(client, g_fPlayerAnglesRestore[client]);
			g_bRespawnPosition[client] = true;
		}
		if (g_bTimeractivated[client])
		{
			g_fStartPauseTime[client] = GetGameTime();
			if (g_fPauseTime[client] > 0.0)
				g_fStartPauseTime[client] = g_fStartPauseTime[client] - g_fPauseTime[client];
		}
		g_bSpectate[client] = true;
		g_bPause[client] = false;
	}
	//Second fix for another cp plugin
	else if (team == 2 || team == 3)
		FakeClientCommandEx(client, "sm_clear");
	//return Plugin_Continue;
	return;
}

//public Action Event_OnPlayerConnectBot(Handle event, const char[] name, bool dontBroadcast)
//{
	//if (!WeAreOk)
		//return Plugin_Continue;
	//int clientid = GetEventInt(event, "userid");
	//int client = GetClientOfUserId(clientid);
	//if (client)
	//{
		//if (IsFakeClient(client) && (GameStartNeeded))
		//{
			//KickClient(client);
			//return Plugin_Handled;
		//}
	//}
	//return Plugin_Continue;
//}

//No need to do that and make another loop just to send a msg.
//public Action Event_PlayerDisconnect(Handle event, const char[] name, bool dontBroadcast)
//{
	//if (!WeAreOk)
		//return Plugin_Continue;
	//if (GetConVarBool(g_hDisconnectMsg))
	//{
		//char szName[64];
		//char disconnectReason[64];
		//int clientid = GetEventInt(event, "userid");
		//int client = GetClientOfUserId(clientid);
		//if (!IsValidClient(client) || IsFakeClient(client))
			//return Plugin_Continue;
		//GetEventString(event, "name", szName, sizeof(szName));
		//GetEventString(event, "reason", disconnectReason, sizeof(disconnectReason));
		//for (int i = 1; i <= MaxClients; i++)
			//if (IsValidClient(i) && i != client && !IsFakeClient(i))
				//PrintToChat(i, "%t", "Disconnected1", WHITE, MOSSGREEN, szName, WHITE, disconnectReason);
		//SetEventBroadcast(event, true); // block server's normal msg, true means disabled
		//return Plugin_Continue;
	//}
	//else
	//{
		//SetEventBroadcast(event, true); // let the server display its usual msg
		//return Plugin_Continue;
	//}
//}

public Action Hook_SetTransmit(int entity, int client)
{
	if (!WeAreOk)
		return Plugin_Continue;
	
	if (IsValidClient(client))
	{
		if (client != entity && (0 < entity <= MaxClients))
		{
			if (g_bChallenge[client] && !g_bHide[client])
			{
				if (!StrEqual(g_szSteamID[entity], g_szChallenge_OpponentID[client], false))
					return Plugin_Handled;
			}		  
			if (g_bHide[client] && entity != g_SpecTarget[client])
				return Plugin_Handled;
			if (entity == g_InfoBot && entity != g_SpecTarget[client])
				return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public void Event_OnPlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	if (!WeAreOk)
		return;
		
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (IsValidClient(client))
	{
		//SDKUnhook(client, SDKHook_SetTransmit, Hook_SetTransmit);
		if (!IsFakeClient(client))
		{
			if (g_hRecording[client] != null)
				StopRecording(client);
			CreateTimer(2.0, RemoveRagdoll, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
		}
		else
			if (g_hBotMimicsRecord[client] != null)
			{
				g_BotMimicTick[client] = 0;
				g_CurrentAdditionalTeleportIndex[client] = 0;
				if (GetClientTeam(client) >= CS_TEAM_T && client != g_InfoBot)
					CreateTimer(1.0, RespawnBot, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
			}
	}
	//return Plugin_Continue;
	return;
}

//public Action Event_OnPlayerSpawnPRE(Handle event, const char[] name, bool dontBroadcast)
//{
	//if (WeAreOk)
	//{
		//int client = GetClientOfUserId(GetEventInt(event, "userid"));
		//if (IsValidClient(client))
		//{
			//if (IsFakeClient(client))
			//{
				//if (!(client != g_InfoBot))
				//{
					//PrintToServer("[CK] Nice, This Info Bot keeps respawning, please move it to spec.");
					//For testing purpose, I don't move it to spec my self or handle it.
					//return Plugin_Handled;
				//}
			//}
		//}
	//}
	//return Plugin_Continue;
//}

//Seems to crash server at 1st bot join if server only had 1 player (game commencing). And on mp_restartgame use.
//Beware that plugin now uses maps configs with mp_ignore_round_win_conditions.
//See Event_OnRoundStart/Event_OnMatchStartCS for more details.
public Action CS_OnTerminateRound(float &delay, CSRoundEndReason &reason)
{
	PrintToServer("[CK] CS_OnTerminateRound fired");
	if (WeAreOk)
	{
		if (reason == CSRoundEnd_GameStart)
		{
			//ServerCommand("bot_kick");
			//ServerCommand("bot_quota 0");
			//CreateTimer(5.0, DelayedStuff2, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
			GameStartNeeded = false;
			g_bRoundEnd = false;
			return Plugin_Handled; // Or Changed, handled is risky
		}
		else
		{
			PrintToServer("[CK] Not due to CS_OTR reason, so we don't block it.");
			GameStartNeeded = true;
			g_bRoundEnd = true;
			//ServerCommand("bot_kick");
			return Plugin_Changed;
		}
	}
	else
	{
		PrintToServer("[CK] NOT a SURF, BHOP or KZ map, so we let it go.");
		//ServerCommand("bot_kick");
		return Plugin_Changed;
	}
	//int timeleft;
	//GetMapTimeLeft(timeleft);
	//if (WeAreOk && timeleft >= -1 && !GetConVarBool(g_hAllowRoundEndCvar))
		//return Plugin_Handled;
	//return Plugin_Continue;
}

public void Event_OnRoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
	PrintToServer("[CK] ROUND END fired");
	if (WeAreOk)
	{
		if (!g_bRoundEnd)
		{
			g_bRoundEnd = true;
		}
		if (!GameStartNeeded)
		{
			GameStartNeeded = true;
		}
		//On surf_summer, bot tries to spawn at every event, and mess up quota.
		//ServerCommand("bot_kick");
		//ServerCommand("bot_quota 0");
		//CreateTimer(1.0, DelayedStuff2, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
		//LoadReplays();
		//LoadInfoBot();
	
		//for (int i = 1; i <= MaxClients; i++)
		//{
			//if(IsValidClient(i))
			//{
				//if(!IsFakeClient(i))
				//{
					//Client_Stop(i, 0);
					//SDKUnhook(i, SDKHook_StartTouch, StartTouchTrigger);
					//SDKUnhook(i, SDKHook_EndTouch, EndTouchTrigger);
				//}
			//}
		//}
	}
	//return;
}

public void OnPlayerThink(int entity)
{
	SetEntPropEnt(entity, Prop_Send, "m_bSpotted", 0);
}

// OnRoundRestart
// Note that many operations lag alot. Refreshing zones is enough.
public void Event_OnRoundStart(Handle event, const char[] name, bool dontBroadcast)
{
	//We somehow reached roundstart, maybe with mp_restartgame command... that you should not use on a surf server
	PrintToServer("[CK] ROUND START fired");
	
	if (!WeAreOk)
		return;
		
	//g_bRoundEnd = false;
	//if (!GameStartNeeded)
	//{
		//GameStartNeeded = true;
	//}
	
	
	//At FreezeEnd (triggered only once unlike round_start)
	//GameStartNeeded = true;
	//LoadReplays();
	//LoadInfoBot();
	//ServerCommand("bot_kick");
	//ServerCommand("bot_quota 0");
	
	//Renewing these hotfixes on round start in this version. Focusing on cktimer 1 & 2.
	int iEnt;
	iEnt = -1;
	//Still need this for many maps
	for (int i = 0; i < sizeof(EntityList); i++)
	{
		while ((iEnt = FindEntityByClassname(iEnt, EntityList[i])) != -1)
		{
			AcceptEntityInput(iEnt, "Disable");
			AcceptEntityInput(iEnt, "Kill");
		}
	}
	
	// PushFix by Mev, George, & Blacky
	// https://forums.alliedmods.net/showthread.php?t=267131
	iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "trigger_push")) != -1)
	{
		SDKHook(iEnt, SDKHook_Touch, OnTouchPushTrigger);
		//SDKHook(iEnt, SDKHook_EndTouch, OnEndTouchPushTrigger);
	}
	
	//Trigger Gravity Fix
	//iEnt = -1;
	//while ((iEnt = FindEntityByClassname(iEnt, "trigger_gravity")) != -1)
	//{
		//SDKHook(iEnt, SDKHook_EndTouch, OnEndTouchGravityTrigger);
	//}
	
	//db_viewMapSettings();
	// Teleport Destinations (goose)
	//iEnt = -1;
	//g_hDestinations = CreateArray(128);
	//while ((iEnt = FindEntityByClassname(iEnt, "info_teleport_destination")) != -1)
		//PushArrayCell(g_hDestinations, iEnt);
	
	//return Plugin_Continue;
	
	//for (int i = 1; i <= MaxClients; i++)
	//{
		//if (IsValidClient(i))
		//{
			//if (!IsFakeClient(i))
			//{
				//g_Stage[g_iClientInZone[i][2]][i] = 1;
				//lastCheckpoint[g_iClientInZone[i][2]][i] = 1;
				//Client_Stop(i, 0);
				//SDKUnhook(i, SDKHook_StartTouch, StartTouchTrigger);
				//SDKUnhook(i, SDKHook_EndTouch, EndTouchTrigger);
				//teleportClient(i, 0, 1, true);
			//}
		//}
	//}
	
	RefreshZones();
	
	return;
}

public void Event_OnFreezeEnd(Handle event, const char[] name, bool dontBroadcast)
{
	//Important: Triggered even with freezetime 0
	//Let's kick all?
	PrintToServer("[CK] FREEZETIME UP");
	
	if (!WeAreOk)
	{
		return;
	}
	
	g_bRoundEnd = false;
	
	if (!GameStartNeeded)
	{
		return;
	}
	
	//Now even with a scd map start, no dbl load
	GameStartNeeded = false;
	
	PrintToServer("[CK] This time, Bots will be reloaded");
	
	//Fixing Bot quota changed by server, because new bot changes his name at that point when it's for a game_start reason
	//This happens at mp_restartgame or at 1st replay on a map, done by a player alone. Even if bot joins same team.
	//I didn't want to remove mp_restartgame command so, I am doing it this way. EDIT: it's a map problem.
	//ServerCommand("bot_quota 0");
	//ServerCommand("bot_kick");
	//LoadReplays();
	//LoadInfoBot();
	
	//if (!g_bRenaming && !g_bInTransactionChain)
	//{
		//CreateTimer(0.1, TimercheckSpawnPoints, _, TIMER_FLAG_NO_MAPCHANGE);
	//}

	//if (!g_bRenaming && !g_bInTransactionChain && IsServerProcessing())
	//{
		//db_selectMapZones();
	//}
	
	//ClearTrie(g_hLoadedRecordsAdditionalTeleport);
	
	//CheatFlag("bot_zombie", false, true);
	//CheatFlag("bot_mimic", false, true);
	
	//for (int i = 1; i <= MaxClients; i++)
	//{
		//if (IsClientInGame(i))
		//{
			//Client_Stop(i, 0);
			//SDKHook(i, SDKHook_StartTouch, StartTouchTrigger);
			//SDKHook(i, SDKHook_EndTouch, EndTouchTrigger);
			//teleportClient(client, 0, 1, true);
		//}
	//}
	
	//I managed to stop CKTimer1 and CKTimer2 and reload them this way, but it's worse. Sometimes, just let the plugin go.
	//CreateTimer(0.2, CKTimer1, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	//CreateTimer(1.0, CKTimer2, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE | TIMER_REPEAT);
	CreateTimer(5.0, DelayedStuff2, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
	
	//return Plugin_Continue;
	return;
}

//Trying to block surf_summer double restart on mp_restartgame
public void Event_OnMatchStartCS(Handle event, const char[] name, bool dontBroadcast)
{
	PrintToServer("[CK] MATCH StArT fired");
}

public Action DelayedStuff2(Handle timer)
{
	//ServerCommand("bot_quota 0");
	//ServerCommand("bot_kick");
	//GameStartNeeded = false;
	//g_bRoundEnd = false;
	//RefreshZones();
	CreateTimer (5.0, LoadReplaysFullTimer, _, TIMER_FLAG_NO_MAPCHANGE);
	//CreateTimer (5.5, LoadInfoBotFullTimer, _, TIMER_FLAG_NO_MAPCHANGE);
	PrintToServer("[CK] All Bots will be reloaded in 5 secs. Surf_summer might spawn an invisible bot, but no crash.");
}

public Action LoadReplaysFullTimer(Handle timer)
{
	//setBotQuota();
	LoadReplays();
	//LoadInfoBot();
	//PrintToServer("[CK] Bots successfully reloaded.");
}

//Maybe readd InfoBot too? or he might be messed up at map restart
//public Action LoadInfoBotFullTimer(Handle timer)
//{
	//LoadInfoBot();
//}

//public Action OnTouchAllTriggers(int entity, int other)
//{
	//if (other >= 1 && other <= MaxClients && IsFakeClient(other))
		//return Plugin_Handled;
	//return Plugin_Continue;
//}

//public Action OnEndTouchAllTriggers(int entity, int other)
//{
	//if (other >= 1 && other <= MaxClients && IsFakeClient(other))
		//return Plugin_Handled;
	//return Plugin_Continue;
//}

// I'm not blocking any bot touch trigger in this version, or am I
// PushFix by Mev, George, & Blacky
// https://forums.alliedmods.net/showthread.php?t=267131
public Action OnTouchPushTrigger(int entity, int other)
{
	if (!WeAreOk)
		return Plugin_Continue;
	
	//if (IsFakeClient(other))
		//return Plugin_Handled;
	//
	if (IsValidClient(other))
	{
		if(GetConVarBool(g_hTriggerPushFixEnable) == true)
		{
			//Takes a new additional teleport to increase acuraccy for bot recordings.
			//Check for bots here too?
			if (g_hRecording[other] != null && !IsFakeClient(other))
			{
				g_createAdditionalTeleport[other] = true;
			}
			
			//For reference only, not using this duck+push fix though
			//g_bInPushTrigger[other] = true;
			
			if (IsValidEntity(entity))
			{
				float m_vecPushDir[3];
				GetEntPropVector(entity, Prop_Data, "m_vecPushDir", m_vecPushDir);
				if (m_vecPushDir[2] == 0.0)
					return Plugin_Continue;
				else
					DoPush(entity, other, m_vecPushDir);
			}
			return Plugin_Handled;
		}
	}
	
	return Plugin_Continue;
}

//public Action OnEndTouchPushTrigger(int entity, int other)
//{
	//if (IsValidClient(other) && GetConVarBool(g_hTriggerPushFixEnable) == true)
	//{
		//if (IsFakeClient(other))
			//return Plugin_Handled;
		//
		//if (IsValidEntity(entity))
		//{
			//g_bInPushTrigger[other] = false;
		//}
		//return Plugin_Handled;
	//}
	//return Plugin_Continue;
//}

//public Action OnEndTouchGravityTrigger(int entity, int other)
//{
	//if (IsValidClient(other) && !IsFakeClient(other))
	//{
		//if (!g_bNoClip[other] && GetConVarBool(g_hGravityFix))
			//return Plugin_Handled;
	//}
	//return Plugin_Continue;
//}

// PlayerHurt 
public Action Event_OnPlayerHurt(Handle event, const char[] name, bool dontBroadcast)
{
	if (!WeAreOk)
		return Plugin_Continue;
	if (!GetConVarBool(g_hCvarGodMode) && GetConVarInt(g_hAutohealing_Hp) > 0)
	{
		int client = GetClientOfUserId(GetEventInt(event, "userid"));
		int remainingHeatlh = GetEventInt(event, "health");
		if (remainingHeatlh > 0)
		{
			if ((remainingHeatlh + GetConVarInt(g_hAutohealing_Hp)) > 100)
				SetEntData(client, FindSendPropInfo("CBasePlayer", "m_iHealth"), 100);
			else
				SetEntData(client, FindSendPropInfo("CBasePlayer", "m_iHealth"), remainingHeatlh + GetConVarInt(g_hAutohealing_Hp));
		}
	}
	return Plugin_Continue;
}

// PlayerDamage (if godmode 0)
public Action Hook_OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (!WeAreOk)
		return Plugin_Continue;
	if (GetConVarBool(g_hCvarGodMode))
	{
		return Plugin_Handled;
	}
	return Plugin_Continue;
}


//thx to TnTSCS (player slap stops timer)
//https://forums.alliedmods.net/showthread.php?t=233966
public Action OnLogAction(Handle source, Identity ident, int client, int target, const char[] message)
{
	if (!WeAreOk)
		return Plugin_Continue;
	if ((1 > target > MaxClients))
		return Plugin_Continue;
	if (IsValidClient(target))
	{
		if (IsPlayerAlive(target) && g_bTimeractivated[target] && !IsFakeClient(target))
		{
			char logtag[PLATFORM_MAX_PATH];
			if (ident == Identity_Plugin)
				GetPluginFilename(source, logtag, sizeof(logtag));
			else
				Format(logtag, sizeof(logtag), "OTHER");
			
			if ((strcmp("playercommands.smx", logtag, false) == 0) || (strcmp("slap.smx", logtag, false) == 0))
				Client_Stop(target, 0);
		}
	}
	return Plugin_Continue;
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if (!WeAreOk || !IsValidClient(client))
		return Plugin_Continue;
	
	if (g_bRoundEnd)
		return Plugin_Continue;
	
	if (IsPlayerAlive(client))
	{
		g_bLastOnGround[client] = g_bOnGround[client];
		if (GetEntityFlags(client) & FL_ONGROUND)
			g_bOnGround[client] = true;
		else
			g_bOnGround[client] = false;

		float newVelocity[3];
		// Slope Boost Fix by Mev, & Blacky
		// https://forums.alliedmods.net/showthread.php?t=266888
		//if (GetConVarBool(g_hSlopeFixEnable) == true)
		if (GetConVarBool(g_hSlopeFixEnable) == true && !IsFakeClient(client))
		{			
			g_vLast[client][0] = g_vCurrent[client][0];
			g_vLast[client][1] = g_vCurrent[client][1];
			g_vLast[client][2] = g_vCurrent[client][2];
			g_vCurrent[client][0] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[0]");
			g_vCurrent[client][1] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[1]");
			g_vCurrent[client][2] = GetEntPropFloat(client, Prop_Send, "m_vecVelocity[2]");
			
			// Check if player landed on the ground
			if (g_bOnGround[client] == true && g_bLastOnGround[client] == false)
			{
				// Set up and do tracehull to find out if the player landed on a slope
				float vPos[3];
				GetEntPropVector(client, Prop_Data, "m_vecOrigin", vPos);
				
				float vMins[3];
				GetEntPropVector(client, Prop_Send, "m_vecMins", vMins);
				
				float vMaxs[3];
				GetEntPropVector(client, Prop_Send, "m_vecMaxs", vMaxs);
				
				float vEndPos[3];
				vEndPos[0] = vPos[0];
				vEndPos[1] = vPos[1];
				vEndPos[2] = vPos[2] - FindConVar("sv_maxvelocity").FloatValue;
				
				TR_TraceHullFilter(vPos, vEndPos, vMins, vMaxs, MASK_PLAYERSOLID_BRUSHONLY, TraceRayDontHitSelf, client);
				
				if (TR_DidHit())
				{
					// Gets the normal vector of the surface under the player
					float vPlane[3], vLast[3];
					TR_GetPlaneNormal(INVALID_HANDLE, vPlane);
					
					// Make sure it's not flat ground and not a surf ramp (1.0 = flat ground, < 0.7 = surf ramp)
					if (0.7 <= vPlane[2] < 1.0)
					{
						/*
						Copy the ClipVelocity function from sdk2013 
						(https://mxr.alliedmods.net/hl2sdk-sdk2013/source/game/shared/gamemovement.cpp#3145)
						With some minor changes to make it actually work
						*/
						vLast[0] = g_vLast[client][0];
						vLast[1] = g_vLast[client][1];
						vLast[2] = g_vLast[client][2];
						vLast[2] -= (FindConVar("sv_gravity").FloatValue * GetTickInterval() * 0.5);
						
						float fBackOff = GetVectorDotProduct(vLast, vPlane);
						
						float change, vVel[3];
						for (int i; i < 2; i++)
						{
							change = vPlane[i] * fBackOff;
							vVel[i] = vLast[i] - change;
						}
						
						float fAdjust = GetVectorDotProduct(vVel, vPlane);
						if (fAdjust < 0.0)
						{
							for (int i; i < 2; i++)
							{
								vVel[i] -= (vPlane[i] * fAdjust);
							}
						}
						
						vVel[2] = 0.0;
						vLast[2] = 0.0;
						
						// Make sure the player is going down a ramp by checking if they actually will gain speed from the boost
						if (GetVectorLength(vVel) > GetVectorLength(vLast))
						{
							// Teleport the player, also adds basevelocity
							if (GetEntityFlags(client) & FL_BASEVELOCITY)
							{
								float vBase[3];
								GetEntPropVector(client, Prop_Data, "m_vecBaseVelocity", vBase);
								
								AddVectors(vVel, vBase, vVel);
							}
							g_bFixingRamp[client] = true;
							Array_Copy(vVel, newVelocity, 3);
							TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel);
						}
					}
				}
			}
		}

		if (newVelocity[0] == 0.0 && newVelocity[1] == 0.0 && newVelocity[2] == 0.0)
		{
			if (!IsFakeClient(client))
				RecordReplay(client, buttons, subtype, seed, impulse, weapon, angles, vel);
			else
				if (client == g_RecordBot || client == g_BonusBot)
					PlayReplay(client, buttons, subtype, seed, impulse, weapon, angles, vel);
		}
		else
		{
			if (!IsFakeClient(client))
				RecordReplay(client, buttons, subtype, seed, impulse, weapon, angles, newVelocity);
			else
				if (client == g_RecordBot || client == g_BonusBot)
					PlayReplay(client, buttons, subtype, seed, impulse, weapon, angles, newVelocity);
		}

		float speed, origin[3], ang[3];
		GetClientAbsOrigin(client, origin);
		GetClientEyeAngles(client, ang);
		
		speed = GetSpeed(client);
		
		checkTrailStatus(client, speed);
		
		//menu refreshing
		CheckRun(client);
		
		AutoBhopFunction(client, buttons);
		NoClipCheck(client);
		AttackProtection(client, buttons);
		
		// If in start zone, cap speed
		LimitSpeed(client);
		
		g_fLastSpeed[client] = speed;
		g_LastButton[client] = buttons;
		
		BeamBox_OnPlayerRunCmd(client);
	}
	return Plugin_Continue;
}

//dhooks
public MRESReturn DHooks_OnTeleport(int client, Handle hParams)
{

	if (!IsValidClient(client))
		return MRES_Ignored;

	if (g_bPushing[client])
	{
		g_bPushing[client] = false;
		return MRES_Ignored;
	}

	if (g_bFixingRamp[client])
	{
		g_bFixingRamp[client] = false;
		return MRES_Ignored;
	}


	// This one is currently mimicing something.
	if (g_hBotMimicsRecord[client] != null)
	{
		// We didn't allow that teleporting. STOP THAT.
		if (!g_bValidTeleportCall[client])
			return MRES_Supercede;
		g_bValidTeleportCall[client] = false;
		return MRES_Ignored;
	}
	
	// Don't care if he's not recording.
	if (g_hRecording[client] == null)
		return MRES_Ignored;

	bool bOriginNull = DHookIsNullParam(hParams, 1);
	bool bAnglesNull = DHookIsNullParam(hParams, 2);
	bool bVelocityNull = DHookIsNullParam(hParams, 3);
	
	float origin[3], angles[3], velocity[3];
	
	if (!bOriginNull)
		DHookGetParamVector(hParams, 1, origin);
	
	if (!bAnglesNull)
	{
		for (int i = 0; i < 3; i++)
			angles[i] = DHookGetParamObjectPtrVar(hParams, 2, i * 4, ObjectValueType_Float);
	}
	
	if (!bVelocityNull)
		DHookGetParamVector(hParams, 3, velocity);
	
	if (bOriginNull && bAnglesNull && bVelocityNull)
		return MRES_Ignored;
	
	int iAT[AT_SIZE];
	Array_Copy(origin, iAT[atOrigin], 3);
	Array_Copy(angles, iAT[atAngles], 3);
	Array_Copy(velocity, iAT[atVelocity], 3);
	
	// Remember, 
	if (!bOriginNull)
		iAT[atFlags] |= ADDITIONAL_FIELD_TELEPORTED_ORIGIN;
	if (!bAnglesNull)
		iAT[atFlags] |= ADDITIONAL_FIELD_TELEPORTED_ANGLES;
	if (!bVelocityNull)
		iAT[atFlags] |= ADDITIONAL_FIELD_TELEPORTED_VELOCITY;
		
	if (g_hRecordingAdditionalTeleport[client] != null)
		PushArrayArray(g_hRecordingAdditionalTeleport[client], iAT, AT_SIZE);
	
	return MRES_Ignored;
}

public void Hook_PostThinkPost(int entity)
{
	if (WeAreOk)
	{
		SetEntProp(entity, Prop_Send, "m_bInBuyZone", 0);
	}
}

//Avoiding server crash on mp_restartgame
//I will need to look through arguments, but we will also need to block say_hook etc.
//public Action Command_GameRestart(int client, const char[] command, int argc)
//{
	//PrintToChat(client, "Command blocked when ckSurf timer is on. Please reload the map instead"); 
	//return Plugin_Handled;
//}

////Sry for all the comments////
//End//