/*
	[SPAWN<>TOOLS<>7]
*/

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#undef REQUIRE_PLUGIN
#include <adminmenu>
#pragma newdecls required

#define VERSION "1.0.1"

public Plugin myinfo =
{
	name = "[CS:GO] SpawnTools7",
	author = "meng & IDDQD",
	description = "spawn point editing tools",
	version = VERSION,
	url = "https://forums.alliedmods.net/showthread.php?t=115496"
}

Handle AdminMenu
bool g_bRemoveDefSpawns = false, g_bInEditMode = false, g_bMapStarted = false, g_bCustomSpawnPoints = false;
char MapCfgPath[PLATFORM_MAX_PATH], g_sWorkShopID[PLATFORM_MAX_PATH];
int g_iBlueGlowSprite, g_iRedGlowSprite, g_iMapSpawnsNum = 0, g_iKilledSpawnsNum = 0, g_iCustomSpawnsNum = 0, g_iDefSpawnsClearNum = 0, g_iEditModeActivator = 0
ArrayList g_hMapSpawns, g_hSpawnTeamNum, g_hKilledSpawns, g_hCustomSpawns, g_hCustomSpawnIndexes

public void OnPluginStart()
{
	char configspath[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, configspath, sizeof(configspath), "configs/spawntools7")
	if (!DirExists(configspath))
		CreateDirectory(configspath, 0x0265)
		
	BuildPath(Path_SM, configspath, sizeof(configspath), "configs/spawntools7/workshop")
	if (!DirExists(configspath))
		CreateDirectory(configspath, 0x0265)

	Handle topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != INVALID_HANDLE))
		OnAdminMenuReady(topmenu);

	g_hKilledSpawns = CreateArray(3)
	g_hCustomSpawns = CreateArray(5)
	g_hCustomSpawnIndexes = CreateArray()
	g_hMapSpawns = CreateArray()
	g_hSpawnTeamNum = CreateArray()
}

public void OnMapStart()
{
	CreateTimer(0.1, TimerOnMapStart, _, TIMER_FLAG_NO_MAPCHANGE) // some maps, like de_cache, need a small delay before creating spawn points
}

public Action TimerOnMapStart(Handle timer)
{
	if(!g_iCustomSpawnsNum)
		return

	float DataFloats[5]
	g_bCustomSpawnPoints = true
	for(int i = 0; i < g_iCustomSpawnsNum; ++i)
	{
		GetArrayArray(g_hCustomSpawns, i, DataFloats)
		CreateSpawn(DataFloats)
	}
	g_bCustomSpawnPoints = false
	PrintToServer("[SpawnTools7] Map has %i spawn points, %i%s killed, %i custom", g_iMapSpawnsNum, g_bRemoveDefSpawns ? g_iDefSpawnsClearNum : g_iKilledSpawnsNum, g_bRemoveDefSpawns ? " default spawns" : "", g_iCustomSpawnsNum)
}

public void OnEntityCreated(int entity, const char[] classname)
{
	if(!g_bMapStarted)
	{
		if(!entity)
			return

		g_bMapStarted = true
		UTIL_MapStarted()
	}

	if(classname[0] == 'i' && classname[4] == '_' && classname[11] == '_')
	{
		switch(classname[12])
		{
			case 't': SDKHook(entity, SDKHook_SpawnPost, OnTsEntitySpawnPost)
			case 'c': SDKHook(entity, SDKHook_SpawnPost, OnCTsEntitySpawnPost)
		}
	}
}

public void OnTsEntitySpawnPost(int EntRef) 
{
	int entity = EntRefToEntIndex(EntRef)
	
	if((g_bRemoveDefSpawns && !g_bCustomSpawnPoints) || UTIL_IsDeadEntity(entity))
	{
		if(g_bRemoveDefSpawns)
			g_iDefSpawnsClearNum++

		AcceptEntityInput(entity, "Kill")
		return
	}
	
	if(g_bCustomSpawnPoints)
		PushArrayCell(g_hCustomSpawnIndexes, entity)
	
	g_iMapSpawnsNum++
	PushArrayCell(g_hSpawnTeamNum, 2)
	PushArrayCell(g_hMapSpawns, entity)
	SDKUnhook(entity, SDKHook_SpawnPost, OnTsEntitySpawnPost)
}

