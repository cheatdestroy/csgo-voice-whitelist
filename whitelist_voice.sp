#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

public Plugin:myinfo = 
{
	name = "WhiteList Voice",
	author = "CheaT",
	version = "1.0.0",
	description = "WhiteList access for voice chat.",
	url = "https://t.me/cheatdestroy"
}

#define PATH_WHITELIST	"configs/voice_whitelist.ini"

static const String:g_sFeature[] = "Voice";

new Handle:g_hKeyValues;

public OnMapStart()
{
	decl String:sBuffer[256];

	if(g_hKeyValues != INVALID_HANDLE)
	{
		CloseHandle(g_hKeyValues);
	}

	g_hKeyValues = CreateKeyValues("VoiceWhiteList");
	BuildPath(Path_SM, sBuffer, sizeof(sBuffer), PATH_WHITELIST);

	if(!FileToKeyValues(g_hKeyValues, sBuffer))
	{
		CloseHandle(g_hKeyValues);
		SetFailState("Не удалось открыть файл \"%s\"", sBuffer);
	}
}

public OnClientPostAdminCheck(int client)
{
	if (CheckCommandAccess(client, "", ADMFLAG_BAN, true) || IsWhiteList(client))
	{
		SetClientListeningFlags(client, VOICE_TEAM);
		LogMessage("Access voice for %N", client);
	}
	else
	{
		SetClientListeningFlags(client, VOICE_MUTED);
	}
}

public int IsWhiteList(int client)
{
	char sBuffer[256], sSteamID[64];
	GetClientAuthId(client, AuthId_Steam2, sSteamID, sizeof(sSteamID));

	KvRewind(g_hKeyValues);
	if(KvJumpToKey(g_hKeyValues, sSteamID))
	{
		KvGetString(g_hKeyValues, g_sFeature, sBuffer, sizeof(sBuffer));

		return StringToInt(sBuffer) ? 1 : 0;
	}
	
	return 0;
}