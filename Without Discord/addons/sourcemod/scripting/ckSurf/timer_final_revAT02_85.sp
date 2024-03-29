//public Action ReplayTrailRefresh(Handle timer, int userid)
//{
	//int client = GetClientOfUserId(userid);
	//if (client == 0)
	//{
		//CloseHandle(g_hBotTrail[0]);
		//g_hBotTrail[0] = null;
		//return Plugin_Stop;
	//}
	//if (!IsValidClient(client))
	//{
		//CloseHandle(g_hBotTrail[0]);
		//g_hBotTrail[0] = null;
		//return Plugin_Stop;
	//}
	//
	//if (g_bReplayAtEnd[client])
		//return Plugin_Stop;
	//
	//if (client == g_BonusBot)
	//{
		//if (GetConVarBool(g_hBonusBotTrail))
			//refreshTrailBot(client);
		//else
		//{
			//CloseHandle(g_hBotTrail[1]);
			//g_hBotTrail[1] = null;
		//}
	//}
	//else if (client == g_RecordBot)
	//{
		//if (GetConVarBool(g_hRecordBotTrail))
			//refreshTrailBot(client);
		//else
		//{
			//CloseHandle(g_hBotTrail[0]);
			//g_hBotTrail[0] = null;
		//}
	//}
	//return Plugin_Continue;
//}

public Action reloadRank(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0)
	{
		return Plugin_Stop;
	}
	if (IsValidClient(client))
		SetPlayerRank(client);
	return Plugin_Handled;
}

public Action reloadConsoleInfo(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0)
	{
		return Plugin_Stop;
	}	
	if (IsValidClient(client))
		PrintConsoleInfo(client);
	return Plugin_Handled;
}


public Action AnnounceMap(Handle timer, any client)
{
	if (IsValidClient(client))
	{
		PrintToChat(client, g_sTierString[0]);
	}
	
	AnnounceTimer[client] = null;
	//return Plugin_Handled;
}

public Action RefreshAdminMenu(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0)
	{
		return Plugin_Stop;
	}
	if (IsValidEntity(client) && !IsFakeClient(client))
		ckAdminMenu(client);
	return Plugin_Handled;
}

public Action RefreshVIPMenu(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0)
	{
		return Plugin_Stop;
	}
	if (IsValidEntity(client) && !IsFakeClient(client) && !IsVoteInProgress())
		Command_Vip(client, 1);
	return Plugin_Handled;
}

public Action RefreshZoneSettings(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0)
	{
		return Plugin_Stop;
	}
	if (IsValidEntity(client) && !IsFakeClient(client))
		ZoneSettings(client);
	return Plugin_Handled;
}

//public Action SetPlayerWeapons(Handle timer, any client)
//{
	//if ((GetClientTeam(client) > 1) && IsValidClient(client))
	//{
		//StripAllWeapons(client);
		//if (!IsFakeClient(client))
			//GivePlayerItem(client, "weapon_usp_silencer");
		//if (!g_bStartWithUsp[client])
		//{
			//int weapon;
			//weapon = GetPlayerWeaponSlot(client, 2);
			//if (weapon != -1 && !IsFakeClient(client))
				//SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
		//}
	//}
	//return Plugin_Handled;
//}

public Action SetArmsModel(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0)
	{
		return Plugin_Stop;
	}
	if (IsValidClient(client))
	{
		if  (IsPlayerAlive(client))
		{
			char szBuffer[256];
			GetConVarString(g_hArmModel, szBuffer, 256);
			SetEntPropString(client, Prop_Send, "m_szArmsModel", szBuffer);
		}
	}
	return Plugin_Handled;
}

public Action PlayerRanksTimer(Handle timer)
{
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))
			continue;
		if (IsFakeClient(i))
			continue;
		db_GetPlayerRank(i);
	}
	return Plugin_Continue;
}

//
// Recounts players time
//
public Action UpdatePlayerProfile(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0)
	{
		return Plugin_Stop;
	}
	if (IsValidClient(client))
		 if (!IsFakeClient(client))
			db_updateStat(client);
	return Plugin_Handled;
}

public Action StartTimer(Handle timer, any client)
{
	if (IsValidClient(client))
		 if (!IsFakeClient(client))
			CL_OnStartTimerPress(client);
	
	return Plugin_Handled;
}

