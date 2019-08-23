public PlVers:__version =
{
	version = 5,
	filevers = "1.8.0.5874",
	date = "07/07/2017",
	time = "07:05:12"
};
new Float:NULL_VECTOR[3];
new String:NULL_STRING[4];
public Extension:__ext_core =
{
	name = "Core",
	file = "core",
	autoload = 0,
	required = 0,
};
new MaxClients;
public Extension:__ext_smjansson =
{
	name = "SMJansson",
	file = "smjansson.ext",
	autoload = 1,
	required = 1,
};
public Extension:__ext_SteamWorks =
{
	name = "SteamWorks",
	file = "SteamWorks.ext",
	autoload = 1,
	required = 1,
};
new Handle:hRateLimit;
new Handle:hRateReset;
new Handle:hRateLeft;
public Plugin:myinfo =
{
	name = "Discord API",
	description = "",
	author = "Deathknife",
	version = "0.1.97",
	url = ""
};
public __ext_core_SetNTVOptional()
{
	MarkNativeAsOptional("GetFeatureStatus");
	MarkNativeAsOptional("RequireFeature");
	MarkNativeAsOptional("AddCommandListener");
	MarkNativeAsOptional("RemoveCommandListener");
	MarkNativeAsOptional("BfWriteBool");
	MarkNativeAsOptional("BfWriteByte");
	MarkNativeAsOptional("BfWriteChar");
	MarkNativeAsOptional("BfWriteShort");
	MarkNativeAsOptional("BfWriteWord");
	MarkNativeAsOptional("BfWriteNum");
	MarkNativeAsOptional("BfWriteFloat");
	MarkNativeAsOptional("BfWriteString");
	MarkNativeAsOptional("BfWriteEntity");
	MarkNativeAsOptional("BfWriteAngle");
	MarkNativeAsOptional("BfWriteCoord");
	MarkNativeAsOptional("BfWriteVecCoord");
	MarkNativeAsOptional("BfWriteVecNormal");
	MarkNativeAsOptional("BfWriteAngles");
	MarkNativeAsOptional("BfReadBool");
	MarkNativeAsOptional("BfReadByte");
	MarkNativeAsOptional("BfReadChar");
	MarkNativeAsOptional("BfReadShort");
	MarkNativeAsOptional("BfReadWord");
	MarkNativeAsOptional("BfReadNum");
	MarkNativeAsOptional("BfReadFloat");
	MarkNativeAsOptional("BfReadString");
	MarkNativeAsOptional("BfReadEntity");
	MarkNativeAsOptional("BfReadAngle");
	MarkNativeAsOptional("BfReadCoord");
	MarkNativeAsOptional("BfReadVecCoord");
	MarkNativeAsOptional("BfReadVecNormal");
	MarkNativeAsOptional("BfReadAngles");
	MarkNativeAsOptional("BfGetNumBytesLeft");
	MarkNativeAsOptional("BfWrite.WriteBool");
	MarkNativeAsOptional("BfWrite.WriteByte");
	MarkNativeAsOptional("BfWrite.WriteChar");
	MarkNativeAsOptional("BfWrite.WriteShort");
	MarkNativeAsOptional("BfWrite.WriteWord");
	MarkNativeAsOptional("BfWrite.WriteNum");
	MarkNativeAsOptional("BfWrite.WriteFloat");
	MarkNativeAsOptional("BfWrite.WriteString");
	MarkNativeAsOptional("BfWrite.WriteEntity");
	MarkNativeAsOptional("BfWrite.WriteAngle");
	MarkNativeAsOptional("BfWrite.WriteCoord");
	MarkNativeAsOptional("BfWrite.WriteVecCoord");
	MarkNativeAsOptional("BfWrite.WriteVecNormal");
	MarkNativeAsOptional("BfWrite.WriteAngles");
	MarkNativeAsOptional("BfRead.ReadBool");
	MarkNativeAsOptional("BfRead.ReadByte");
	MarkNativeAsOptional("BfRead.ReadChar");
	MarkNativeAsOptional("BfRead.ReadShort");
	MarkNativeAsOptional("BfRead.ReadWord");
	MarkNativeAsOptional("BfRead.ReadNum");
	MarkNativeAsOptional("BfRead.ReadFloat");
	MarkNativeAsOptional("BfRead.ReadString");
	MarkNativeAsOptional("BfRead.ReadEntity");
	MarkNativeAsOptional("BfRead.ReadAngle");
	MarkNativeAsOptional("BfRead.ReadCoord");
	MarkNativeAsOptional("BfRead.ReadVecCoord");
	MarkNativeAsOptional("BfRead.ReadVecNormal");
	MarkNativeAsOptional("BfRead.ReadAngles");
	MarkNativeAsOptional("BfRead.GetNumBytesLeft");
	MarkNativeAsOptional("PbReadInt");
	MarkNativeAsOptional("PbReadFloat");
	MarkNativeAsOptional("PbReadBool");
	MarkNativeAsOptional("PbReadString");
	MarkNativeAsOptional("PbReadColor");
	MarkNativeAsOptional("PbReadAngle");
	MarkNativeAsOptional("PbReadVector");
	MarkNativeAsOptional("PbReadVector2D");
	MarkNativeAsOptional("PbGetRepeatedFieldCount");
	MarkNativeAsOptional("PbSetInt");
	MarkNativeAsOptional("PbSetFloat");
	MarkNativeAsOptional("PbSetBool");
	MarkNativeAsOptional("PbSetString");
	MarkNativeAsOptional("PbSetColor");
	MarkNativeAsOptional("PbSetAngle");
	MarkNativeAsOptional("PbSetVector");
	MarkNativeAsOptional("PbSetVector2D");
	MarkNativeAsOptional("PbAddInt");
	MarkNativeAsOptional("PbAddFloat");
	MarkNativeAsOptional("PbAddBool");
	MarkNativeAsOptional("PbAddString");
	MarkNativeAsOptional("PbAddColor");
	MarkNativeAsOptional("PbAddAngle");
	MarkNativeAsOptional("PbAddVector");
	MarkNativeAsOptional("PbAddVector2D");
	MarkNativeAsOptional("PbRemoveRepeatedFieldValue");
	MarkNativeAsOptional("PbReadMessage");
	MarkNativeAsOptional("PbReadRepeatedMessage");
	MarkNativeAsOptional("PbAddMessage");
	MarkNativeAsOptional("Protobuf.ReadInt");
	MarkNativeAsOptional("Protobuf.ReadFloat");
	MarkNativeAsOptional("Protobuf.ReadBool");
	MarkNativeAsOptional("Protobuf.ReadString");
	MarkNativeAsOptional("Protobuf.ReadColor");
	MarkNativeAsOptional("Protobuf.ReadAngle");
	MarkNativeAsOptional("Protobuf.ReadVector");
	MarkNativeAsOptional("Protobuf.ReadVector2D");
	MarkNativeAsOptional("Protobuf.GetRepeatedFieldCount");
	MarkNativeAsOptional("Protobuf.SetInt");
	MarkNativeAsOptional("Protobuf.SetFloat");
	MarkNativeAsOptional("Protobuf.SetBool");
	MarkNativeAsOptional("Protobuf.SetString");
	MarkNativeAsOptional("Protobuf.SetColor");
	MarkNativeAsOptional("Protobuf.SetAngle");
	MarkNativeAsOptional("Protobuf.SetVector");
	MarkNativeAsOptional("Protobuf.SetVector2D");
	MarkNativeAsOptional("Protobuf.AddInt");
	MarkNativeAsOptional("Protobuf.AddFloat");
	MarkNativeAsOptional("Protobuf.AddBool");
	MarkNativeAsOptional("Protobuf.AddString");
	MarkNativeAsOptional("Protobuf.AddColor");
	MarkNativeAsOptional("Protobuf.AddAngle");
	MarkNativeAsOptional("Protobuf.AddVector");
	MarkNativeAsOptional("Protobuf.AddVector2D");
	MarkNativeAsOptional("Protobuf.RemoveRepeatedFieldValue");
	MarkNativeAsOptional("Protobuf.ReadMessage");
	MarkNativeAsOptional("Protobuf.ReadRepeatedMessage");
	MarkNativeAsOptional("Protobuf.AddMessage");
	VerifyCoreVersion();
	return 0;
}

public .2920.StrEqual(String:str1[], String:str2[], bool:caseSensitive)
{
	return strcmp(str1, str2, caseSensitive) == 0;
}

public .2920.StrEqual(String:str1[], String:str2[], bool:caseSensitive)
{
	return strcmp(str1, str2, caseSensitive) == 0;
}

public .2972.json_pack_array_(String:sFormat[], &iPos, Handle:hParams)
{
	new Handle:hObj = json_array();
	new iStrLen = strlen(sFormat);
	while (iPos < iStrLen)
	{
		new this_char = sFormat[iPos];
		new var1;
		if (this_char == 32 || this_char == 58 || this_char == 44)
		{
			new var2 = iPos;
			var2++;
			iPos = var2;
		}
		else
		{
			if (this_char == 93)
			{
				new var3 = iPos;
				var3++;
				iPos = var3;
				return hObj;
			}
			new Handle:hValue = .4300.json_pack_element_(sFormat, iPos, hParams);
			json_array_append_new(hObj, hValue);
		}
	}
	return hObj;
}

public .2972.json_pack_array_(String:sFormat[], &iPos, Handle:hParams)
{
	new Handle:hObj = json_array();
	new iStrLen = strlen(sFormat);
	while (iPos < iStrLen)
	{
		new this_char = sFormat[iPos];
		new var1;
		if (this_char == 32 || this_char == 58 || this_char == 44)
		{
			new var2 = iPos;
			var2++;
			iPos = var2;
		}
		else
		{
			if (this_char == 93)
			{
				new var3 = iPos;
				var3++;
				iPos = var3;
				return hObj;
			}
			new Handle:hValue = .4300.json_pack_element_(sFormat, iPos, hParams);
			json_array_append_new(hObj, hValue);
		}
	}
	return hObj;
}

public .3520.json_pack_object_(String:sFormat[], &iPos, Handle:hParams)
{
	new Handle:hObj = json_object();
	new iStrLen = strlen(sFormat);
	while (iPos < iStrLen)
	{
		new this_char = sFormat[iPos];
		new var1;
		if (this_char == 32 || this_char == 58 || this_char == 44)
		{
			new var2 = iPos;
			var2++;
			iPos = var2;
		}
		else
		{
			if (this_char == 125)
			{
				new var3 = iPos;
				var3++;
				iPos = var3;
				return hObj;
			}
			if (this_char != 115)
			{
				LogError("Object keys must be strings at %d.", iPos);
				return 0;
			}
			decl String:sKey[256];
			GetArrayString(hParams, 0, sKey, 255);
			RemoveFromArray(hParams, 0);
			new var4 = iPos;
			var4++;
			iPos = var4;
			new Handle:hValue = .4300.json_pack_element_(sFormat, iPos, hParams);
			json_object_set_new(hObj, sKey, hValue);
		}
	}
	return hObj;
}

public .3520.json_pack_object_(String:sFormat[], &iPos, Handle:hParams)
{
	new Handle:hObj = json_object();
	new iStrLen = strlen(sFormat);
	while (iPos < iStrLen)
	{
		new this_char = sFormat[iPos];
		new var1;
		if (this_char == 32 || this_char == 58 || this_char == 44)
		{
			new var2 = iPos;
			var2++;
			iPos = var2;
		}
		else
		{
			if (this_char == 125)
			{
				new var3 = iPos;
				var3++;
				iPos = var3;
				return hObj;
			}
			if (this_char != 115)
			{
				LogError("Object keys must be strings at %d.", iPos);
				return 0;
			}
			decl String:sKey[256];
			GetArrayString(hParams, 0, sKey, 255);
			RemoveFromArray(hParams, 0);
			new var4 = iPos;
			var4++;
			iPos = var4;
			new Handle:hValue = .4300.json_pack_element_(sFormat, iPos, hParams);
			json_object_set_new(hObj, sKey, hValue);
		}
	}
	return hObj;
}

