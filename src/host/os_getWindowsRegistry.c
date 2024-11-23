/**
 * \file   os_reg.c
 * \brief  Returns true if the given file exists on the file system.
 * \author Copyright (c) 2002-2016 Jess Perkins and the Premake project
 */

#include "premake.h"

#if PLATFORM_WINDOWS

typedef struct RegKeyInfo
{
	HKEY key;
	HKEY subkey;
	char * value;
} RegKeyInfo;

HKEY getRegistryKey(const char **path)
{
	if (_strnicmp(*path, "HKCU:", 5) == 0) {
		*path += 5;
		return HKEY_CURRENT_USER;
	}
	if (_strnicmp(*path, "HKLM:", 5) == 0) {
		*path += 5;
		return HKEY_LOCAL_MACHINE;
	}
	if (_strnicmp(*path, "HKCR:", 5) == 0) {
		*path += 5;
		return HKEY_CLASSES_ROOT;
	}
	if (_strnicmp(*path, "HKU:", 4) == 0) {
		*path += 4;
		return HKEY_USERS;
	}
	if (_strnicmp(*path, "HKCC:", 5) == 0) {
		*path += 5;
		return HKEY_CURRENT_CONFIG;
	}

	// unsupported or invalid key prefix
	return NULL;
}

static HKEY getSubkey(HKEY key, const char **path)
{
	HKEY subkey;
	size_t length;
	char *subpath;
	const char *value;
	char hasValue;

	if (key == NULL)
		return NULL;

	// skip the initial path separator
	if ((*path)[0] == '\\')
		(*path)++;

	// make a copy of the subkey path that excludes the value name (if present)
	value = strrchr(*path, '\\');
	hasValue = value ? value[1] : 0;
	if (hasValue) {
		length = (size_t)(value - *path);
		subpath = (char *)malloc(length + 1);
		strncpy(subpath, *path, length);
		subpath[length] = 0;
	}
	// no value separator means we should check the default value
	else {
		subpath = (char *)*path;
		length = strlen(subpath);
	}

	// open the key for reading
	if (RegOpenKeyExA(key, subpath, 0, KEY_READ, &subkey) != ERROR_SUCCESS)
		subkey = NULL;

	// free the subpath if one was allocated
	if (hasValue)
		free(subpath);

	*path += length;
	return subkey;
}

static char * getValue(HKEY key, const char * name)
{
	DWORD length;
	char * value;

	if (key == NULL || name == NULL)
		return NULL;

	// skip the initial path separator
	if (name[0] == '\\')
		name++;

	// query length of value
	if (RegQueryValueExA(key, name, NULL, NULL, NULL, &length) != ERROR_SUCCESS)
		return NULL;

	// allocate room for the value and fetch it
	value = (char *)malloc((size_t)length + 1);
	if (RegQueryValueExA(key, name, NULL, NULL, (LPBYTE)value, &length) != ERROR_SUCCESS) {
		free(value);
		return NULL;
	}

	value[length] = 0;
	return value;
}

static void fetchKeyInfo(struct RegKeyInfo *info, const char *path)
{
	info->key = getRegistryKey(&path);
	info->subkey = getSubkey(info->key, &path);
	info->value = getValue(info->subkey, path);
}

static void releaseKeyInfo(struct RegKeyInfo *info)
{
	free(info->value);
	RegCloseKey(info->subkey);
}

int os_getWindowsRegistry(lua_State *L)
{
	RegKeyInfo info;
	fetchKeyInfo(&info, luaL_checkstring(L, 1));
	lua_pushstring(L, info.value);
	releaseKeyInfo(&info);
	return 1;
}

#else

int os_getWindowsRegistry(lua_State *L)
{
	lua_pushnil(L);
	return 1;
}

#endif