public Action AttackTimer(Handle timer)
{
	if (!WeAreOk)
	{
		return Plugin_Continue;
	}
	for (int i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))
			continue;
		if (IsFakeClient(i))
			continue;
		
		if (g_AttackCounter[i] > 0)
		{
			if (g_AttackCounter[i] < 5)
				g_AttackCounter[i] = 0;
			else
				g_AttackCounter[i] = g_AttackCounter[i] - 5;
		}
	}
	return Plugin_Continue;
}

public Action CKTimer1(Handle timer)
{
	if (!WeAreOk)
		return Plugin_Stop;
	
	//if (g_bRoundEnd)
		//return Plugin_Continue; // Don't wanna stop this
	
	int client;
	for (client = 1; client <= MaxClients; client++)
	{
		if (IsValidClient(client))
		{
			if (!IsFakeClient(client) && IsPlayerAlive(client))
			{
				//1st team join + in-game
				if (g_bFirstTeamJoin[client])
				{
					g_bFirstTeamJoin[client] = false;
					CreateTimer(1.0, StartMsgTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(10.0, WelcomeMsgTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
					CreateTimer(70.0, HelpMsgTimer, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
				}
				GetcurrentRunTime(client);
				CenterHudAlive(client);
				MovementCheck(client);
			}
			else
				if (!IsFakeClient(client) && !IsPlayerAlive(client))
					CenterHudDead(client);
		}
	}
	return Plugin_Continue;
}

public Action CKTimer2(Handle timer)
{
	if (!WeAreOk)
		return Plugin_Stop;
		
	if (g_bRoundEnd)
		return Plugin_Continue;
	
	if (GetConVarBool(g_hMapEnd))
	{
		Handle hTmp;
		hTmp = FindConVar("mp_timelimit");
		int iTimeLimit;
		iTimeLimit = GetConVarInt(hTmp);
		if (hTmp != null)
			CloseHandle(hTmp);
		if (iTimeLimit > 0)
		{
			int timeleft;
			GetMapTimeLeft(timeleft);
			switch (timeleft)
			{
				case 1800:PrintToChatAll("%t", "TimeleftMinutes", LIGHTRED, WHITE, timeleft / 60);
				case 1200:PrintToChatAll("%t", "TimeleftMinutes", LIGHTRED, WHITE, timeleft / 60);
				case 600:PrintToChatAll("%t", "TimeleftMinutes", LIGHTRED, WHITE, timeleft / 60);
				case 300:PrintToChatAll("%t", "TimeleftMinutes", LIGHTRED, WHITE, timeleft / 60);
				case 120:PrintToChatAll("%t", "TimeleftMinutes", LIGHTRED, WHITE, timeleft / 60);
				case 60:PrintToChatAll("%t", "TimeleftSeconds", LIGHTRED, WHITE, timeleft);
				case 30:PrintToChatAll("%t", "TimeleftSeconds", LIGHTRED, WHITE, timeleft);
				case 15:PrintToChatAll("%t", "TimeleftSeconds", LIGHTRED, WHITE, timeleft);
				case  - 1:PrintToChatAll("%t", "TimeleftCounter", LIGHTRED, WHITE, 3);
				case  - 2:PrintToChatAll("%t", "TimeleftCounter", LIGHTRED, WHITE, 2);
				case  - 3:
				{
					if (!g_bRoundEnd)
					{
						g_bRoundEnd = true;
						ServerCommand("mp_ignore_round_win_conditions 0");
						PrintToChatAll("%t", "TimeleftCounter", LIGHTRED, WHITE, 1);
						CreateTimer(3.0, TerminateRoundTimer, INVALID_HANDLE, TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		}
	}
	
	//info bot name
	if (g_InfoBot != -1)
		SetInfoBotName(g_InfoBot);
	
	//clean weapons on ground
	int maxEntities;
	maxEntities = GetMaxEntities();
	char classx[20];
	if (GetConVarBool(g_hCleanWeapons))
	{
		int j;
		for (j = MaxClients + 1; j < maxEntities; j++)
		{
			if (IsValidEdict(j) && (GetEntDataEnt2(j, g_ownerOffset) == -1))
			{
				GetEdictClassname(j, classx, sizeof(classx));
				if ((StrContains(classx, "weapon_") != -1) || (StrContains(classx, "item_") != -1))
				{
					AcceptEntityInput(j, "Kill");
				}
			}
		}
	}
	
	int i;
	for (i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))
			continue;
		
		//overlay check
		if (!IsFakeClient(i) && g_bOverlay[i] && GetGameTime() - g_fLastOverlay[i] > 5.0)
			g_bOverlay[i] = false;
		
		//stop replay to prevent server crashes because of a massive recording array (max. 2h)
		if (g_hRecording[i] != null && g_fCurrentRunTime[i] > 6720.0)
		{
			StopRecording(i);
		}
		
		//Scoreboard			
		if (!g_bPause[i])
		{
			float fltime;
			fltime = GetGameTime() - g_fStartTime[i] - g_fPauseTime[i] + 1.0;
			if (IsPlayerAlive(i) && g_bTimeractivated[i])
			{
				int time;
				time = RoundToZero(fltime);
				Client_SetScore(i, time);
			}
			else
			{
				Client_SetScore(i, 0);
			}
			if (!IsFakeClient(i) && !g_pr_Calculating[i])
				CreateTimer(0.3, SetClanTag, GetClientUserId(i), TIMER_FLAG_NO_MAPCHANGE);
		}
		
		if (!IsFakeClient(i) && IsPlayerAlive(i))
		{
			//spec hud
			SpecListMenuAlive(i);
			
			//challenge check
			if (g_bChallenge_Request[i])
			{
				float time;
				time = GetGameTime() - g_fChallenge_RequestTime[i];
				if (time > 20.0)
				{
					PrintToChat(i, "%t", "ChallengeRequestExpired", RED, WHITE, YELLOW);
					g_bChallenge_Request[i] = false;
				}
			}
			
			//if (g_bNEEDSPEED[i])
			//{
				//if (g_iClientInZone[i][0] > 0)
				//CPrintToChat(i, "[CK] Last Start Speed: {olive}%i", RoundToNearest(g_fLastSpeed[i]));
				//g_bNEEDSPEED[i] = false;
			//}
			
			//Last Cords & Angles
			GetClientAbsOrigin(i, g_fPlayerCordsLastPosition[i]);
			GetClientEyeAngles(i, g_fPlayerAnglesLastPosition[i]);
		}
		else
			if (!IsFakeClient(i) && !IsPlayerAlive(i))
				SpecListMenuDead(i);
	}
	return Plugin_Continue;
}


//challenge start countdown
public Action Timer_Countdown(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0)
	{
		return Plugin_Stop;
	}
	if (IsValidClient(client))
	{
		if (g_bChallenge[client] && !IsFakeClient(client))
		{
			PrintToChat(client, "[%cCK%c] %c%i", RED, WHITE, YELLOW, g_CountdownTime[client]);
			g_CountdownTime[client]--;
			if (g_CountdownTime[client] <= 0)
			{
				SetEntityMoveType(client, MOVETYPE_WALK);
				PrintToChat(client, "%t", "ChallengeStarted1", RED, WHITE, YELLOW);
				PrintToChat(client, "%t", "ChallengeStarted2", RED, WHITE, YELLOW);
				PrintToChat(client, "%t", "ChallengeStarted3", RED, WHITE, YELLOW);
				return Plugin_Stop;
			}
		}
	}
	return Plugin_Continue;
}

public Action ReplayTimer(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (IsValidClient(client))
	{
		if (!IsFakeClient(client))
			SaveRecording(client, 0);
		else
			g_bNewReplay[client] = false;
	}
}
public Action BonusReplayTimer(Handle timer, Handle pack)
{
	ResetPack(pack);
	int client = GetClientOfUserId(ReadPackCell(pack));
	int zGrp = ReadPackCell(pack);

	if (IsValidClient(client))
	{
		if (!IsFakeClient(client))
		{
			SaveRecording(client, zGrp);
		}
	}
	else
		g_bNewBonus[client] = false;

	
	return Plugin_Handled;
}
public Action CheckChallenge(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0)
	{
		return Plugin_Stop;
	}
	bool oppenent = false;
	char szSteamId[128];
	char szName[32];
	char szNameTarget[32];
	if (IsValidClient(client))
	{
		if (g_bChallenge[client] && !IsFakeClient(client))
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && i != client)
				{
					if (StrEqual(g_szSteamID[i], g_szChallenge_OpponentID[client]))
															 
					{
						oppenent = true;
						if (g_bChallenge_Abort[i] && g_bChallenge_Abort[client])
						{
							GetClientName(i, szNameTarget, 32);
							GetClientName(client, szName, 32);
							g_bChallenge[client] = false;
							g_bChallenge[i] = false;
							SetEntityRenderColor(client, 255, 255, 255, 255);
							SetEntityRenderColor(i, 255, 255, 255, 255);
							PrintToChat(client, "%t", "ChallengeAborted", RED, WHITE, GREEN, szNameTarget, WHITE);
							PrintToChat(i, "%t", "ChallengeAborted", RED, WHITE, GREEN, szName, WHITE);
							SetEntityMoveType(client, MOVETYPE_WALK);
							SetEntityMoveType(i, MOVETYPE_WALK);
						}
					}
				}
			}
   
			if (!oppenent)
			{
				SetEntityRenderColor(client, 255, 255, 255, 255);
				g_bChallenge[client] = false;
				
				//db challenge entry
				db_insertPlayerChallenge(client);
				
				//new points
				g_pr_showmsg[client] = true;
				CreateTimer(0.5, UpdatePlayerProfile, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
				
				//db opponent
				Format(szSteamId, 128, "%s", g_szChallenge_OpponentID[client]);
				RecalcPlayerRank(64, szSteamId);
				
				//chat msgs
				if (IsValidClient(client))
					PrintToChat(client, "%t", "ChallengeWon", RED, WHITE, YELLOW, WHITE);
				
				return Plugin_Stop;
			}
		}
	}
	return Plugin_Continue;
}

public Action SetClanTag(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0)
	{
		return Plugin_Stop;
	}
	if (!IsValidClient(client))
		return Plugin_Stop;
	if (IsFakeClient(client) || g_pr_Calculating[client])
		return Plugin_Stop;
	
	/*char buffer[MAX_NAME_LENGTH];
	if (CS_GetClientClanTag(client, buffer,MAX_NAME_LENGTH) > 0)
		return Plugin_Stop;
	*/
	if (!GetConVarBool(g_hCountry) && !GetConVarBool(g_hPointSystem) && !GetConVarBool(g_hAdminClantag))
	{
		CS_SetClientClanTag(client, "");
		return Plugin_Stop;
	}
	
	char old_pr_rankname[128];
	char tag[154];
	bool oldrank;
	oldrank = false;
	if (!StrEqual(g_pr_rankname[client], "", false))
	{
		oldrank = true;
		Format(old_pr_rankname, 128, "%s", g_pr_rankname[client]);
	}
	SetPlayerRank(client);
	
	if (GetConVarBool(g_hCountry))
	{
		Format(tag, 154, "%s | %s", g_szCountryCode[client], g_pr_rankname[client]);
		CS_SetClientClanTag(client, tag);
	}
	else
	{
		if (GetConVarBool(g_hPointSystem) || ((StrEqual(g_pr_rankname[client], "ADMIN", false)) && GetConVarBool(g_hAdminClantag)))
			CS_SetClientClanTag(client, g_pr_rankname[client]);
	}
	
	//new rank
	if (oldrank && GetConVarBool(g_hPointSystem))
		if (IsValidClient(client))
			if (!StrEqual(g_pr_rankname[client], old_pr_rankname, false))
				CPrintToChat(client, "%t", "SkillGroup", MOSSGREEN, WHITE, GRAY, GRAY, g_pr_chat_coloredrank[client]);
	
	return Plugin_Handled;
}