public .4300.json_pack_element_(String:sFormat[], &iPos, Handle:hParams)
{
	new this_char = sFormat[iPos];
	while (this_char == 32 || this_char == 58 || this_char == 44)
	{
		new var2 = iPos;
		var2++;
		iPos = var2;
		this_char = sFormat[iPos];
	}
	new var3 = iPos;
	var3++;
	iPos = var3;
	switch (this_char)
	{
		case 91:
		{
			return .2972.json_pack_array_(sFormat, iPos, hParams);
		}
		case 98:
		{
			new iValue = GetArrayCell(hParams, 0, 0, false);
			RemoveFromArray(hParams, 0);
			return json_boolean(iValue);
		}
		case 102, 114:
		{
			new Float:iValue = GetArrayCell(hParams, 0, 0, false);
			RemoveFromArray(hParams, 0);
			return json_real(iValue);
		}
		case 105:
		{
			new iValue = GetArrayCell(hParams, 0, 0, false);
			RemoveFromArray(hParams, 0);
			return json_integer(iValue);
		}
		case 110:
		{
			return json_null();
		}
		case 115:
		{
			decl String:sKey[256];
			GetArrayString(hParams, 0, sKey, 255);
			RemoveFromArray(hParams, 0);
			return json_string(sKey);
		}
		case 123:
		{
			return .3520.json_pack_object_(sFormat, iPos, hParams);
		}
		default:
		{
			SetFailState("Invalid pack String '%s'. Type '%s' not supported at %i", sFormat, this_char, iPos);
			return json_null();
		}
	}
}

public .4300.json_pack_element_(String:sFormat[], &iPos, Handle:hParams)
{
	new this_char = sFormat[iPos];
	while (this_char == 32 || this_char == 58 || this_char == 44)
	{
		new var2 = iPos;
		var2++;
		iPos = var2;
		this_char = sFormat[iPos];
	}
	new var3 = iPos;
	var3++;
	iPos = var3;
	switch (this_char)
	{
		case 91:
		{
			return .2972.json_pack_array_(sFormat, iPos, hParams);
		}
		case 98:
		{
			new iValue = GetArrayCell(hParams, 0, 0, false);
			RemoveFromArray(hParams, 0);
			return json_boolean(iValue);
		}
		case 102, 114:
		{
			new Float:iValue = GetArrayCell(hParams, 0, 0, false);
			RemoveFromArray(hParams, 0);
			return json_real(iValue);
		}
		case 105:
		{
			new iValue = GetArrayCell(hParams, 0, 0, false);
			RemoveFromArray(hParams, 0);
			return json_integer(iValue);
		}
		case 110:
		{
			return json_null();
		}
		case 115:
		{
			decl String:sKey[256];
			GetArrayString(hParams, 0, sKey, 255);
			RemoveFromArray(hParams, 0);
			return json_string(sKey);
		}
		case 123:
		{
			return .3520.json_pack_object_(sFormat, iPos, hParams);
		}
		default:
		{
			SetFailState("Invalid pack String '%s'. Type '%s' not supported at %i", sFormat, this_char, iPos);
			return json_null();
		}
	}
}

public .5492.JsonObjectGetInt(Handle:hElement, String:key[])
{
	new Handle:hObject = json_object_get(hElement, key);
	if (hObject)
	{
		new value;
		if (json_typeof(hObject) == 3)
		{
			value = json_integer_value(hObject);
		}
		else
		{
			if (json_typeof(hObject) == 2)
			{
				new String:buffer[12];
				json_string_value(hObject, buffer, 12);
				value = StringToInt(buffer, 10);
			}
		}
		CloseHandle(hObject);
		return value;
	}
	return 0;
}

public .5492.JsonObjectGetInt(Handle:hElement, String:key[])
{
	new Handle:hObject = json_object_get(hElement, key);
	if (hObject)
	{
		new value;
		if (json_typeof(hObject) == 3)
		{
			value = json_integer_value(hObject);
		}
		else
		{
			if (json_typeof(hObject) == 2)
			{
				new String:buffer[12];
				json_string_value(hObject, buffer, 12);
				value = StringToInt(buffer, 10);
			}
		}
		CloseHandle(hObject);
		return value;
	}
	return 0;
}

public .5884.JsonObjectGetString(Handle:hElement, String:key[], String:buffer[], maxlength)
{
	new Handle:hObject = json_object_get(hElement, key);
	if (hObject)
	{
		if (json_typeof(hObject) == 3)
		{
			IntToString(json_integer_value(hObject), buffer, maxlength);
		}
		else
		{
			if (json_typeof(hObject) == 2)
			{
				json_string_value(hObject, buffer, maxlength);
			}
			if (json_typeof(hObject) == 4)
			{
				FloatToString(json_real_value(hObject), buffer, maxlength);
			}
			if (json_typeof(hObject) == 5)
			{
				FormatEx(buffer, maxlength, "true");
			}
			if (json_typeof(hObject) == 6)
			{
				FormatEx(buffer, maxlength, "false");
			}
		}
		CloseHandle(hObject);
		return 1;
	}
	return 0;
}

public .5884.JsonObjectGetString(Handle:hElement, String:key[], String:buffer[], maxlength)
{
	new Handle:hObject = json_object_get(hElement, key);
	if (hObject)
	{
		if (json_typeof(hObject) == 3)
		{
			IntToString(json_integer_value(hObject), buffer, maxlength);
		}
		else
		{
			if (json_typeof(hObject) == 2)
			{
				json_string_value(hObject, buffer, maxlength);
			}
			if (json_typeof(hObject) == 4)
			{
				FloatToString(json_real_value(hObject), buffer, maxlength);
			}
			if (json_typeof(hObject) == 5)
			{
				FormatEx(buffer, maxlength, "true");
			}
			if (json_typeof(hObject) == 6)
			{
				FormatEx(buffer, maxlength, "false");
			}
		}
		CloseHandle(hObject);
		return 1;
	}
	return 0;
}

public .6456.JsonObjectGetBool(Handle:hElement, String:key[], bool:defaultvalue)
{
	new Handle:hObject = json_object_get(hElement, key);
	if (hObject)
	{
		new bool:ObjectBool = defaultvalue;
		if (json_typeof(hObject) == 3)
		{
			ObjectBool = json_integer_value(hObject);
		}
		else
		{
			if (json_typeof(hObject) == 2)
			{
				new String:buffer[12];
				json_string_value(hObject, buffer, 11);
				if (.2920.StrEqual(buffer, "true", false))
				{
					ObjectBool = true;
				}
				else
				{
					if (.2920.StrEqual(buffer, "false", false))
					{
						ObjectBool = false;
					}
					new x = StringToInt(buffer, 10);
					ObjectBool = x;
				}
			}
			if (json_typeof(hObject) == 4)
			{
				ObjectBool = RoundToFloor(json_real_value(hObject));
			}
			if (json_typeof(hObject) == 5)
			{
				ObjectBool = true;
			}
			if (json_typeof(hObject) == 6)
			{
				ObjectBool = false;
			}
		}
		CloseHandle(hObject);
		return ObjectBool;
	}
	return defaultvalue;
}

public .6456.JsonObjectGetBool(Handle:hElement, String:key[], bool:defaultvalue)
{
	new Handle:hObject = json_object_get(hElement, key);
	if (hObject)
	{
		new bool:ObjectBool = defaultvalue;
		if (json_typeof(hObject) == 3)
		{
			ObjectBool = json_integer_value(hObject);
		}
		else
		{
			if (json_typeof(hObject) == 2)
			{
				new String:buffer[12];
				json_string_value(hObject, buffer, 11);
				if (.2920.StrEqual(buffer, "true", false))
				{
					ObjectBool = true;
				}
				else
				{
					if (.2920.StrEqual(buffer, "false", false))
					{
						ObjectBool = false;
					}
					new x = StringToInt(buffer, 10);
					ObjectBool = x;
				}
			}
			if (json_typeof(hObject) == 4)
			{
				ObjectBool = RoundToFloor(json_real_value(hObject));
			}
			if (json_typeof(hObject) == 5)
			{
				ObjectBool = true;
			}
			if (json_typeof(hObject) == 6)
			{
				ObjectBool = false;
			}
		}
		CloseHandle(hObject);
		return ObjectBool;
	}
	return defaultvalue;
}

public .7264.JsonObjectGetFloat(Handle:hJson, String:key[], Float:defaultValue)
{
	new Handle:hObject = json_object_get(hJson, key);
	if (hObject)
	{
		new Float:value = defaultValue;
		if (json_typeof(hObject) == 3)
		{
			value = float(json_integer_value(hObject));
		}
		else
		{
			if (json_typeof(hObject) == 4)
			{
				value = json_real_value(hObject);
			}
			if (json_typeof(hObject) == 2)
			{
				new String:buffer[12];
				json_string_value(hObject, buffer, 12);
				value = StringToFloat(buffer);
			}
		}
		CloseHandle(hObject);
		return value;
	}
	return defaultValue;
}

public .7264.JsonObjectGetFloat(Handle:hJson, String:key[], Float:defaultValue)
{
	new Handle:hObject = json_object_get(hJson, key);
	if (hObject)
	{
		new Float:value = defaultValue;
		if (json_typeof(hObject) == 3)
		{
			value = float(json_integer_value(hObject));
		}
		else
		{
			if (json_typeof(hObject) == 4)
			{
				value = json_real_value(hObject);
			}
			if (json_typeof(hObject) == 2)
			{
				new String:buffer[12];
				json_string_value(hObject, buffer, 12);
				value = StringToFloat(buffer);
			}
		}
		CloseHandle(hObject);
		return value;
	}
	return defaultValue;
}

public .7764.DiscordChannel.GetID(DiscordChannel:this, String:buffer[], maxlength)
{
	.5884.JsonObjectGetString(this, "id", buffer, maxlength);
	return 0;
}

public .7764.DiscordChannel.GetID(DiscordChannel:this, String:buffer[], maxlength)
{
	.5884.JsonObjectGetString(this, "id", buffer, maxlength);
	return 0;
}

public .7828.DiscordChannel.GetLastMessageID(DiscordChannel:this, String:buffer[], maxlength)
{
	.5884.JsonObjectGetString(this, "last_message_id", buffer, maxlength);
	return 0;
}

public .7828.DiscordChannel.GetLastMessageID(DiscordChannel:this, String:buffer[], maxlength)
{
	.5884.JsonObjectGetString(this, "last_message_id", buffer, maxlength);
	return 0;
}

public .7892.DiscordChannel.SetLastMessageID(DiscordChannel:this, String:id[])
{
	json_object_set_new(this, "last_message_id", json_string(id));
	return 0;
}

public .7892.DiscordChannel.SetLastMessageID(DiscordChannel:this, String:id[])
{
	json_object_set_new(this, "last_message_id", json_string(id));
	return 0;
}

public .7964.DiscordWebHook.GetUrl(DiscordWebHook:this, String:buffer[], maxlength)
{
	.5884.JsonObjectGetString(this, "__url", buffer, maxlength);
	return 0;
}

public .7964.DiscordWebHook.GetUrl(DiscordWebHook:this, String:buffer[], maxlength)
{
	.5884.JsonObjectGetString(this, "__url", buffer, maxlength);
	return 0;
}

public .8028.DiscordWebHook.SlackMode.get(DiscordWebHook:this)
{
	return .6456.JsonObjectGetBool(this, "__slack", false);
}

public .8028.DiscordWebHook.SlackMode.get(DiscordWebHook:this)
{
	return .6456.JsonObjectGetBool(this, "__slack", false);
}

public .8080.DiscordWebHook.Data.get(DiscordWebHook:this)
{
	return json_object_get(this, "__data");
}

public .8080.DiscordWebHook.Data.get(DiscordWebHook:this)
{
	return json_object_get(this, "__data");
}

public .8124.DiscordBot.MessageCheckInterval.get(DiscordBot:this)
{
	return .7264.JsonObjectGetFloat(this, "messageInterval", 3.0);
}

public .8124.DiscordBot.MessageCheckInterval.get(DiscordBot:this)
{
	return .7264.JsonObjectGetFloat(this, "messageInterval", 3.0);
}

public .8176.DiscordBot.GetListeningChannels(DiscordBot:this)
{
	return json_object_get(this, "listeningChannels");
}

public .8176.DiscordBot.GetListeningChannels(DiscordBot:this)
{
	return json_object_get(this, "listeningChannels");
}