public void OnCTsEntitySpawnPost(int EntRef) 
{
	int entity = EntRefToEntIndex(EntRef)

	if((g_bRemoveDefSpawns && !g_bCustomSpawnPoints) || UTIL_IsDeadEntity(entity))
	{
		if(g_bRemoveDefSpawns)
			g_iDefSpawnsClearNum++

		AcceptEntityInput(entity, "Kill")
		return
	}
	
	if(g_bCustomSpawnPoints)
		PushArrayCell(g_hCustomSpawnIndexes, entity)
	
	g_iMapSpawnsNum++
	PushArrayCell(g_hSpawnTeamNum, 3)
	PushArrayCell(g_hMapSpawns, entity)
	SDKUnhook(entity, SDKHook_SpawnPost, OnCTsEntitySpawnPost)
}

void ReadConfig()
{
	Handle kv = CreateKeyValues("ST7Root");
	if (FileToKeyValues(kv, MapCfgPath))
	{
		char sBuffer[32]
		float fVec[3], DataFloats[5];
		if (KvGetNum(kv, "remdefsp"))
			g_bRemoveDefSpawns = true;
		else
		{
			Format(sBuffer, 31, "rs:%d:pos", g_iKilledSpawnsNum);
			KvGetVector(kv, sBuffer, fVec);
			while (fVec[0] != 0.0)
			{
				PushArrayArray(g_hKilledSpawns, fVec);
				g_iKilledSpawnsNum++;
				Format(sBuffer, 31, "rs:%d:pos", g_iKilledSpawnsNum);
				KvGetVector(kv, sBuffer, fVec);
			}
		}

		Format(sBuffer, 31, "ns:%d:pos", g_iCustomSpawnsNum);
		KvGetVector(kv, sBuffer, fVec);
		while (fVec[0] != 0.0)
		{
			DataFloats[0] = fVec[0];
			DataFloats[1] = fVec[1];
			DataFloats[2] = fVec[2];
			Format(sBuffer, 31, "ns:%d:ang", g_iCustomSpawnsNum);
			DataFloats[3] = KvGetFloat(kv, sBuffer);
			Format(sBuffer, 31, "ns:%d:team", g_iCustomSpawnsNum);
			DataFloats[4] = KvGetFloat(kv, sBuffer);
			PushArrayArray(g_hCustomSpawns, DataFloats);
			g_iCustomSpawnsNum++;
			Format(sBuffer, 31, "ns:%d:pos", g_iCustomSpawnsNum);
			KvGetVector(kv, sBuffer, fVec);
		}
	}
	CloseHandle(kv);
}

public void OnLibraryRemoved(const char[] name)
{
	if (strcmp(name, "adminmenu") == 0)
		AdminMenu = INVALID_HANDLE;
}

public void OnClientDisconnect(int client)
{
	if(g_iEditModeActivator == client)
	{
		g_iEditModeActivator = 0
		g_bInEditMode = false
	}
}

public void OnAdminMenuReady(Handle topmenu)
{
	if (topmenu == AdminMenu)
		return;

	AdminMenu = topmenu;
	TopMenuObject serverCmds = FindTopMenuCategory(AdminMenu, ADMINMENU_SERVERCOMMANDS);
	AddToTopMenu(AdminMenu, "sm_spawntools7", TopMenuObject_Item, TopMenuHandler, serverCmds, "sm_spawntools7", ADMFLAG_RCON);
}