public Action TerminateRoundTimer(Handle timer)
{
	CS_TerminateRound(1.0, CSRoundEnd_CTWin, true);
	//return Plugin_Handled;
}

public Action WelcomeMsgTimer(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0)
	{
		return Plugin_Stop;
	}
	char szBuffer[512];
	GetConVarString(g_hWelcomeMsg, szBuffer, 512);
	if (IsValidClient(client))
		if (!IsFakeClient(client) && szBuffer[0])
			CPrintToChat(client, "%s", szBuffer);
	
	return Plugin_Handled;
}

public Action HelpMsgTimer(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0)
	{
		return Plugin_Stop;
	}
	if (IsValidClient(client))
		if (!IsFakeClient(client))
			PrintToChat(client, "%t", "HelpMsg", MOSSGREEN, WHITE, GREEN, WHITE);
	
	return Plugin_Handled;
}


public Action AdvertTimer(Handle timer)
{
	g_Advert++;
	if ((g_Advert % 2) == 0)
	{
		if (g_bhasBonus)
		{
			PrintToChatAll("%t", "AdvertBonus", MOSSGREEN, WHITE, MOSSGREEN, WHITE, MOSSGREEN);
		}
		else if (g_bhasStages)
		{
			PrintToChatAll("%t", "AdvertStage", MOSSGREEN, WHITE, MOSSGREEN, WHITE, MOSSGREEN, WHITE, MOSSGREEN);
		}
	}
	else
	{
		if (g_bhasStages)
		{
			PrintToChatAll("%t", "AdvertStage", MOSSGREEN, WHITE, MOSSGREEN, WHITE, MOSSGREEN, WHITE, MOSSGREEN);
		}
		else if (g_bhasBonus)
		{
			PrintToChatAll("%t", "AdvertBonus", MOSSGREEN, WHITE, MOSSGREEN, WHITE, MOSSGREEN);
		}
	}
	return Plugin_Continue;
}