public .8220.DiscordBot.IsListeningToChannel(DiscordBot:this, DiscordChannel:Channel)
{
	new String:id[32];
	.7764.DiscordChannel.GetID(Channel, id, 32);
	new Handle:hChannels = .8176.DiscordBot.GetListeningChannels(this);
	if (hChannels)
	{
		new i;
		while (json_array_size(hChannels) > i)
		{
			new DiscordChannel:tempChannel = json_array_get(hChannels, i);
			static String:tempID[32];
			.7764.DiscordChannel.GetID(tempChannel, tempID, 32);
			if (.2920.StrEqual(id, tempID, false))
			{
				CloseHandle(tempChannel);
				tempChannel = MissingTAG:0;
				CloseHandle(hChannels);
				hChannels = MissingTAG:0;
				return 1;
			}
			CloseHandle(tempChannel);
			tempChannel = MissingTAG:0;
			i++;
		}
		CloseHandle(hChannels);
		hChannels = MissingTAG:0;
		return 0;
	}
	return 0;
}

public .8220.DiscordBot.IsListeningToChannel(DiscordBot:this, DiscordChannel:Channel)
{
	new String:id[32];
	.7764.DiscordChannel.GetID(Channel, id, 32);
	new Handle:hChannels = .8176.DiscordBot.GetListeningChannels(this);
	if (hChannels)
	{
		new i;
		while (json_array_size(hChannels) > i)
		{
			new DiscordChannel:tempChannel = json_array_get(hChannels, i);
			static String:tempID[32];
			.7764.DiscordChannel.GetID(tempChannel, tempID, 32);
			if (.2920.StrEqual(id, tempID, false))
			{
				CloseHandle(tempChannel);
				tempChannel = MissingTAG:0;
				CloseHandle(hChannels);
				hChannels = MissingTAG:0;
				return 1;
			}
			CloseHandle(tempChannel);
			tempChannel = MissingTAG:0;
			i++;
		}
		CloseHandle(hChannels);
		hChannels = MissingTAG:0;
		return 0;
	}
	return 0;
}

public .8828.DiscordBot.IsListeningToChannelID(DiscordBot:this, String:id[])
{
	new Handle:hChannels = .8176.DiscordBot.GetListeningChannels(this);
	if (hChannels)
	{
		new i;
		while (json_array_size(hChannels) > i)
		{
			new DiscordChannel:tempChannel = json_array_get(hChannels, i);
			static String:tempID[32];
			.7764.DiscordChannel.GetID(tempChannel, tempID, 32);
			if (.2920.StrEqual(id, tempID, false))
			{
				CloseHandle(tempChannel);
				tempChannel = MissingTAG:0;
				CloseHandle(hChannels);
				hChannels = MissingTAG:0;
				return 1;
			}
			CloseHandle(tempChannel);
			tempChannel = MissingTAG:0;
			i++;
		}
		CloseHandle(hChannels);
		hChannels = MissingTAG:0;
		return 0;
	}
	return 0;
}

public .8828.DiscordBot.IsListeningToChannelID(DiscordBot:this, String:id[])
{
	new Handle:hChannels = .8176.DiscordBot.GetListeningChannels(this);
	if (hChannels)
	{
		new i;
		while (json_array_size(hChannels) > i)
		{
			new DiscordChannel:tempChannel = json_array_get(hChannels, i);
			static String:tempID[32];
			.7764.DiscordChannel.GetID(tempChannel, tempID, 32);
			if (.2920.StrEqual(id, tempID, false))
			{
				CloseHandle(tempChannel);
				tempChannel = MissingTAG:0;
				CloseHandle(hChannels);
				hChannels = MissingTAG:0;
				return 1;
			}
			CloseHandle(tempChannel);
			tempChannel = MissingTAG:0;
			i++;
		}
		CloseHandle(hChannels);
		hChannels = MissingTAG:0;
		return 0;
	}
	return 0;
}

public .9360.DiscordRequest.DiscordRequest(String:url[], EHTTPMethod:method)
{
	new Handle:request = SteamWorks_CreateHTTPRequest(method, url);
	return request;
}

public .9360.DiscordRequest.DiscordRequest(String:url[], EHTTPMethod:method)
{
	new Handle:request = SteamWorks_CreateHTTPRequest(method, url);
	return request;
}

public .9436.DiscordRequest.SetJsonBodyEx(DiscordRequest:this, Handle:hJson)
{
	static String:stringJson[16384];
	stringJson[0] = 0;
	if (hJson)
	{
		json_dump(hJson, stringJson, 16384, 0, true, false, false);
	}
	SteamWorks_SetHTTPRequestRawPostBody(this, "application/json; charset=UTF-8", stringJson, strlen(stringJson));
	return 0;
}

public .9436.DiscordRequest.SetJsonBodyEx(DiscordRequest:this, Handle:hJson)
{
	static String:stringJson[16384];
	stringJson[0] = 0;
	if (hJson)
	{
		json_dump(hJson, stringJson, 16384, 0, true, false, false);
	}
	SteamWorks_SetHTTPRequestRawPostBody(this, "application/json; charset=UTF-8", stringJson, strlen(stringJson));
	return 0;
}

public .9620.DiscordRequest.SetCallbacks(DiscordRequest:this, SteamWorksHTTPRequestCompleted:OnComplete, SteamWorksHTTPDataReceived:DataReceived)
{
	SteamWorks_SetHTTPCallbacks(this, OnComplete, SteamWorksHTTPHeadersReceived:121, DataReceived, Handle:0);
	return 0;
}

public .9620.DiscordRequest.SetCallbacks(DiscordRequest:this, SteamWorksHTTPRequestCompleted:OnComplete, SteamWorksHTTPDataReceived:DataReceived)
{
	SteamWorks_SetHTTPCallbacks(this, OnComplete, SteamWorksHTTPHeadersReceived:121, DataReceived, Handle:0);
	return 0;
}

public .9692.DiscordRequest.SetContextValue(DiscordRequest:this, any:data1, any:data2)
{
	SteamWorks_SetHTTPRequestContextValue(this, data1, data2);
	return 0;
}

public .9692.DiscordRequest.SetContextValue(DiscordRequest:this, any:data1, any:data2)
{
	SteamWorks_SetHTTPRequestContextValue(this, data1, data2);
	return 0;
}

public .9740.DiscordRequest.SetData(DiscordRequest:this, any:data1, String:route[])
{
	SteamWorks_SetHTTPRequestContextValue(this, data1, UrlToDP(route));
	return 0;
}

public .9740.DiscordRequest.SetData(DiscordRequest:this, any:data1, String:route[])
{
	SteamWorks_SetHTTPRequestContextValue(this, data1, UrlToDP(route));
	return 0;
}

public .9812.DiscordRequest.SetBot(DiscordRequest:this, DiscordBot:bot)
{
	.46632.BuildAuthHeader(this, bot);
	return 0;
}

public .9812.DiscordRequest.SetBot(DiscordRequest:this, DiscordBot:bot)
{
	.46632.BuildAuthHeader(this, bot);
	return 0;
}

public .9860.DiscordRequest.Send(DiscordRequest:this, String:route[])
{
	DiscordSendRequest(this, route);
	return 0;
}

public .9860.DiscordRequest.Send(DiscordRequest:this, String:route[])
{
	DiscordSendRequest(this, route);
	return 0;
}

public Native_DiscordBot_SendMessageToChannel(Handle:plugin, numParams)
{
	new DiscordBot:bot = GetNativeCell(1);
	new String:channel[32];
	static String:message[2048];
	GetNativeString(2, channel, 32, 0);
	GetNativeString(3, message, 2048, 0);
	new Function:fCallback = GetNativeCell(4);
	new any:data = GetNativeCell(5);
	new Handle:fForward;
	if (fCallback != -1)
	{
		fForward = CreateForward(ExecType:0, 2, 2, 2, 2);
		AddToForward(fForward, plugin, fCallback);
	}
	.11656.SendMessage(bot, channel, message, fForward, data);
	return 0;
}

public Native_DiscordBot_SendMessage(Handle:plugin, numParams)
{
	new DiscordBot:bot = GetNativeCell(1);
	new DiscordChannel:Channel = GetNativeCell(2);
	new String:channelID[32];
	.7764.DiscordChannel.GetID(Channel, channelID, 32);
	static String:message[2048];
	GetNativeString(3, message, 2048, 0);
	new Function:fCallback = GetNativeCell(4);
	new any:data = GetNativeCell(5);
	new Handle:fForward;
	if (fCallback != -1)
	{
		fForward = CreateForward(ExecType:0, 2, 2, 2, 2);
		AddToForward(fForward, plugin, fCallback);
	}
	.11656.SendMessage(bot, channelID, message, fForward, data);
	return 0;
}

public Native_DiscordChannel_SendMessage(Handle:plugin, numParams)
{
	new DiscordChannel:channel = GetNativeCell(1);
	new String:channelID[32];
	.7764.DiscordChannel.GetID(channel, channelID, 32);
	new DiscordBot:bot = GetNativeCell(2);
	static String:message[2048];
	GetNativeString(3, message, 2048, 0);
	new Function:fCallback = GetNativeCell(4);
	new any:data = GetNativeCell(5);
	new Handle:fForward;
	if (fCallback != -1)
	{
		fForward = CreateForward(ExecType:0, 2, 2, 2, 2);
		AddToForward(fForward, plugin, fCallback);
	}
	.11656.SendMessage(bot, channelID, message, fForward, data);
	return 0;
}

public .11656.SendMessage(DiscordBot:bot, String:channel[], String:message[], Handle:fForward, any:data)
{
	new Handle:hJson = json_object();
	json_object_set_new(hJson, "content", json_string(message));
	new String:url[64];
	FormatEx(url, 64, "channels/%s/messages", channel);
	new DataPack:dpSafety = DataPack.DataPack();
	WritePackCell(dpSafety, bot);
	WritePackString(dpSafety, channel);
	WritePackString(dpSafety, message);
	WritePackCell(dpSafety, fForward);
	WritePackCell(dpSafety, data);
	new Handle:request = .46772.PrepareRequest(bot, url, EHTTPMethod:3, hJson, SteamWorksHTTPDataReceived:115, SteamWorksHTTPRequestCompleted:-1);
	if (request)
	{
		SteamWorks_SetHTTPRequestContextValue(request, dpSafety, UrlToDP(url));
		DiscordSendRequest(request, url);
		return 0;
	}
	CloseHandle(hJson);
	hJson = MissingTAG:0;
	CreateTimer(2.0, SendMessageDelayed, dpSafety, 0);
	return 0;
}

public .11656.SendMessage(DiscordBot:bot, String:channel[], String:message[], Handle:fForward, any:data)
{
	new Handle:hJson = json_object();
	json_object_set_new(hJson, "content", json_string(message));
	new String:url[64];
	FormatEx(url, 64, "channels/%s/messages", channel);
	new DataPack:dpSafety = DataPack.DataPack();
	WritePackCell(dpSafety, bot);
	WritePackString(dpSafety, channel);
	WritePackString(dpSafety, message);
	WritePackCell(dpSafety, fForward);
	WritePackCell(dpSafety, data);
	new Handle:request = .46772.PrepareRequest(bot, url, EHTTPMethod:3, hJson, SteamWorksHTTPDataReceived:115, SteamWorksHTTPRequestCompleted:-1);
	if (request)
	{
		SteamWorks_SetHTTPRequestContextValue(request, dpSafety, UrlToDP(url));
		DiscordSendRequest(request, url);
		return 0;
	}
	CloseHandle(hJson);
	hJson = MissingTAG:0;
	CreateTimer(2.0, SendMessageDelayed, dpSafety, 0);
	return 0;
}

public Action:SendMessageDelayed(Handle:timer, any:data)
{
	new DataPack:dp = data;
	ResetPack(dp, false);
	new DiscordBot:bot = ReadPackCell(dp);
	new String:channel[32];
	ReadPackString(dp, channel, 32);
	new String:message[2048];
	ReadPackString(dp, message, 2048);
	new Handle:fForward = ReadPackCell(dp);
	new any:dataa = ReadPackCell(dp);
	CloseHandle(dp);
	dp = MissingTAG:0;
	.11656.SendMessage(bot, channel, message, fForward, dataa);
	return Action:0;
}

