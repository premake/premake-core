/**
 * \file   os_reg.c
 * \brief  Returns true if the given file exists on the file system.
 * \author Copyright (c) 2002-2016 Jason Perkins and the Premake project
 */

#include "premake.h"

#if PLATFORM_WINDOWS

typedef struct RegKeyInfo
{
	HKEY key;
	HKEY subkey;
	char * value;
} RegKeyInfo;

static HKEY get_key(const char **path)
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

	// unsupported or invalid key prefix
	return NULL;
}

static HKEY get_subkey(HKEY key, const char **path)
{
	HKEY subkey;
	size_t length;
	char *subpath;
	const char *name;

	if (key == NULL)
		return NULL;

	// make a copy of the subkey path that excludes the value name
	name = strchr(*path, '?');
	if (name) {
		length = (size_t)(name - *path);
		subpath = (char *)malloc(length + 1);
		strncpy(subpath, *path, length);
		subpath[length] = 0;
	}
	// no value separator means we should check the default value
	else {
		subpath = (char *)*path;
		length = strlen(*path);
	}

	// open the key for reading
	if (RegOpenKeyExA(key, subpath, 0, KEY_READ, &subkey) != ERROR_SUCCESS)
		subkey = NULL;

	// free the subpath if one was allocated
	if (name)
		free(subpath);

	*path += length + 1;
	return subkey;
}

static char * get_value(HKEY key, const char * name)
{
	DWORD length;
	char * value;

	if (key == NULL)
		return NULL;

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

static void fetch_keyinfo(struct RegKeyInfo *info, const char *path)
{
	info->key = get_key(&path);
	info->subkey = get_subkey(info->key, &path);
	info->value = get_value(info->subkey, path);
}

static void release_keyinfo(struct RegKeyInfo *info)
{
	free(info->value);
	RegCloseKey(info->subkey);
}

int os_getreg(lua_State *L)
{
	RegKeyInfo info;
	fetch_keyinfo(&info, luaL_checkstring(L, 1));
	lua_pushstring(L, info.value);
	release_keyinfo(&info);
	return 1;
}

#else

int os_getreg(lua_State *L)
{
	lua_pushnil(L);
	return 1;
}

#endif