public Action StartMsgTimer(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0)
	{
		return Plugin_Stop;
	}
	if (IsValidClient(client))
	{
		if (!IsFakeClient(client))
			PrintMapRecords(client);
	}
	return Plugin_Handled;
}

public Action CenterMsgTimer(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0)
	{
		return Plugin_Stop;
	}
	if (IsValidClient(client))
	{
		if (!IsFakeClient(client))
		{
			if (g_bRestorePositionMsg[client])
			{
				g_fLastOverlay[client] = GetGameTime();
				g_bOverlay[client] = true;
				PrintHintText(client, "%t", "PositionRestored");
			}
			g_bRestorePositionMsg[client] = false;
		}
										
	}
	return Plugin_Handled;
}

public Action RemoveRagdoll(Handle timer, any userid)
{
	int victim = GetClientOfUserId(userid);
	if (victim == 0)
	{
		return Plugin_Stop;
	}
	if (IsValidEntity(victim))
	{
		if (!IsPlayerAlive(victim))
		{
			int player_ragdoll;
			player_ragdoll = GetEntDataEnt2(victim, g_ragdolls);
			if (player_ragdoll != -1)
				RemoveEdict(player_ragdoll);
		}
	}
	return Plugin_Handled;
}

public Action HideHud(Handle timer, any userid)
{
	int client = GetClientOfUserId(userid);
	if (client == 0)
	{
		return Plugin_Stop;
	}
	if (IsValidClient(client))
	{
		if (!IsFakeClient(client))
		{
			SetEntPropEnt(client, Prop_Send, "m_bSpotted", 0);
	
			// ViewModel
			Client_SetDrawViewModel(client, g_bViewModel[client]);
	
			// Crosshair and chat
			if (g_bViewModel[client])
			{
				// Display
				if (!g_bHideChat[client])
					SetEntProp(client, Prop_Send, "m_iHideHUD", HIDE_RADAR);
				else
					SetEntProp(client, Prop_Send, "m_iHideHUD", HIDE_RADAR | HIDE_CHAT);
	
			}
			else
			{
				// Hiding
				if (!g_bHideChat[client])
					SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDE_RADAR | HIDE_CROSSHAIR);
				else
					SetEntProp(client, Prop_Send, "m_iHideHUD", GetEntProp(client, Prop_Send, "m_iHideHUD") | HIDE_RADAR | HIDE_CHAT | HIDE_CROSSHAIR);
			}
		}
	}
	return Plugin_Handled;
}

public Action LoadPlayerSettings(Handle timer)
{
	for (int c = 1; c <= MaxClients; c++)
	{
		if (IsValidClient(c))
			OnClientPutInServer(c);
	}
	//return Plugin_Handled;
}