public void TopMenuHandler(Handle topmenu, TopMenuAction action, TopMenuObject object_id, int param, char[] buffer, int maxlength)
{
	if (action == TopMenuAction_DisplayOption)
		Format(buffer, maxlength, "Spawn Tools 7");

	else if (action == TopMenuAction_SelectOption)
		ShowToolzMenu(param);
}

void ShowToolzMenu(int client)
{
	Panel panel = CreatePanel();
	SetPanelTitle(panel, "Spawn Tools 7");
	char sText[256];
	FormatEx(sText, 255, "1. %s Edit Mode\n2. %s Default Spawn Removal\n3. Add T Spawn\n4. Add CT Spawn\n5. Remove Spawn\n6. Remove All T Spawns\n7. Remove All CT Spawns\n8. Save Configuration\n\n9. Exit", g_bInEditMode == false ? "Enable" : "Disable", g_bRemoveDefSpawns == false ? "Enable" : "Disable")
	DrawPanelText(panel, sText)
	SetPanelKeys(panel, ((1<<0)|(1<<1)|(1<<2)|(1<<3)|(1<<4)|(1<<5)|(1<<6)|(1<<7)|(1<<8)))
	SendPanelToClient(panel, client, MainMenuHandler, MENU_TIME_FOREVER)
	delete panel
}

public int MainMenuHandler(Handle menu, MenuAction action, int client, int selection)
{
	switch(action)
	{
		case MenuAction_Select:
		{
			switch(selection)
			{
				case 1:
				{
					g_bInEditMode = !g_bInEditMode
					PrintToChat(client, "[SpawnTools7] Edit Mode %s.", !g_bInEditMode ? "Disabled" : "Enabled");
					if (g_bInEditMode)
					{
						CreateTimer(1.0, ShowEditModeGoodies, INVALID_HANDLE, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
						g_iEditModeActivator = client
					}
					else
						g_iEditModeActivator = 0

					ShowToolzMenu(client);
				}
				case 2:
				{
					g_bRemoveDefSpawns = !g_bRemoveDefSpawns
					PrintToChat(client, "[SpawnTools7] Default Spawn Removal will be %s.", !g_bRemoveDefSpawns ? "Disabled" : "Enabled");
					ShowToolzMenu(client);
				}
				case 3:
				{
					if(!g_bInEditMode)
					{
						PrintToChat(client, "You must enable the edit mode!")
						ShowToolzMenu(client)
						return
					}

					bool bCacheData = g_bRemoveDefSpawns
					g_bRemoveDefSpawns = false
					InitializeNewSpawn(client, 2);
					g_bRemoveDefSpawns = bCacheData
					ShowToolzMenu(client);
				}
				case 4:
				{
					if(!g_bInEditMode)
					{
						PrintToChat(client, "You must enable the edit mode!")
						ShowToolzMenu(client)
						return
					}

					bool bCacheData = g_bRemoveDefSpawns
					g_bRemoveDefSpawns = false
					InitializeNewSpawn(client, 3);
					g_bRemoveDefSpawns = bCacheData
					ShowToolzMenu(client);
				}
				case 5:
				{
					if(!g_bInEditMode)
					{
						PrintToChat(client, "You must enable the edit mode!")
						ShowToolzMenu(client)
						return
					}

					if (!RemoveSpawn(client))
						PrintToChat(client, "[SpawnTools7] No valid spawn point found.");
					else
						PrintToChat(client, "[SpawnTools7] Spawn point removed!");

					ShowToolzMenu(client);
				}
				case 6:
				{
					if(!g_bInEditMode)
					{
						PrintToChat(client, "You must enable the edit mode!")
						ShowToolzMenu(client)
						return
					}

					int entity, iCustom
					float vOrigin[3]
					for(int i = 0; i < g_iMapSpawnsNum; i++)
					{
						if(UTIL_GetSpawnEntityTeamNum(i) != 2)
							continue
						
						if((iCustom = UTIL_IsCustomSpawn((entity = UTIL_GetSpawnEntityIndex(i)))) != -1)
						{
							g_iCustomSpawnsNum--
							RemoveFromArray(g_hCustomSpawns, iCustom)
							RemoveFromArray(g_hCustomSpawnIndexes, iCustom)
						}
						else
						{
							g_iKilledSpawnsNum++
							GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vOrigin)
							PushArrayArray(g_hKilledSpawns, vOrigin)
						}

						RemoveFromArray(g_hMapSpawns, i)
						AcceptEntityInput(entity, "Kill")
						RemoveFromArray(g_hSpawnTeamNum, i)
						
						g_iMapSpawnsNum--, i--
					}
					ShowToolzMenu(client);
				}
				case 7:
				{
					if(!g_bInEditMode)
					{
						PrintToChat(client, "You must enable the edit mode!")
						ShowToolzMenu(client)
						return
					}

					int entity, iCustom
					float vOrigin[3]
					for(int i = 0; i < g_iMapSpawnsNum; i++)
					{
						if(UTIL_GetSpawnEntityTeamNum(i) != 3)
							continue
						
						if((iCustom = UTIL_IsCustomSpawn((entity = UTIL_GetSpawnEntityIndex(i)))) != -1)
						{
							g_iCustomSpawnsNum--
							RemoveFromArray(g_hCustomSpawns, iCustom)
							RemoveFromArray(g_hCustomSpawnIndexes, iCustom)
						}
						else
						{
							g_iKilledSpawnsNum++
							GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vOrigin)
							PushArrayArray(g_hKilledSpawns, vOrigin)
						}

						RemoveFromArray(g_hMapSpawns, i)
						AcceptEntityInput(entity, "Kill")
						RemoveFromArray(g_hSpawnTeamNum, i)
						
						g_iMapSpawnsNum--, i--
					}
					ShowToolzMenu(client);
				}
				case 8:
				{
					SaveConfiguration() ? PrintToChat(client, "[SpawnTools7] Configuration Saved!") : LogError("failed to save to key values")
					ShowToolzMenu(client);
				}
				case 9:
				{
					g_bInEditMode = false
					g_iEditModeActivator = 0
				}
			}
		}
		case MenuAction_Cancel:
		{
			if(selection == MenuCancel_Interrupted)
			{
				g_bInEditMode = false
				g_iEditModeActivator = 0
			}
		}
	}

}