public GetSendMessageData(Handle:request, bool:failure, offset, statuscode, any:dp)
{
	new var1;
	if (failure || statuscode == 200)
	{
		new var2;
		if (statuscode == 429 || statuscode == 500)
		{
			ResetPack(dp, false);
			new DiscordBot:bot = ReadPackCell(dp);
			new String:channel[32];
			ReadPackString(dp, channel, 32);
			new String:message[2048];
			ReadPackString(dp, message, 2048);
			new Handle:fForward = ReadPackCell(dp);
			new any:data = ReadPackCell(dp);
			CloseHandle(dp);
			dp = MissingTAG:0;
			.11656.SendMessage(bot, channel, message, fForward, data);
			CloseHandle(request);
			request = MissingTAG:0;
			return 0;
		}
		LogError("[DISCORD] Couldn't Send Message - Fail %i %i", failure, statuscode);
		CloseHandle(request);
		request = MissingTAG:0;
		CloseHandle(dp);
		dp = MissingTAG:0;
		return 0;
	}
	CloseHandle(request);
	request = MissingTAG:0;
	CloseHandle(dp);
	dp = MissingTAG:0;
	return 0;
}

public Native_DiscordBot_GetGuilds(Handle:plugin, numParams)
{
	new DiscordBot:bot = GetNativeCell(1);
	new Function:fCallback = GetNativeCell(2);
	new Function:fCallbackAll = GetNativeCell(3);
	new any:data = GetNativeCell(4);
	new DataPack:dp = CreateDataPack();
	WritePackCell(dp, bot);
	WritePackCell(dp, plugin);
	WritePackFunction(dp, fCallback);
	WritePackFunction(dp, fCallbackAll);
	WritePackCell(dp, data);
	.13948.ThisSendRequest(bot, dp);
	return 0;
}

public .13948.ThisSendRequest(DiscordBot:bot, DataPack:dp)
{
	new String:url[64];
	FormatEx(url, 64, "users/@me/guilds");
	new Handle:request = .46772.PrepareRequest(bot, url, EHTTPMethod:1, Handle:0, SteamWorksHTTPDataReceived:93, SteamWorksHTTPRequestCompleted:-1);
	if (request)
	{
		SteamWorks_SetHTTPRequestContextValue(request, dp, UrlToDP(url));
		DiscordSendRequest(request, url);
		return 0;
	}
	CreateTimer(2.0, GetGuildsDelayed, dp, 0);
	return 0;
}

public Action:GetGuildsDelayed(Handle:timer, any:data)
{
	new DataPack:dp = data;
	ResetPack(dp, false);
	new DiscordBot:bot = ReadPackCell(dp);
	.13948.ThisSendRequest(bot, dp);
	return Action:0;
}

public GetGuildsData(Handle:request, bool:failure, offset, statuscode, any:dp)
{
	new var1;
	if (failure || statuscode == 200)
	{
		new var2;
		if (statuscode == 429 || statuscode == 500)
		{
			ResetPack(dp, false);
			new DiscordBot:bot = ReadPackCell(dp);
			.13948.ThisSendRequest(bot, dp);
			CloseHandle(request);
			request = MissingTAG:0;
			return 0;
		}
		LogError("[DISCORD] Couldn't Retrieve Guilds - Fail %i %i", failure, statuscode);
		CloseHandle(request);
		request = MissingTAG:0;
		CloseHandle(dp);
		dp = MissingTAG:0;
		return 0;
	}
	SteamWorks_GetHTTPResponseBodyCallback(request, SteamWorksHTTPBodyCallback:95, dp, Handle:0);
	CloseHandle(request);
	request = MissingTAG:0;
	return 0;
}

public GetGuildsData_Data(String:data[], any:datapack)
{
	new Handle:hJson = json_load(data);
	new Handle:dp = datapack;
	ResetPack(dp, false);
	new bot = ReadPackCell(dp);
	new Handle:plugin = ReadPackCell(dp);
	new Function:func = ReadPackFunction(dp);
	new Function:funcAll = ReadPackFunction(dp);
	new any:pluginData = ReadPackCell(dp);
	CloseHandle(dp);
	dp = MissingTAG:0;
	new Handle:fForward;
	new Handle:fForwardAll;
	if (func != -1)
	{
		fForward = CreateForward(ExecType:0, 2, 7, 7, 7, 2, 2, 2);
		AddToForward(fForward, plugin, func);
	}
	if (funcAll != -1)
	{
		fForwardAll = CreateForward(ExecType:0, 2, 2, 2, 2, 2, 2, 2);
		AddToForward(fForwardAll, plugin, funcAll);
	}
	new ArrayList:alId;
	new ArrayList:alName;
	new ArrayList:alIcon;
	new ArrayList:alOwner;
	new ArrayList:alPermissions;
	if (funcAll != -1)
	{
		alId = CreateArray(32, 0);
		alName = CreateArray(64, 0);
		alIcon = CreateArray(128, 0);
		alOwner = CreateArray(1, 0);
		alPermissions = CreateArray(1, 0);
	}
	new i;
	while (json_array_size(hJson) > i)
	{
		new Handle:hObject = json_array_get(hJson, i);
		static String:id[32];
		static String:name[64];
		static String:icon[128];
		new bool:owner;
		new permissions;
		.5884.JsonObjectGetString(hObject, "id", id, 32);
		.5884.JsonObjectGetString(hObject, "name", name, 64);
		.5884.JsonObjectGetString(hObject, "icon", icon, 128);
		owner = .6456.JsonObjectGetBool(hObject, "owner", false);
		permissions = .6456.JsonObjectGetBool(hObject, "permissions", false);
		if (fForward)
		{
			Call_StartForward(fForward);
			Call_PushCell(bot);
			Call_PushString(id);
			Call_PushString(name);
			Call_PushString(icon);
			Call_PushCell(owner);
			Call_PushCell(permissions);
			Call_PushCell(pluginData);
			Call_Finish(0);
		}
		if (fForwardAll)
		{
			ArrayList.PushString(alId, id);
			ArrayList.PushString(alName, name);
			ArrayList.PushString(alIcon, icon);
			ArrayList.Push(alOwner, owner);
			ArrayList.Push(alPermissions, permissions);
		}
		CloseHandle(hObject);
		hObject = MissingTAG:0;
		i++;
	}
	if (fForwardAll)
	{
		Call_StartForward(fForwardAll);
		Call_PushCell(bot);
		Call_PushCell(alId);
		Call_PushCell(alName);
		Call_PushCell(alIcon);
		Call_PushCell(alOwner);
		Call_PushCell(alPermissions);
		Call_PushCell(pluginData);
		Call_Finish(0);
		CloseHandle(alId);
		alId = MissingTAG:0;
		CloseHandle(alName);
		alName = MissingTAG:0;
		CloseHandle(alIcon);
		alIcon = MissingTAG:0;
		CloseHandle(alOwner);
		alOwner = MissingTAG:0;
		CloseHandle(alPermissions);
		alPermissions = MissingTAG:0;
		CloseHandle(fForwardAll);
		fForwardAll = MissingTAG:0;
	}
	if (fForward)
	{
		CloseHandle(fForward);
		fForward = MissingTAG:0;
	}
	CloseHandle(hJson);
	hJson = MissingTAG:0;
	return 0;
}

public Native_DiscordBot_GetGuildChannels(Handle:plugin, numParams)
{
	new DiscordBot:bot = GetNativeCell(1);
	new String:guild[32];
	GetNativeString(2, guild, 32, 0);
	new Function:fCallback = GetNativeCell(3);
	new Function:fCallbackAll = GetNativeCell(4);
	new any:data = GetNativeCell(5);
	new DataPack:dp = CreateDataPack();
	WritePackCell(dp, bot);
	WritePackString(dp, guild);
	WritePackCell(dp, plugin);
	WritePackFunction(dp, fCallback);
	WritePackFunction(dp, fCallbackAll);
	WritePackCell(dp, data);
	.18156.ThisSendRequest(bot, guild, dp);
	return 0;
}

public .18156.ThisSendRequest(DiscordBot:bot, String:guild[], DataPack:dp)
{
	new String:url[64];
	FormatEx(url, 64, "guilds/%s/channels", guild);
	new Handle:request = .46772.PrepareRequest(bot, url, EHTTPMethod:1, Handle:0, SteamWorksHTTPDataReceived:85, SteamWorksHTTPRequestCompleted:-1);
	if (request)
	{
		SteamWorks_SetHTTPRequestContextValue(request, dp, UrlToDP(url));
		DiscordSendRequest(request, url);
		return 0;
	}
	CreateTimer(2.0, GetGuildChannelsDelayed, dp, 0);
	return 0;
}

public .18156.ThisSendRequest(DiscordBot:bot, String:guild[], DataPack:dp)
{
	new String:url[64];
	FormatEx(url, 64, "guilds/%s/channels", guild);
	new Handle:request = .46772.PrepareRequest(bot, url, EHTTPMethod:1, Handle:0, SteamWorksHTTPDataReceived:85, SteamWorksHTTPRequestCompleted:-1);
	if (request)
	{
		SteamWorks_SetHTTPRequestContextValue(request, dp, UrlToDP(url));
		DiscordSendRequest(request, url);
		return 0;
	}
	CreateTimer(2.0, GetGuildChannelsDelayed, dp, 0);
	return 0;
}

public Action:GetGuildChannelsDelayed(Handle:timer, any:data)
{
	new DataPack:dp = data;
	ResetPack(dp, false);
	new DiscordBot:bot = ReadPackCell(dp);
	new String:guild[32];
	ReadPackString(dp, guild, 32);
	.18156.ThisSendRequest(bot, guild, dp);
	return Action:0;
}

public GetGuildChannelsData(Handle:request, bool:failure, offset, statuscode, any:dp)
{
	new var1;
	if (failure || statuscode == 200)
	{
		new var2;
		if (statuscode == 429 || statuscode == 500)
		{
			ResetPack(dp, false);
			new DiscordBot:bot = ReadPackCell(dp);
			new String:guild[32];
			ReadPackString(dp, guild, 32);
			.18156.ThisSendRequest(bot, guild, dp);
			CloseHandle(request);
			request = MissingTAG:0;
			return 0;
		}
		LogError("[DISCORD] Couldn't Retrieve Guild Channels - Fail %i %i", failure, statuscode);
		CloseHandle(request);
		request = MissingTAG:0;
		CloseHandle(dp);
		dp = MissingTAG:0;
		return 0;
	}
	SteamWorks_GetHTTPResponseBodyCallback(request, SteamWorksHTTPBodyCallback:87, dp, Handle:0);
	CloseHandle(request);
	request = MissingTAG:0;
	return 0;
}

public GetGuildChannelsData_Data(String:data[], any:datapack)
{
	new Handle:hJson = json_load(data);
	new Handle:dp = datapack;
	ResetPack(dp, false);
	new bot = ReadPackCell(dp);
	new String:guild[32];
	ReadPackString(dp, guild, 32);
	new Handle:plugin = ReadPackCell(dp);
	new Function:func = ReadPackFunction(dp);
	new Function:funcAll = ReadPackFunction(dp);
	new any:pluginData = ReadPackCell(dp);
	CloseHandle(dp);
	dp = MissingTAG:0;
	new Handle:fForward;
	new Handle:fForwardAll;
	if (func != -1)
	{
		fForward = CreateForward(ExecType:0, 2, 7, 2, 2);
		AddToForward(fForward, plugin, func);
	}
	if (funcAll != -1)
	{
		fForwardAll = CreateForward(ExecType:0, 2, 7, 2, 2);
		AddToForward(fForwardAll, plugin, funcAll);
	}
	new ArrayList:alChannels;
	if (funcAll != -1)
	{
		alChannels = CreateArray(1, 0);
	}
	new i;
	while (json_array_size(hJson) > i)
	{
		new Handle:hObject = json_array_get(hJson, i);
		new DiscordChannel:Channel = hObject;
		if (fForward)
		{
			Call_StartForward(fForward);
			Call_PushCell(bot);
			Call_PushString(guild);
			Call_PushCell(Channel);
			Call_PushCell(pluginData);
			Call_Finish(0);
		}
		if (fForwardAll)
		{
			ArrayList.Push(alChannels, Channel);
		}
		else
		{
			CloseHandle(Channel);
			Channel = MissingTAG:0;
		}
		i++;
	}
	if (fForwardAll)
	{
		Call_StartForward(fForwardAll);
		Call_PushCell(bot);
		Call_PushString(guild);
		Call_PushCell(alChannels);
		Call_PushCell(pluginData);
		Call_Finish(0);
		new i;
		while (ArrayList.Length.get(alChannels) > i)
		{
			new Handle:hChannel = ArrayList.Get(alChannels, i, 0, false);
			CloseHandle(hChannel);
			hChannel = MissingTAG:0;
			i++;
		}
		CloseHandle(alChannels);
		alChannels = MissingTAG:0;
		CloseHandle(fForwardAll);
		fForwardAll = MissingTAG:0;
	}
	if (fForward)
	{
		CloseHandle(fForward);
		fForward = MissingTAG:0;
	}
	CloseHandle(hJson);
	hJson = MissingTAG:0;
	return 0;
}

