#include <sourcemod>
#include <sdktools>

enum SQLH_Type {
	SQLH_TYPE_SQLITE = 0,
	SQLH_TYPE_MySQL
};

static const String:g_DriverProduct[_:SQLH_Type + 1][] = {
	"SQLite",
	"MySQL",
	"UNKOWN_SQL_TYPE"
};

enum QueryParser_State {
	QPSTATE_INITIAL = 1,			// '['
	QPSTATE_QUERY,					// "..."
	QPSTATE_WHITESPACE,				// { '\n', ' ', '\t', etc }
	QPSTATE_COMMENT_DASH,			// "--..."
	QPSTATE_COMMENT_C,				// "/* ... */"
	QPSTATE_COMMENT_BRACE,			// "{ ... }" OR "{[driver poduct] ... }" (conditional)
	QPSTATE_END						// ']'
};

stock SQLH_Connect(const String:file[], const String:key_values[], const String:sqlite_db_name[], &Handle:db, &SQLH_Type:db_type) {
	new ret = 0;

	if (db != INVALID_HANDLE) {
		CloseHandle2(db);
	}

	decl String:buffer[256], String:named_config[128];
	new SQLH_Type:requested_type = SQLH_TYPE_SQLITE;

	if (!StrEqual(file, "") && !StrEqual(key_values, "")) {
		GetGameFolderName(buffer, sizeof(buffer));
		new len = strlen(buffer) + strlen(file) + 5;
		decl String:path[len];
		Format(path, len, "../%s/%s", buffer, file);

		if (FileExists(path)) {
			new Handle:kv = CreateKeyValues(key_values);
			if (!FileToKeyValues(kv, path)) {
				LogError("Couldn\'t load file '%s' as a keyvalue structure.", path);
			}
			else {
				if (!KvGotoFirstSubKey(kv)) {
					LogError("Couldn\'t find first subkey in file '%s'.", path);
				}
				else {
					do {
						KvGetSectionName(kv, buffer, sizeof(buffer));

						if (StrEqual(buffer, "SQL")) {
							KvGetString(kv, "named_config", named_config, sizeof(named_config), "");

							if (named_config[0] != '\0') {
								requested_type = SQLH_TYPE_MySQL;
							}
						}
					} while (KvGotoNextKey(kv));
				}

				CloseHandle(kv);
			}
		}
	}

	if (requested_type != SQLH_TYPE_SQLITE) {
		if (SQL_CheckConfig(named_config)) {
			if ((db = SQL_Connect(named_config, true, buffer, sizeof(buffer))) == INVALID_HANDLE) {
				LogMessage("Couldn't connect to database using configuration \"%s\": %s", named_config, buffer);
				requested_type = SQLH_TYPE_SQLITE;
			}
			else {
				db_type = SQLH_Type;

				decl String:driver_product[32];
				new Handle:driver = SQL_ReadDriver(db);

				SQL_GetDriverProduct(driver, driver_product, sizeof(driver_product));

				if ((db_type = SQLH_DriverProductToType(driver_product)) >= SQLH_Type) {
					LogError("Unrecognized database type \"%s\".", driver_product);
					requested_type = SQLH_TYPE_SQLITE;
					CloseHandle2(db);
				}
			}
		}
		else {
			LogMessage("Couldn't find named configuration \"%s\" in databases.cfg.", named_config);
			requested_type = SQLH_TYPE_SQLITE;
		}
	}
	if (requested_type == SQLH_TYPE_SQLITE) {
		if ((db = SQLite_UseDatabase(sqlite_db_name, buffer, sizeof(buffer))) == INVALID_HANDLE) {
			LogError(buffer);
			return ret + 1;
		}
	}

	return ret;
}

stock SQLH_SQLTypeToDriverProduct(String:driver, max_length, SQLH_Type:type) {
	if (type < 0 || type > SQLH_Type) {
		type = SQLH_Type;
	}

	strcopy(driver_product, max_length, g_DriverProduct[_:type]);
}

stock SQLH_Type:SQLH_DriverProductToType(const String:driver[]) {
	for (new i = 0; i < _:SQLH_Type; i++) {
		if (StrEqual(driver, g_DriverProduct[i], false)) {
			return SQLH_Type:i;
		}
	}

	return SQLH_Type;
}