public Action ShowEditModeGoodies(Handle timer)
{
	if (!g_bInEditMode)
		return Plugin_Stop;

	int tsCount, ctsCount
	float fVec[3];
	for (int i = 0; i < g_iMapSpawnsNum; i++)
	{
		if (UTIL_GetSpawnEntityTeamNum(i) == 2)
		{
			tsCount++;
			GetEntPropVector(UTIL_GetSpawnEntityIndex(i), Prop_Data, "m_vecOrigin", fVec);
			TE_SetupGlowSprite(fVec, g_iRedGlowSprite, 1.0, 0.4, 249);
			TE_SendToAll();
		}
		else
		{
			ctsCount++;
			GetEntPropVector(UTIL_GetSpawnEntityIndex(i), Prop_Data, "m_vecOrigin", fVec);
			TE_SetupGlowSprite(fVec, g_iBlueGlowSprite, 1.0, 0.3, 237);
			TE_SendToAll();
		}
	}
	PrintHintText(g_iEditModeActivator, "T Spawns: %i \nCT Spawns: %i", tsCount, ctsCount)
	return Plugin_Continue;
}

void InitializeNewSpawn(int client, int team)
{
	float DataFloats[5], posVec[3], angVec[3];
	GetClientAbsOrigin(client, posVec);
	GetClientEyeAngles(client, angVec);
	DataFloats[0] = posVec[0];
	DataFloats[1] = posVec[1];
	DataFloats[2] = (posVec[2] + 16.0);
	DataFloats[3] = angVec[1];
	DataFloats[4] = float(team);

	if (CreateSpawn(DataFloats, true))
		PrintToChat(client, "[SpawnTools7] New spawn point created!");
	else
		LogError("failed to create new sp entity");
}