public Native_DiscordBot_StartTimer(Handle:plugin, numParams)
{
	new DiscordBot:bot = GetNativeCell(1);
	new DiscordChannel:channel = GetNativeCell(2);
	new Function:func = GetNativeCell(3);
	new Handle:hObj = json_object();
	json_object_set(hObj, "bot", bot);
	json_object_set(hObj, "channel", channel);
	new Handle:fwd = CreateForward(ExecType:0, 2, 2, 2);
	AddToForward(fwd, plugin, func);
	json_object_set_new(hObj, "callback", json_integer(fwd));
	GetMessages(hObj);
	return 0;
}

public void:GetMessages(Handle:hObject)
{
	new DiscordBot:bot = json_object_get(hObject, "bot");
	new DiscordChannel:channel = json_object_get(hObject, "channel");
	new String:channelID[32];
	.7764.DiscordChannel.GetID(channel, channelID, 32);
	new String:lastMessage[64];
	.7828.DiscordChannel.GetLastMessageID(channel, lastMessage, 64);
	new String:url[256];
	FormatEx(url, 256, "channels/%s/messages?limit=%i&after=%s", channelID, 100, lastMessage);
	new Handle:request = .46772.PrepareRequest(bot, url, EHTTPMethod:1, Handle:0, SteamWorksHTTPDataReceived:177, SteamWorksHTTPRequestCompleted:-1);
	if (request)
	{
		new String:route[128];
		FormatEx(route, 128, "channels/%s", channelID);
		SteamWorks_SetHTTPRequestContextValue(request, hObject, UrlToDP(route));
		CloseHandle(bot);
		bot = MissingTAG:0;
		CloseHandle(channel);
		channel = MissingTAG:0;
		DiscordSendRequest(request, route);
		return void:0;
	}
	CloseHandle(bot);
	bot = MissingTAG:0;
	CloseHandle(channel);
	channel = MissingTAG:0;
	CreateTimer(2.0, GetMessagesDelayed, hObject, 0);
	return void:0;
}

public Action:GetMessagesDelayed(Handle:timer, any:data)
{
	GetMessages(data);
	return Action:0;
}

public Action:CheckMessageTimer(Handle:timer, any:dpt)
{
	GetMessages(dpt);
	return Action:0;
}

public OnGetMessage(Handle:request, bool:failure, offset, statuscode, any:dp)
{
	new var1;
	if (failure || statuscode == 200)
	{
		new var2;
		if (statuscode == 429 || statuscode == 500)
		{
			GetMessages(dp);
			CloseHandle(request);
			request = MissingTAG:0;
			return 0;
		}
		LogError("[DISCORD] Couldn't Retrieve Messages - Fail %i %i", failure, statuscode);
		CloseHandle(request);
		request = MissingTAG:0;
		new Handle:fwd = .5492.JsonObjectGetInt(dp, "callback");
		if (fwd)
		{
			CloseHandle(fwd);
			fwd = MissingTAG:0;
		}
		CloseHandle(dp);
		dp = MissingTAG:0;
		return 0;
	}
	SteamWorks_GetHTTPResponseBodyCallback(request, SteamWorksHTTPBodyCallback:179, dp, Handle:0);
	CloseHandle(request);
	request = MissingTAG:0;
	return 0;
}

public OnGetMessage_Data(String:data[], any:dpt)
{
	new Handle:hObj = dpt;
	new DiscordBot:Bot = json_object_get(hObj, "bot");
	new DiscordChannel:channel = json_object_get(hObj, "channel");
	new Handle:fwd = .5492.JsonObjectGetInt(hObj, "callback");
	new var1;
	if (!.8220.DiscordBot.IsListeningToChannel(Bot, channel) || GetForwardFunctionCount(fwd))
	{
		CloseHandle(Bot);
		Bot = MissingTAG:0;
		CloseHandle(channel);
		channel = MissingTAG:0;
		CloseHandle(hObj);
		hObj = MissingTAG:0;
		CloseHandle(fwd);
		fwd = MissingTAG:0;
		return 0;
	}
	new Handle:hJson = json_load(data);
	if (json_typeof(hJson) == 1)
	{
		new i = json_array_size(hJson) + -1;
		while (0 <= i)
		{
			new Handle:hObject = json_array_get(hJson, i);
			new String:channelID[32];
			.5884.JsonObjectGetString(hObject, "channel_id", channelID, 32);
			if (!.8828.DiscordBot.IsListeningToChannelID(Bot, channelID))
			{
				CloseHandle(hObject);
				hObject = MissingTAG:0;
				CloseHandle(hJson);
				hJson = MissingTAG:0;
				CloseHandle(fwd);
				fwd = MissingTAG:0;
				CloseHandle(Bot);
				Bot = MissingTAG:0;
				CloseHandle(channel);
				channel = MissingTAG:0;
				CloseHandle(hObj);
				hObj = MissingTAG:0;
				return 0;
			}
			new String:id[32];
			.5884.JsonObjectGetString(hObject, "id", id, 32);
			if (!i)
			{
				.7892.DiscordChannel.SetLastMessageID(channel, id);
			}
			if (fwd)
			{
				Call_StartForward(fwd);
				Call_PushCell(Bot);
				Call_PushCell(channel);
				Call_PushCell(hObject);
				Call_Finish(0);
			}
			CloseHandle(hObject);
			hObject = MissingTAG:0;
			i--;
		}
	}
	CreateTimer(.8124.DiscordBot.MessageCheckInterval.get(Bot), CheckMessageTimer, hObj, 0);
	CloseHandle(Bot);
	Bot = MissingTAG:0;
	CloseHandle(channel);
	channel = MissingTAG:0;
	CloseHandle(hJson);
	hJson = MissingTAG:0;
	return 0;
}

public Native_DiscordWebHook_Send(Handle:plugin, numParams)
{
	new DiscordWebHook:hook = GetNativeCell(1);
	SendWebHook(hook);
	return 0;
}

public void:SendWebHook(DiscordWebHook:hook)
{
	if (!.6456.JsonObjectGetBool(hook, "__selfCopy", false))
	{
		hook = json_deep_copy(hook);
		json_object_set_new(hook, "__selfCopy", json_true());
	}
	new Handle:hJson = .8080.DiscordWebHook.Data.get(hook);
	new String:url[256];
	.7964.DiscordWebHook.GetUrl(hook, url, 256);
	if (.8028.DiscordWebHook.SlackMode.get(hook))
	{
		if (StrContains(url, "/slack", true) == -1)
		{
			Format(url, 256, "%s/slack", url);
		}
		.49984.RenameJsonObject(hJson, "content", "text");
		.49984.RenameJsonObject(hJson, "embeds", "attachments");
		new Handle:hAttachments = json_object_get(hJson, "attachments");
		if (hAttachments)
		{
			if (json_typeof(hAttachments) == 1)
			{
				new i;
				while (json_array_size(hAttachments) > i)
				{
					new Handle:hEmbed = json_array_get(hAttachments, i);
					new Handle:hFields = json_object_get(hEmbed, "fields");
					if (hFields)
					{
						if (json_typeof(hFields) == 1)
						{
							new j;
							while (json_array_size(hFields) > j)
							{
								new Handle:hField = json_array_get(hFields, j);
								.49984.RenameJsonObject(hField, "name", "title");
								.49984.RenameJsonObject(hField, "inline", "short");
								CloseHandle(hField);
								hField = MissingTAG:0;
								j++;
							}
						}
						CloseHandle(hFields);
						hFields = MissingTAG:0;
					}
					CloseHandle(hEmbed);
					hEmbed = MissingTAG:0;
					i++;
				}
			}
			CloseHandle(hAttachments);
			hAttachments = MissingTAG:0;
		}
	}
	new DiscordRequest:request = .9360.DiscordRequest.DiscordRequest(url, EHTTPMethod:3);
	.9620.DiscordRequest.SetCallbacks(request, SteamWorksHTTPRequestCompleted:117, SteamWorksHTTPDataReceived:195);
	.9436.DiscordRequest.SetJsonBodyEx(request, hJson);
	if (request)
	{
		.9692.DiscordRequest.SetContextValue(request, hJson, UrlToDP(url));
		.9860.DiscordRequest.Send(request, url);
		return void:0;
	}
	CreateTimer(2.0, SendWebHookDelayed, hJson, 0);
	return void:0;
}

public Action:SendWebHookDelayed(Handle:timer, any:data)
{
	SendWebHook(data);
	return Action:0;
}

public SendWebHookReceiveData(Handle:request, bool:failure, offset, statuscode, any:dp)
{
	new var2;
	if (failure || (statuscode != 200 && statuscode != 204))
	{
		if (statuscode == 400)
		{
			PrintToServer("BAD REQUEST");
			SteamWorks_GetHTTPResponseBodyCallback(request, SteamWorksHTTPBodyCallback:199, dp, Handle:0);
		}
		new var3;
		if (statuscode == 429 || statuscode == 500)
		{
			SendWebHook(dp);
			CloseHandle(request);
			request = MissingTAG:0;
			return 0;
		}
		LogError("[DISCORD] Couldn't Send Webhook - Fail %i %i", failure, statuscode);
		CloseHandle(request);
		request = MissingTAG:0;
		CloseHandle(dp);
		dp = MissingTAG:0;
		return 0;
	}
	CloseHandle(request);
	request = MissingTAG:0;
	CloseHandle(dp);
	dp = MissingTAG:0;
	return 0;
}

public WebHookData(String:data[], any:dp)
{
	PrintToServer("DATA RECE: %s", data);
	static String:stringJson[16384];
	stringJson[0] = 0;
	json_dump(dp, stringJson, 16384, 0, true, false, false);
	PrintToServer("DATA SENT: %s", stringJson);
	return 0;
}

public Native_DiscordBot_AddReaction(Handle:plugin, numParams)
{
	new DiscordBot:bot = GetNativeCell(1);
	new String:channel[32];
	GetNativeString(2, channel, 32, 0);
	new String:msgid[64];
	GetNativeString(3, msgid, 64, 0);
	new String:emoji[128];
	GetNativeString(4, emoji, 128, 0);
	AddReaction(bot, channel, msgid, emoji);
	return 0;
}

public Native_DiscordBot_DeleteReaction(Handle:plugin, numParams)
{
	new DiscordBot:bot = GetNativeCell(1);
	new String:channel[32];
	GetNativeString(2, channel, 32, 0);
	new String:msgid[64];
	GetNativeString(3, msgid, 64, 0);
	new String:emoji[128];
	GetNativeString(4, emoji, 128, 0);
	new String:user[128];
	GetNativeString(5, user, 128, 0);
	DeleteReaction(bot, channel, msgid, emoji, user);
	return 0;
}

public Native_DiscordBot_GetReaction(Handle:plugin, numParams)
{
	new DiscordBot:bot = GetNativeCell(1);
	new String:channel[32];
	GetNativeString(2, channel, 32, 0);
	new String:msgid[64];
	GetNativeString(3, msgid, 64, 0);
	new String:emoji[128];
	GetNativeString(4, emoji, 128, 0);
	new OnGetReactions:fCallback = GetNativeCell(5);
	new Handle:fForward;
	if (fCallback != OnGetReactions:-1)
	{
		fForward = CreateForward(ExecType:0, 2, 2, 7, 7, 7, 7, 2);
		AddToForward(fForward, plugin, fCallback);
	}
	new any:data = GetNativeCell(6);
	GetReaction(bot, channel, msgid, emoji, fForward, data);
	return 0;
}

public void:AddReaction(DiscordBot:bot, String:channel[], String:messageid[], String:emoji[])
{
	new String:url[256];
	FormatEx(url, 256, "channels/%s/messages/%s/reactions/%s/@me", channel, messageid, emoji);
	new Handle:request = .46772.PrepareRequest(bot, url, EHTTPMethod:4, Handle:0, SteamWorksHTTPDataReceived:71, SteamWorksHTTPRequestCompleted:-1);
	new DataPack:dp = DataPack.DataPack();
	WritePackCell(dp, bot);
	WritePackString(dp, channel);
	WritePackString(dp, messageid);
	WritePackString(dp, emoji);
	if (dp == request)
	{
		CreateTimer(2.0, AddReactionDelayed, dp, 0);
		return void:0;
	}
	new String:route[128];
	FormatEx(route, 128, "channels/%s/messages/msgid/reactions", channel);
	SteamWorks_SetHTTPRequestContextValue(request, dp, UrlToDP(route));
	DiscordSendRequest(request, url);
	return void:0;
}