bool:SQLH_FastQueriesFromFile(Handle:db, String:queries[], bool:must_exist = true) {
	if (db == INVALID_HANDLE) {
		return false;
	}

	decl String:driver_product[32];
	StrToLower(driver_product);
	new Handle:driver = SQL_ReadDriver(db);
	SQL_GetDriverProduct(driver, driver_product, sizeof(driver_product));
	StrToLower(driver_product);
	CloseHandle(driver);

	decl String:query[1024],
		String:buffer[1024];

	GetGameFolderName(buffer, sizeof(buffer));
	decl String:path[PLATFORM_MAX_PATH];
	Format(path, sizeof(path), "../%s/%s", buffer, queries);

	if (!FileExists(path)) {
		if (must_exist) {
			LogError("File '%s' doesn't exist.", path);
		}

		return must_exist;
	}

	new Handle:file = OpenFile(path, "r");
	if (file == INVALID_HANDLE) {
		LogError("File '%s' couldn't be opened.", path);
		return false;
	}

	new QueryParser_State:current_state = QPSTATE_INITIAL,
		QueryParser_State:return_state = QPSTATE_INITIAL,
		index = 0;

	while (ReadFileString(file, buffer, sizeof(buffer))) {
		new i = 0;
		while (buffer[i] != '\0') {
			switch (current_state) {
				case QPSTATE_INITIAL:
				{
					if (buffer[i] == '[') {
						return_state = QPSTATE_QUERY;
						current_state = QPSTATE_WHITESPACE;
					}
				}
				case QPSTATE_QUERY:
				{
					if (IsCharSpace(buffer[i])) {
						current_state = QPSTATE_WHITESPACE;
						return_state = QPSTATE_QUERY;
						query[index++] = ' ';
					}
					else if (buffer[i] == '-') {
						current_state = QPSTATE_COMMENT_DASH;
					}
					else if (buffer[i] == '/') {
						current_state = QPSTATE_COMMENT_C;
					}
					else if (buffer[i] == '{') {
						current_state = QPSTATE_COMMENT_BRACE;
					}
					else if (buffer[i] == ']') {
						current_state = QPSTATE_END;
						query[index++] = '\0';
					}
					else {
						if (buffer[i] == ',' && return_state == QPSTATE_WHITESPACE) {
							index--;
						}
						query[index++] = buffer[i];
						return_state = QPSTATE_QUERY;
					}
				}
				case QPSTATE_WHITESPACE:
				{
					if (!IsCharSpace(buffer[i])) {
						current_state = return_state;
						return_state = QPSTATE_WHITESPACE;
						i--;
					}
				}
				case QPSTATE_COMMENT_DASH:
				{
					static stage = 0;
					if (stage == 0) {
						if (buffer[i] == '-') {
							stage++;
						}
						else {
							query[index++] = '-';
							i--;
							current_state = QPSTATE_QUERY;
							return_state = QPSTATE_QUERY;
						}
					}
					else if (buffer[i] == '\n') {
						stage = 0;
						current_state = return_state;
						return_state = QPSTATE_QUERY;
					}
				}
				case QPSTATE_COMMENT_C:
				{
					static stage = 0;
					switch (stage) {
						case 0:
						{
							if (buffer[i] == '*') {
								stage++;
							}
							else {
								query[index++] = '/';
								i--;
								current_state = QPSTATE_QUERY;
								return_state = QPSTATE_QUERY;
							}
						}
						case 1:
						{
							if (buffer[i] == '*') {
								stage++;
							}
						}
						case 2:
						{
							if (buffer[i] == '/') {
								stage = 0;
								current_state = return_state;
								return_state = QPSTATE_QUERY;
							}
							else {
								stage--;
							}
						}
					}
				}
				case QPSTATE_COMMENT_BRACE:
				{
					static stage = 0,
						idx = 0,
						bool:ignore = false;

					if (!ignore) {
						switch (stage) {
							case 0:
							{
								if (buffer[i] == '[') {
									stage++;
								}
							}
							case 1:
							{
								if (buffer[i] == ']') {
									if (driver_product[idx] == '\0') {
										stage++;
									}
									else {
										ignore = true;
									}
								}
								else if (driver_product[idx] == '\0' || CharToLower(buffer[i]) != driver_product[idx]) {
									ignore = true;
								}

								idx++;
							}
							case 2:
							{
								if (IsCharSpace(buffer[i])) {
									if (return_state != QPSTATE_WHITESPACE) {
										query[index++] = ' ';
									}

									return_state = QPSTATE_COMMENT_BRACE;
									current_state = QPSTATE_WHITESPACE;
								}
								else if (buffer[i] != '}') {
									stage++;
									if (buffer[i] == ',' && return_state == QPSTATE_WHITESPACE) {
										index--;
									}
									query[index++] = buffer[i];
								}
							}
							case 3:
							{
								if (IsCharSpace(buffer[i])) {
									if (return_state != QPSTATE_WHITESPACE) {
										query[index++] = ' ';
									}

									return_state = QPSTATE_COMMENT_BRACE;
									current_state = QPSTATE_WHITESPACE;
								}
								else if (buffer[i] != '}') {
									if (buffer[i] == ',' && return_state == QPSTATE_WHITESPACE) {
										index--;
									}
									query[index++] = buffer[i];
									return_state = QPSTATE_QUERY;
								}
							}
						}
					}

					if (buffer[i] == '}') {
						stage = 0;
						idx = 0;
						ignore = false;
						current_state = return_state;
						return_state = QPSTATE_QUERY;
					}
				}
				case QPSTATE_END:
				{
					if (index > 1) {
						if (IsCharSpace(query[index-1])) {
							query[--index] = '\0';
						}

						if (index > 1) {
							if (!SQL_FastQuery(db, query)) {
								decl String:error[256];
								SQL_GetError(db, error, sizeof(error));
							
								LogError("Query '%s' failed: %s", query, error);
								return false;
							}
						}
					}

					current_state = QPSTATE_INITIAL;
					index = 0;
				}
			}

			i++;
		}
	}

	CloseHandle(file);

	if (current_state != QPSTATE_INITIAL) {
		LogError("Couldn't parse file '%s'.", path);
		return false;
	}

	return true;
}

static CloseHandle2(&Handle:hndl) {
	if (hndl != INVALID_HANDLE) {
		CloseHandle(hndl);
		hndl = INVALID_HANDLE;
	}
}

static StrToLower(String:buffer[]) {
	new i = 0;
	while (buffer[i] != '\0') {
		buffer[i] = CharToLower(buffer[i]);
		i++;
	}
}