bool CreateSpawn(float DataFloats[5], bool isNew = false) // if 2 spawn entities will closer than 42 unit, the server will flood in console "BUG: CCSGameMovement::CheckParameters - too many stacking levels.", you may not worry about it if convar mp_solid_teammates is 0
{
	float posVec[3], angVec[3];
	posVec[0] = DataFloats[0];
	posVec[1] = DataFloats[1];
	posVec[2] = DataFloats[2];
	angVec[0] = 0.0;
	angVec[1] = DataFloats[3];
	angVec[2] = 0.0;

	int RefEnt = CreateEntityByName(DataFloats[4] == 2.0 ? "info_player_terrorist" : "info_player_counterterrorist");
	if (DispatchSpawn(RefEnt))
	{
		int entity = EntRefToEntIndex(RefEnt)
		TeleportEntity(entity, posVec, angVec, NULL_VECTOR);
		
		if(isNew)
		{
			g_iCustomSpawnsNum++
			PushArrayArray(g_hCustomSpawns, DataFloats)
			PushArrayCell(g_hCustomSpawnIndexes, entity)
		}
		return true;
	}

	return false;
}

bool RemoveSpawn(int client)
{
	float client_posVec[3], ent_posVec[3]
	int i, d, iCustom
	GetClientAbsOrigin(client, client_posVec);
	client_posVec[2] += 16;
	for (i = 0; i < g_iMapSpawnsNum; i++)
	{
		GetEntPropVector((d = UTIL_GetSpawnEntityIndex(i)), Prop_Data, "m_vecOrigin", ent_posVec);
		if (GetVectorDistance(client_posVec, ent_posVec) < 42.7)
		{
			if((iCustom = UTIL_IsCustomSpawn(d)) != -1)
			{
				g_iCustomSpawnsNum--
				RemoveFromArray(g_hCustomSpawns, iCustom)
				RemoveFromArray(g_hCustomSpawnIndexes, iCustom)
			}
			else
			{
				g_iKilledSpawnsNum++
				PushArrayArray(g_hKilledSpawns, ent_posVec)
			}

			g_iMapSpawnsNum--
			AcceptEntityInput(d, "Kill")
			RemoveFromArray(g_hMapSpawns, i)
			RemoveFromArray(g_hSpawnTeamNum, i)
			return true;
		}
	}
	return false;
}

bool SaveConfiguration()
{
	KeyValues kv = CreateKeyValues("ST7Root");
	char sBuffer[32]
	float DataFloats[5], posVec[3];
	KvJumpToKey(kv, "smdata", true);
	KvSetNum(kv, "remdefsp", g_bRemoveDefSpawns ? 1 : 0);
	if (g_iCustomSpawnsNum)
	{
		for (int i = 0; i < g_iCustomSpawnsNum; i++)
		{
			GetArrayArray(g_hCustomSpawns, i, DataFloats);
			posVec[0] = DataFloats[0];
			posVec[1] = DataFloats[1];
			posVec[2] = DataFloats[2];
			Format(sBuffer, 31, "ns:%d:pos", i);
			KvSetVector(kv, sBuffer, posVec);
			Format(sBuffer, 31, "ns:%d:ang", i);
			KvSetFloat(kv, sBuffer, DataFloats[3]);
			Format(sBuffer, 31, "ns:%d:team", i);
			KvSetFloat(kv, sBuffer, DataFloats[4]);
		}
	}

	if (g_iKilledSpawnsNum)
	{
		if(g_bRemoveDefSpawns)
		{
			ClearArray(g_hKilledSpawns)
			g_iKilledSpawnsNum = 0
		}
		else
		{
			for (int i = 0; i < g_iKilledSpawnsNum; i++)
			{
				GetArrayArray(g_hKilledSpawns, i, posVec);
				Format(sBuffer, sizeof(sBuffer), "rs:%d:pos", i);
				KvSetVector(kv, sBuffer, posVec);
			}
		}
	}

	bool RetVal = KeyValuesToFile(kv, MapCfgPath)
	delete kv;
	return RetVal
}