public Action:AddReactionDelayed(Handle:timer, any:data)
{
	new DataPack:dp = data;
	new DiscordBot:bot = ReadPackCell(dp);
	new String:channel[64];
	new String:messageid[64];
	new String:emoji[64];
	ReadPackString(dp, channel, 64);
	ReadPackString(dp, messageid, 64);
	ReadPackString(dp, emoji, 64);
	CloseHandle(dp);
	dp = MissingTAG:0;
	AddReaction(bot, channel, messageid, emoji);
	return Action:0;
}

public AddReactionReceiveData(Handle:request, bool:failure, offset, statuscode, any:data)
{
	new var1;
	if (failure || statuscode == 204)
	{
		new var2;
		if (statuscode == 429 || statuscode == 500)
		{
			new DataPack:dp = data;
			new DiscordBot:bot = ReadPackCell(dp);
			new String:channel[64];
			new String:messageid[64];
			new String:emoji[64];
			ReadPackString(dp, channel, 64);
			ReadPackString(dp, messageid, 64);
			ReadPackString(dp, emoji, 64);
			CloseHandle(dp);
			dp = MissingTAG:0;
			AddReaction(bot, channel, messageid, emoji);
			CloseHandle(request);
			request = MissingTAG:0;
			return 0;
		}
		LogError("[DISCORD] Couldn't Add Reaction - Fail %i %i", failure, statuscode);
		CloseHandle(request);
		request = MissingTAG:0;
		CloseHandle(data);
		data = MissingTAG:0;
		CloseHandle(data);
		data = MissingTAG:0;
		return 0;
	}
	CloseHandle(request);
	request = MissingTAG:0;
	CloseHandle(data);
	data = MissingTAG:0;
	return 0;
}

public void:DeleteReaction(DiscordBot:bot, String:channel[], String:messageid[], String:emoji[], String:userid[])
{
	new String:url[256];
	if (.2920.StrEqual(userid, "@all", true))
	{
		FormatEx(url, 256, "channels/%s/messages/%s/reactions/%s", channel, messageid, emoji);
	}
	else
	{
		FormatEx(url, 256, "channels/%s/messages/%s/reactions/%s/%s", channel, messageid, emoji, userid);
	}
	new Handle:request = .46772.PrepareRequest(bot, url, EHTTPMethod:5, Handle:0, SteamWorksHTTPDataReceived:81, SteamWorksHTTPRequestCompleted:-1);
	new DataPack:dp = DataPack.DataPack();
	WritePackCell(dp, bot);
	WritePackString(dp, channel);
	WritePackString(dp, messageid);
	WritePackString(dp, emoji);
	WritePackString(dp, userid);
	if (dp == request)
	{
		CreateTimer(2.0, DeleteReactionDelayed, dp, 0);
		return void:0;
	}
	new String:route[128];
	FormatEx(route, 128, "channels/%s/messages/msgid/reactions", channel);
	SteamWorks_SetHTTPRequestContextValue(request, dp, UrlToDP(route));
	DiscordSendRequest(request, url);
	return void:0;
}

public Action:DeleteReactionDelayed(Handle:timer, any:data)
{
	new DataPack:dp = data;
	new DiscordBot:bot = ReadPackCell(dp);
	new String:channel[64];
	new String:messageid[64];
	new String:emoji[64];
	new String:userid[64];
	ReadPackString(dp, channel, 64);
	ReadPackString(dp, messageid, 64);
	ReadPackString(dp, emoji, 64);
	ReadPackString(dp, userid, 64);
	CloseHandle(dp);
	dp = MissingTAG:0;
	DeleteReaction(bot, channel, messageid, emoji, userid);
	return Action:0;
}

public DeleteReactionReceiveData(Handle:request, bool:failure, offset, statuscode, any:data)
{
	new var1;
	if (failure || statuscode == 204)
	{
		new var2;
		if (statuscode == 429 || statuscode == 500)
		{
			new DataPack:dp = data;
			new DiscordBot:bot = ReadPackCell(dp);
			new String:channel[64];
			new String:messageid[64];
			new String:emoji[64];
			new String:userid[64];
			ReadPackString(dp, channel, 64);
			ReadPackString(dp, messageid, 64);
			ReadPackString(dp, emoji, 64);
			ReadPackString(dp, userid, 64);
			CloseHandle(dp);
			dp = MissingTAG:0;
			DeleteReaction(bot, channel, messageid, emoji, userid);
			CloseHandle(request);
			request = MissingTAG:0;
			return 0;
		}
		LogError("[DISCORD] Couldn't Delete Reaction - Fail %i %i", failure, statuscode);
		CloseHandle(request);
		request = MissingTAG:0;
		CloseHandle(data);
		data = MissingTAG:0;
		return 0;
	}
	CloseHandle(request);
	request = MissingTAG:0;
	CloseHandle(data);
	data = MissingTAG:0;
	return 0;
}

public void:GetReaction(DiscordBot:bot, String:channel[], String:messageid[], String:emoji[], Handle:fForward, any:data)
{
	new String:url[256];
	FormatEx(url, 256, "channels/%s/messages/%s/reactions/%s", channel, messageid, emoji);
	new Handle:request = .46772.PrepareRequest(bot, url, EHTTPMethod:1, Handle:0, SteamWorksHTTPDataReceived:109, SteamWorksHTTPRequestCompleted:-1);
	new DataPack:dp = DataPack.DataPack();
	WritePackCell(dp, bot);
	WritePackString(dp, channel);
	WritePackString(dp, messageid);
	WritePackString(dp, emoji);
	WritePackCell(dp, fForward);
	WritePackCell(dp, data);
	if (dp == request)
	{
		CreateTimer(2.0, GetReactionDelayed, dp, 0);
		return void:0;
	}
	new String:route[128];
	FormatEx(route, 128, "channels/%s/messages/msgid/reactions", channel);
	SteamWorks_SetHTTPRequestContextValue(request, dp, UrlToDP(route));
	DiscordSendRequest(request, url);
	return void:0;
}

public Action:GetReactionDelayed(Handle:timer, any:data)
{
	new DataPack:dp = data;
	new DiscordBot:bot = ReadPackCell(dp);
	new String:channel[64];
	new String:messageid[64];
	new String:emoji[64];
	ReadPackString(dp, channel, 64);
	ReadPackString(dp, messageid, 64);
	ReadPackString(dp, emoji, 64);
	new Handle:fForward = ReadPackCell(dp);
	new any:addData = ReadPackCell(dp);
	CloseHandle(dp);
	dp = MissingTAG:0;
	GetReaction(bot, channel, messageid, emoji, fForward, addData);
	return Action:0;
}

public GetReactionReceiveData(Handle:request, bool:failure, offset, statuscode, any:data)
{
	new var1;
	if (failure || statuscode == 204)
	{
		new var2;
		if (statuscode == 429 || statuscode == 500)
		{
			new DataPack:dp = data;
			new DiscordBot:bot = ReadPackCell(dp);
			new String:channel[64];
			new String:messageid[64];
			new String:emoji[64];
			ReadPackString(dp, channel, 64);
			ReadPackString(dp, messageid, 64);
			ReadPackString(dp, emoji, 64);
			new Handle:fForward = ReadPackCell(dp);
			new any:addData = ReadPackCell(dp);
			CloseHandle(dp);
			dp = MissingTAG:0;
			GetReaction(bot, channel, messageid, emoji, fForward, addData);
			CloseHandle(request);
			request = MissingTAG:0;
			return 0;
		}
		LogError("[DISCORD] Couldn't Delete Reaction - Fail %i %i", failure, statuscode);
		CloseHandle(request);
		request = MissingTAG:0;
		CloseHandle(data);
		data = MissingTAG:0;
		return 0;
	}
	SteamWorks_GetHTTPResponseBodyCallback(request, SteamWorksHTTPBodyCallback:111, data, Handle:0);
	CloseHandle(request);
	request = MissingTAG:0;
	return 0;
}

public GetReactionsData(String:data[], any:datapack)
{
	new DataPack:dp = datapack;
	new DiscordBot:bot = ReadPackCell(dp);
	new String:channel[64];
	new String:messageid[64];
	new String:emoji[64];
	ReadPackString(dp, channel, 64);
	ReadPackString(dp, messageid, 64);
	ReadPackString(dp, emoji, 64);
	new Handle:fForward = ReadPackCell(dp);
	new any:addData = ReadPackCell(dp);
	CloseHandle(dp);
	dp = MissingTAG:0;
	new Handle:hJson = json_load(data);
	new ArrayList:alUsers = ArrayList.ArrayList(1, 0);
	if (json_typeof(hJson) == 1)
	{
		new i;
		while (json_array_size(hJson) > i)
		{
			new DiscordUser:user = json_array_get(hJson, i);
			ArrayList.Push(alUsers, user);
			i++;
		}
	}
	CloseHandle(hJson);
	hJson = MissingTAG:0;
	if (fForward)
	{
		Call_StartForward(fForward);
		Call_PushCell(bot);
		Call_PushCell(alUsers);
		Call_PushString(channel);
		Call_PushString(messageid);
		Call_PushString(emoji);
		Call_PushCell(addData);
		Call_Finish(0);
	}
	new i;
	while (ArrayList.Length.get(alUsers) > i)
	{
		new DiscordUser:user = ArrayList.Get(alUsers, i, 0, false);
		CloseHandle(user);
		user = MissingTAG:0;
		i++;
	}
	CloseHandle(alUsers);
	alUsers = MissingTAG:0;
	return 0;
}

public Native_DiscordUser_GetID(Handle:plugin, numParams)
{
	new Handle:hJson = GetNativeCell(1);
	new String:buffer[64];
	.5884.JsonObjectGetString(hJson, "id", buffer, 64);
	SetNativeString(2, buffer, GetNativeCell(3), true, 0);
	return 0;
}

public Native_DiscordUser_GetUsername(Handle:plugin, numParams)
{
	new Handle:hJson = GetNativeCell(1);
	new String:buffer[64];
	.5884.JsonObjectGetString(hJson, "username", buffer, 64);
	SetNativeString(2, buffer, GetNativeCell(3), true, 0);
	return 0;
}

public Native_DiscordUser_GetDiscriminator(Handle:plugin, numParams)
{
	new Handle:hJson = GetNativeCell(1);
	new String:buffer[16];
	.5884.JsonObjectGetString(hJson, "discriminator", buffer, 16);
	SetNativeString(2, buffer, GetNativeCell(3), true, 0);
	return 0;
}

public Native_DiscordUser_GetAvatar(Handle:plugin, numParams)
{
	new Handle:hJson = GetNativeCell(1);
	new String:buffer[256];
	.5884.JsonObjectGetString(hJson, "avatar", buffer, 256);
	SetNativeString(2, buffer, GetNativeCell(3), true, 0);
	return 0;
}

public Native_DiscordUser_GetEmail(Handle:plugin, numParams)
{
	new Handle:hJson = GetNativeCell(1);
	new String:buffer[64];
	.5884.JsonObjectGetString(hJson, "email", buffer, 64);
	SetNativeString(2, buffer, GetNativeCell(3), true, 0);
	return 0;
}

public Native_DiscordUser_IsVerified(Handle:plugin, numParams)
{
	new Handle:hJson = GetNativeCell(1);
	return .6456.JsonObjectGetBool(hJson, "verified", false);
}

public Native_DiscordUser_IsBot(Handle:plugin, numParams)
{
	new Handle:hJson = GetNativeCell(1);
	return .6456.JsonObjectGetBool(hJson, "bot", false);
}

public Native_DiscordMessage_GetID(Handle:plugin, numParams)
{
	new Handle:hJson = GetNativeCell(1);
	new String:buffer[64];
	.5884.JsonObjectGetString(hJson, "id", buffer, 64);
	SetNativeString(2, buffer, GetNativeCell(3), true, 0);
	return 0;
}

public Native_DiscordMessage_IsPinned(Handle:plugin, numParams)
{
	new Handle:hJson = GetNativeCell(1);
	return .6456.JsonObjectGetBool(hJson, "pinned", false);
}

public Native_DiscordMessage_GetAuthor(Handle:plugin, numParams)
{
	new Handle:hJson = GetNativeCell(1);
	new Handle:hAuthor = json_object_get(hJson, "author");
	new DiscordUser:user = CloneHandle(hAuthor, plugin);
	CloseHandle(hAuthor);
	hAuthor = MissingTAG:0;
	return user;
}

public Native_DiscordMessage_GetContent(Handle:plugin, numParams)
{
	new Handle:hJson = GetNativeCell(1);
	static String:buffer[2000];
	.5884.JsonObjectGetString(hJson, "content", buffer, 2000);
	SetNativeString(2, buffer, GetNativeCell(3), true, 0);
	return 0;
}

public Native_DiscordMessage_GetChannelID(Handle:plugin, numParams)
{
	new Handle:hJson = GetNativeCell(1);
	new String:buffer[64];
	.5884.JsonObjectGetString(hJson, "channel_id", buffer, 64);
	SetNativeString(2, buffer, GetNativeCell(3), true, 0);
	return 0;
}

public Native_DiscordBot_GetGuildMembers(Handle:plugin, numParams)
{
	new DiscordBot:bot = CloneHandle(GetNativeCell(1), Handle:0);
	new String:guild[32];
	GetNativeString(2, guild, 32, 0);
	new Function:fCallback = GetNativeCell(3);
	new limit = GetNativeCell(4);
	new String:afterID[32];
	GetNativeString(5, afterID, 32, 0);
	new Handle:hData = json_object();
	json_object_set_new(hData, "bot", bot);
	json_object_set_new(hData, "guild", json_string(guild));
	json_object_set_new(hData, "limit", json_integer(limit));
	json_object_set_new(hData, "afterID", json_string(afterID));
	new Handle:fwd = CreateForward(ExecType:0, 2, 7, 2);
	AddToForward(fwd, plugin, fCallback);
	json_object_set_new(hData, "callback", json_integer(fwd));
	.40216.GetMembers(hData);
	return 0;
}

public Native_DiscordBot_GetGuildMembersAll(Handle:plugin, numParams)
{
	new DiscordBot:bot = CloneHandle(GetNativeCell(1), Handle:0);
	new String:guild[32];
	GetNativeString(2, guild, 32, 0);
	new Function:fCallback = GetNativeCell(3);
	new limit = GetNativeCell(4);
	new String:afterID[32];
	GetNativeString(5, afterID, 32, 0);
	new Handle:hData = json_object();
	json_object_set_new(hData, "bot", bot);
	json_object_set_new(hData, "guild", json_string(guild));
	json_object_set_new(hData, "limit", json_integer(limit));
	json_object_set_new(hData, "afterID", json_string(afterID));
	new Handle:fwd = CreateForward(ExecType:0, 2, 7, 2);
	AddToForward(fwd, plugin, fCallback);
	json_object_set_new(hData, "callback", json_integer(fwd));
	.40216.GetMembers(hData);
	return 0;
}

public .40216.GetMembers(Handle:hData)
{
	new DiscordBot:bot = json_object_get(hData, "bot");
	new String:guild[32];
	.5884.JsonObjectGetString(hData, "guild", guild, 32);
	new limit = .5492.JsonObjectGetInt(hData, "limit");
	new String:afterID[32];
	.5884.JsonObjectGetString(hData, "afterID", afterID, 32);
	new String:url[256];
	if (.2920.StrEqual(afterID, "", true))
	{
		FormatEx(url, 256, "https://discordapp.com/api/guilds/%s/members?limit=%i", guild, limit);
	}
	else
	{
		FormatEx(url, 256, "https://discordapp.com/api/guilds/%s/members?limit=%i&afterID=%s", guild, limit, afterID);
	}
	new String:route[128];
	FormatEx(route, 128, "guild/%s/members", guild);
	new DiscordRequest:request = .9360.DiscordRequest.DiscordRequest(url, EHTTPMethod:1);
	if (request)
	{
		.9620.DiscordRequest.SetCallbacks(request, SteamWorksHTTPRequestCompleted:117, SteamWorksHTTPDataReceived:123);
		.9812.DiscordRequest.SetBot(request, bot);
		.9740.DiscordRequest.SetData(request, hData, route);
		.9860.DiscordRequest.Send(request, route);
		CloseHandle(bot);
		bot = MissingTAG:0;
		return 0;
	}
	CloseHandle(bot);
	bot = MissingTAG:0;
	CreateTimer(2.0, SendGetMembers, hData, 0);
	return 0;
}

public .40216.GetMembers(Handle:hData)
{
	new DiscordBot:bot = json_object_get(hData, "bot");
	new String:guild[32];
	.5884.JsonObjectGetString(hData, "guild", guild, 32);
	new limit = .5492.JsonObjectGetInt(hData, "limit");
	new String:afterID[32];
	.5884.JsonObjectGetString(hData, "afterID", afterID, 32);
	new String:url[256];
	if (.2920.StrEqual(afterID, "", true))
	{
		FormatEx(url, 256, "https://discordapp.com/api/guilds/%s/members?limit=%i", guild, limit);
	}
	else
	{
		FormatEx(url, 256, "https://discordapp.com/api/guilds/%s/members?limit=%i&afterID=%s", guild, limit, afterID);
	}
	new String:route[128];
	FormatEx(route, 128, "guild/%s/members", guild);
	new DiscordRequest:request = .9360.DiscordRequest.DiscordRequest(url, EHTTPMethod:1);
	if (request)
	{
		.9620.DiscordRequest.SetCallbacks(request, SteamWorksHTTPRequestCompleted:117, SteamWorksHTTPDataReceived:123);
		.9812.DiscordRequest.SetBot(request, bot);
		.9740.DiscordRequest.SetData(request, hData, route);
		.9860.DiscordRequest.Send(request, route);
		CloseHandle(bot);
		bot = MissingTAG:0;
		return 0;
	}
	CloseHandle(bot);
	bot = MissingTAG:0;
	CreateTimer(2.0, SendGetMembers, hData, 0);
	return 0;
}

public Action:SendGetMembers(Handle:timer, any:data)
{
	.40216.GetMembers(data);
	return Action:0;
}

public MembersDataReceive(Handle:request, bool:failure, offset, statuscode, any:dp)
{
	new var1;
	if (failure || statuscode == 200)
	{
		if (statuscode == 400)
		{
			PrintToServer("BAD REQUEST");
		}
		new var2;
		if (statuscode == 429 || statuscode == 500)
		{
			.40216.GetMembers(dp);
			CloseHandle(request);
			request = MissingTAG:0;
			return 0;
		}
		LogError("[DISCORD] Couldn't Send GetMembers - Fail %i %i", failure, statuscode);
		CloseHandle(request);
		request = MissingTAG:0;
		CloseHandle(dp);
		dp = MissingTAG:0;
		return 0;
	}
	SteamWorks_GetHTTPResponseBodyCallback(request, SteamWorksHTTPBodyCallback:99, dp, Handle:0);
	CloseHandle(request);
	request = MissingTAG:0;
	return 0;
}

public GetMembersData(String:data[], any:dp)
{
	new Handle:hJson = json_load(data);
	new Handle:hData = dp;
	new DiscordBot:bot = json_object_get(hData, "bot");
	new Handle:fwd = .5492.JsonObjectGetInt(hData, "callback");
	new String:guild[32];
	.5884.JsonObjectGetString(hData, "guild", guild, 32);
	if (fwd)
	{
		Call_StartForward(fwd);
		Call_PushCell(bot);
		Call_PushString(guild);
		Call_PushCell(hJson);
		Call_Finish(0);
	}
	CloseHandle(bot);
	bot = MissingTAG:0;
	if (.6456.JsonObjectGetBool(hData, "autoPaginate", false))
	{
		new size = json_array_size(hJson);
		new limit = .5492.JsonObjectGetInt(hData, "limit");
		if (size == limit)
		{
			new Handle:hLast = json_array_get(hJson, size + -1);
			new String:lastID[32];
			json_string_value(hLast, lastID, 32);
			CloseHandle(hJson);
			hJson = MissingTAG:0;
			CloseHandle(hLast);
			hLast = MissingTAG:0;
			json_object_set_new(hData, "afterID", json_string(lastID));
			.40216.GetMembers(hData);
			return 0;
		}
	}
	CloseHandle(hJson);
	hJson = MissingTAG:0;
	CloseHandle(hData);
	hData = MissingTAG:0;
	CloseHandle(fwd);
	fwd = MissingTAG:0;
	return 0;
}

public Native_DiscordBot_GetGuildRoles(Handle:plugin, numParams)
{
	new DiscordBot:bot = CloneHandle(GetNativeCell(1), Handle:0);
	new String:guild[32];
	GetNativeString(2, guild, 32, 0);
	new Function:fCallback = GetNativeCell(3);
	new any:data = GetNativeCell(4);
	new Handle:hData = json_object();
	json_object_set_new(hData, "bot", bot);
	json_object_set_new(hData, "guild", json_string(guild));
	json_object_set_new(hData, "data1", json_integer(data));
	new Handle:fwd = CreateForward(ExecType:0, 2, 7, 2, 2);
	AddToForward(fwd, plugin, fCallback);
	json_object_set_new(hData, "callback", json_integer(fwd));
	.43480.GetGuildRoles(hData);
	return 0;
}

public .43480.GetGuildRoles(Handle:hData)
{
	new DiscordBot:bot = json_object_get(hData, "bot");
	new String:guild[32];
	.5884.JsonObjectGetString(hData, "guild", guild, 32);
	new String:url[256];
	FormatEx(url, 256, "https://discordapp.com/api/guilds/%s/roles", guild);
	new String:route[128];
	FormatEx(route, 128, "guild/%s/roles", guild);
	new DiscordRequest:request = .9360.DiscordRequest.DiscordRequest(url, EHTTPMethod:1);
	if (request)
	{
		.9620.DiscordRequest.SetCallbacks(request, SteamWorksHTTPRequestCompleted:117, SteamWorksHTTPDataReceived:91);
		.9812.DiscordRequest.SetBot(request, bot);
		.9740.DiscordRequest.SetData(request, hData, route);
		.9860.DiscordRequest.Send(request, route);
		CloseHandle(bot);
		bot = MissingTAG:0;
		return 0;
	}
	CloseHandle(bot);
	bot = MissingTAG:0;
	CreateTimer(2.0, SendGetGuildRoles, hData, 0);
	return 0;
}

public .43480.GetGuildRoles(Handle:hData)
{
	new DiscordBot:bot = json_object_get(hData, "bot");
	new String:guild[32];
	.5884.JsonObjectGetString(hData, "guild", guild, 32);
	new String:url[256];
	FormatEx(url, 256, "https://discordapp.com/api/guilds/%s/roles", guild);
	new String:route[128];
	FormatEx(route, 128, "guild/%s/roles", guild);
	new DiscordRequest:request = .9360.DiscordRequest.DiscordRequest(url, EHTTPMethod:1);
	if (request)
	{
		.9620.DiscordRequest.SetCallbacks(request, SteamWorksHTTPRequestCompleted:117, SteamWorksHTTPDataReceived:91);
		.9812.DiscordRequest.SetBot(request, bot);
		.9740.DiscordRequest.SetData(request, hData, route);
		.9860.DiscordRequest.Send(request, route);
		CloseHandle(bot);
		bot = MissingTAG:0;
		return 0;
	}
	CloseHandle(bot);
	bot = MissingTAG:0;
	CreateTimer(2.0, SendGetGuildRoles, hData, 0);
	return 0;
}

public Action:SendGetGuildRoles(Handle:timer, any:data)
{
	.43480.GetGuildRoles(data);
	return Action:0;
}

public GetGuildRolesReceive(Handle:request, bool:failure, offset, statuscode, any:dp)
{
	new var1;
	if (failure || statuscode == 200)
	{
		if (statuscode == 400)
		{
			PrintToServer("BAD REQUEST");
		}
		new var2;
		if (statuscode == 429 || statuscode == 500)
		{
			.43480.GetGuildRoles(dp);
			CloseHandle(request);
			request = MissingTAG:0;
			return 0;
		}
		LogError("[DISCORD] Couldn't Send GetGuildRoles - Fail %i %i", failure, statuscode);
		CloseHandle(request);
		request = MissingTAG:0;
		CloseHandle(dp);
		dp = MissingTAG:0;
		return 0;
	}
	SteamWorks_GetHTTPResponseBodyCallback(request, SteamWorksHTTPBodyCallback:113, dp, Handle:0);
	CloseHandle(request);
	request = MissingTAG:0;
	return 0;
}