stock int UTIL_ArrayIndexOfSpawnEntity(int entity)
{
	if(!g_iMapSpawnsNum)
		return -1

	for(int i = 0; i < g_iMapSpawnsNum; ++i)
		if(GetArrayCell(g_hMapSpawns, i) == entity)
			return i

	return -1
}

int UTIL_GetSpawnEntityIndex(int cell)
{
	return GetArrayCell(g_hMapSpawns, cell)
}

int UTIL_GetSpawnEntityTeamNum(int cell)
{
	return GetArrayCell(g_hSpawnTeamNum, cell)
}

int UTIL_IsCustomSpawn(int entity)
{
	if(!g_iCustomSpawnsNum)
		return -1

	for(int i = 0; i < g_iCustomSpawnsNum; ++i)
		if(GetArrayCell(g_hCustomSpawnIndexes, i) == entity)
			return i
	
	return -1
}

bool UTIL_IsDeadEntity(int entity)
{
	if(!g_iKilledSpawnsNum)
		return false

	float vOrigin[3], vOrigin2[3]
	for(int i = 0; i < g_iKilledSpawnsNum; ++i)
	{
		GetArrayArray(g_hKilledSpawns, i, vOrigin)
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vOrigin2)
		
		if(RoundToFloor(vOrigin[0]) == RoundToFloor(vOrigin2[0]) && RoundToFloor(vOrigin[1]) == RoundToFloor(vOrigin2[1]))
			return true
	}
	return false
}

void UTIL_MapStarted()
{
	char sMapName[64], sBuffer[64];
	GetCurrentMap(sMapName, 63);
	
	if (StrContains(sMapName, "workshop", false) != -1)
	{
		GetCurrentWorkshopMap(sBuffer, 63, g_sWorkShopID, sizeof(g_sWorkShopID) - 1)
		BuildPath(Path_SM, MapCfgPath, sizeof(MapCfgPath), "configs/spawntools7/workshop/%s/%s.cfg", g_sWorkShopID, sBuffer)
	}
	else
		BuildPath(Path_SM, MapCfgPath, sizeof(MapCfgPath), "configs/spawntools7/%s.cfg", sMapName)

	ReadConfig();

	g_iRedGlowSprite = PrecacheModel("sprites/purpleglow1.vmt");
	g_iBlueGlowSprite = PrecacheModel("sprites/blueglow1.vmt");
}

void GetCurrentWorkshopMap(char[] szMap, int iMapBuf, char[] szWorkShopID, int iWorkShopBuf)
{
	char szCurMap[128]
	char szCurMapSplit[2][64]

	GetCurrentMap(szCurMap, 127)
	ReplaceString(szCurMap, sizeof(szCurMap), "workshop/", "", false)
	ExplodeString(szCurMap, "/", szCurMapSplit, 2, 63)

	strcopy(szMap, iMapBuf, szCurMapSplit[1])
	strcopy(szWorkShopID, iWorkShopBuf, szCurMapSplit[0])
} 

public void OnMapEnd()
{
	ClearArray(g_hMapSpawns)
	ClearArray(g_hKilledSpawns);
	ClearArray(g_hCustomSpawns);
	ClearArray(g_hSpawnTeamNum);
	ClearArray(g_hCustomSpawnIndexes);
	g_iMapSpawnsNum = g_iKilledSpawnsNum = g_iCustomSpawnsNum = g_iDefSpawnsClearNum = g_iEditModeActivator = 0
	g_bRemoveDefSpawns = g_bInEditMode = g_bMapStarted = g_bCustomSpawnPoints = false
}

public void OnPluginEnd()
{
	delete g_hMapSpawns
	delete g_hCustomSpawns
	delete g_hKilledSpawns
	delete g_hSpawnTeamNum
	delete g_hCustomSpawnIndexes
}