public GetRolesData(String:data[], any:dp)
{
	new Handle:hJson = json_load(data);
	new Handle:hData = dp;
	new DiscordBot:bot = json_object_get(hData, "bot");
	new Handle:fwd = .5492.JsonObjectGetInt(hData, "callback");
	new String:guild[32];
	.5884.JsonObjectGetString(hData, "guild", guild, 32);
	new any:data1 = .5492.JsonObjectGetInt(hData, "data1");
	if (fwd)
	{
		Call_StartForward(fwd);
		Call_PushCell(bot);
		Call_PushString(guild);
		Call_PushCell(hJson);
		Call_PushCell(data1);
		Call_Finish(0);
	}
	CloseHandle(bot);
	bot = MissingTAG:0;
	CloseHandle(hJson);
	hJson = MissingTAG:0;
	CloseHandle(hData);
	hData = MissingTAG:0;
	CloseHandle(fwd);
	fwd = MissingTAG:0;
	return 0;
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("DiscordBot.GetToken", Native_DiscordBot_Token_Get);
	CreateNative("DiscordBot.SendMessage", Native_DiscordBot_SendMessage);
	CreateNative("DiscordBot.SendMessageToChannelID", Native_DiscordBot_SendMessageToChannel);
	CreateNative("DiscordChannel.SendMessage", Native_DiscordChannel_SendMessage);
	CreateNative("DiscordBot.StartTimer", Native_DiscordBot_StartTimer);
	CreateNative("DiscordBot.GetGuilds", Native_DiscordBot_GetGuilds);
	CreateNative("DiscordBot.GetGuildChannels", Native_DiscordBot_GetGuildChannels);
	CreateNative("DiscordBot.GetGuildRoles", Native_DiscordBot_GetGuildRoles);
	CreateNative("DiscordBot.AddReactionID", Native_DiscordBot_AddReaction);
	CreateNative("DiscordBot.DeleteReactionID", Native_DiscordBot_DeleteReaction);
	CreateNative("DiscordBot.GetReactionID", Native_DiscordBot_GetReaction);
	CreateNative("DiscordBot.GetGuildMembers", Native_DiscordBot_GetGuildMembers);
	CreateNative("DiscordBot.GetGuildMembersAll", Native_DiscordBot_GetGuildMembersAll);
	CreateNative("DiscordWebHook.Send", Native_DiscordWebHook_Send);
	CreateNative("DiscordUser.GetID", Native_DiscordUser_GetID);
	CreateNative("DiscordUser.GetUsername", Native_DiscordUser_GetUsername);
	CreateNative("DiscordUser.GetDiscriminator", Native_DiscordUser_GetDiscriminator);
	CreateNative("DiscordUser.GetAvatar", Native_DiscordUser_GetAvatar);
	CreateNative("DiscordUser.IsVerified", Native_DiscordUser_IsVerified);
	CreateNative("DiscordUser.GetEmail", Native_DiscordUser_GetEmail);
	CreateNative("DiscordUser.IsBot", Native_DiscordUser_IsBot);
	CreateNative("DiscordMessage.GetID", Native_DiscordMessage_GetID);
	CreateNative("DiscordMessage.IsPinned", Native_DiscordMessage_IsPinned);
	CreateNative("DiscordMessage.GetAuthor", Native_DiscordMessage_GetAuthor);
	CreateNative("DiscordMessage.GetContent", Native_DiscordMessage_GetContent);
	CreateNative("DiscordMessage.GetChannelID", Native_DiscordMessage_GetChannelID);
	RegPluginLibrary("discord-api");
	return APLRes:0;
}

public void:OnPluginStart()
{
	hRateLeft = StringMap.StringMap();
	hRateReset = StringMap.StringMap();
	hRateLimit = StringMap.StringMap();
	return void:0;
}

public Native_DiscordBot_Token_Get(Handle:plugin, numParams)
{
	new DiscordBot:bot = GetNativeCell(1);
	static String:token[196];
	.5884.JsonObjectGetString(bot, "token", token, 196);
	SetNativeString(2, token, GetNativeCell(3), true, 0);
	return 0;
}

public .46632.BuildAuthHeader(Handle:request, DiscordBot:Bot)
{
	static String:buffer[256];
	static String:token[196];
	.5884.JsonObjectGetString(Bot, "token", token, 196);
	FormatEx(buffer, 256, "Bot %s", token);
	SteamWorks_SetHTTPRequestHeaderValue(request, "Authorization", buffer);
	return 0;
}

public .46632.BuildAuthHeader(Handle:request, DiscordBot:Bot)
{
	static String:buffer[256];
	static String:token[196];
	.5884.JsonObjectGetString(Bot, "token", token, 196);
	FormatEx(buffer, 256, "Bot %s", token);
	SteamWorks_SetHTTPRequestHeaderValue(request, "Authorization", buffer);
	return 0;
}

public .46772.PrepareRequest(DiscordBot:bot, String:url[], EHTTPMethod:method, Handle:hJson, SteamWorksHTTPDataReceived:DataReceived, SteamWorksHTTPRequestCompleted:RequestCompleted)
{
	static String:stringJson[16384];
	stringJson[0] = 0;
	if (hJson)
	{
		json_dump(hJson, stringJson, 16384, 0, true, false, false);
	}
	static String:turl[128];
	FormatEx(turl, 128, "https://discordapp.com/api/%s", url);
	new Handle:request = SteamWorks_CreateHTTPRequest(method, turl);
	if (request)
	{
		if (bot)
		{
			.46632.BuildAuthHeader(request, bot);
		}
		SteamWorks_SetHTTPRequestRawPostBody(request, "application/json; charset=UTF-8", stringJson, strlen(stringJson));
		SteamWorks_SetHTTPRequestNetworkActivityTimeout(request, 30);
		if (RequestCompleted == SteamWorksHTTPRequestCompleted:-1)
		{
			RequestCompleted = MissingTAG:117;
		}
		if (DataReceived == SteamWorksHTTPDataReceived:-1)
		{
			DataReceived = MissingTAG:119;
		}
		SteamWorks_SetHTTPCallbacks(request, RequestCompleted, SteamWorksHTTPHeadersReceived:121, DataReceived, Handle:0);
		if (hJson)
		{
			CloseHandle(hJson);
			hJson = MissingTAG:0;
		}
		return request;
	}
	return 0;
}

public .46772.PrepareRequest(DiscordBot:bot, String:url[], EHTTPMethod:method, Handle:hJson, SteamWorksHTTPDataReceived:DataReceived, SteamWorksHTTPRequestCompleted:RequestCompleted)
{
	static String:stringJson[16384];
	stringJson[0] = 0;
	if (hJson)
	{
		json_dump(hJson, stringJson, 16384, 0, true, false, false);
	}
	static String:turl[128];
	FormatEx(turl, 128, "https://discordapp.com/api/%s", url);
	new Handle:request = SteamWorks_CreateHTTPRequest(method, turl);
	if (request)
	{
		if (bot)
		{
			.46632.BuildAuthHeader(request, bot);
		}
		SteamWorks_SetHTTPRequestRawPostBody(request, "application/json; charset=UTF-8", stringJson, strlen(stringJson));
		SteamWorks_SetHTTPRequestNetworkActivityTimeout(request, 30);
		if (RequestCompleted == SteamWorksHTTPRequestCompleted:-1)
		{
			RequestCompleted = MissingTAG:117;
		}
		if (DataReceived == SteamWorksHTTPDataReceived:-1)
		{
			DataReceived = MissingTAG:119;
		}
		SteamWorks_SetHTTPCallbacks(request, RequestCompleted, SteamWorksHTTPHeadersReceived:121, DataReceived, Handle:0);
		if (hJson)
		{
			CloseHandle(hJson);
			hJson = MissingTAG:0;
		}
		return request;
	}
	return 0;
}

public HTTPCompleted(Handle:request, bool:failure, bool:requestSuccessful, EHTTPStatusCode:statuscode, any:data, any:data2)
{
	return 0;
}

public HTTPDataReceive(Handle:request, bool:failure, offset, statuscode, any:dp)
{
	CloseHandle(request);
	request = MissingTAG:0;
	return 0;
}

public HeadersReceived(Handle:request, bool:failure, any:data, any:datapack)
{
	new DataPack:dp = datapack;
	if (failure)
	{
		CloseHandle(dp);
		dp = MissingTAG:0;
		return 0;
	}
	new String:xRateLimit[16];
	new String:xRateLeft[16];
	new String:xRateReset[32];
	new bool:exists = SteamWorks_GetHTTPResponseHeaderValue(request, "X-RateLimit-Limit", xRateLimit, 16);
	exists = SteamWorks_GetHTTPResponseHeaderValue(request, "X-RateLimit-Remaining", xRateLeft, 16);
	exists = SteamWorks_GetHTTPResponseHeaderValue(request, "X-RateLimit-Reset", xRateReset, 32);
	new String:route[128];
	ResetPack(dp, false);
	ReadPackString(dp, route, 128);
	CloseHandle(dp);
	dp = MissingTAG:0;
	new reset = StringToInt(xRateReset, 10);
	if (GetTime({0,0}) + 3 < reset)
	{
		reset = GetTime({0,0}) + 3;
	}
	if (exists)
	{
		SetTrieValue(hRateReset, route, reset, true);
		SetTrieValue(hRateLeft, route, StringToInt(xRateLeft, 10), true);
		SetTrieValue(hRateLimit, route, StringToInt(xRateLimit, 10), true);
	}
	else
	{
		SetTrieValue(hRateReset, route, any:-1, true);
		SetTrieValue(hRateLeft, route, any:-1, true);
		SetTrieValue(hRateLimit, route, any:-1, true);
	}
	return 0;
}

public void:DiscordSendRequest(Handle:request, String:route[])
{
	new time = GetTime({0,0});
	new resetTime;
	new defLimit;
	if (!GetTrieValue(hRateLimit, route, defLimit))
	{
		defLimit = 1;
	}
	new bool:exists = GetTrieValue(hRateReset, route, resetTime);
	if (!exists)
	{
		SetTrieValue(hRateReset, route, GetTime({0,0}) + 5, true);
		SetTrieValue(hRateLeft, route, defLimit + -1, true);
		SteamWorks_SendHTTPRequest(request);
		return void:0;
	}
	if (time == -1)
	{
		SteamWorks_SendHTTPRequest(request);
		return void:0;
	}
	if (time > resetTime)
	{
		SetTrieValue(hRateLeft, route, defLimit + -1, true);
		SteamWorks_SendHTTPRequest(request);
		return void:0;
	}
	new left;
	GetTrieValue(hRateLeft, route, left);
	if (left)
	{
		left--;
		SetTrieValue(hRateLeft, route, left, true);
		SteamWorks_SendHTTPRequest(request);
	}
	else
	{
		new Float:remaining = float(resetTime) - float(time) + 1.0;
		new Handle:dp = DataPack.DataPack();
		WritePackCell(dp, request);
		WritePackString(dp, route);
		CreateTimer(remaining, SendRequestAgain, dp, 0);
	}
	return void:0;
}

public Handle:UrlToDP(String:url[])
{
	new DataPack:dp = DataPack.DataPack();
	WritePackString(dp, url);
	return dp;
}

public Action:SendRequestAgain(Handle:timer, any:dp)
{
	ResetPack(dp, false);
	new Handle:request = ReadPackCell(dp);
	new String:route[128];
	ReadPackString(dp, route, 128);
	CloseHandle(dp);
	dp = MissingTAG:0;
	DiscordSendRequest(request, route);
	return Action:0;
}

public .49984.RenameJsonObject(Handle:hJson, String:key[], String:toKey[])
{
	new Handle:hObject = json_object_get(hJson, key);
	if (hObject)
	{
		json_object_set_new(hJson, toKey, hObject);
		json_object_del(hJson, key);
		return 1;
	}
	return 0;
}

public .49984.RenameJsonObject(Handle:hJson, String:key[], String:toKey[])
{
	new Handle:hObject = json_object_get(hJson, key);
	if (hObject)
	{
		json_object_set_new(hJson, toKey, hObject);
		json_object_del(hJson, key);
		return 1;
	}
	return 0;
}

