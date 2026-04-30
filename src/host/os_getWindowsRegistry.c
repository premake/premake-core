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
	DWORD keyType;
	LPBYTE value;
	DWORD valueBytes;
} RegKeyInfo;

extern int convertString(const wchar_t *value, char **pbuf, int *psize); /* from os_listWindowsRegistry.c */

HKEY getRegistryKey(const wchar_t **path)
{
	if (_wcsnicmp(*path, L"HKCU:", 5) == 0) {
		*path += 5;
		return HKEY_CURRENT_USER;
	}
	if (_wcsnicmp(*path, L"HKLM:", 5) == 0) {
		*path += 5;
		return HKEY_LOCAL_MACHINE;
	}
	if (_wcsnicmp(*path, L"HKCR:", 5) == 0) {
		*path += 5;
		return HKEY_CLASSES_ROOT;
	}
	if (_wcsnicmp(*path, L"HKU:", 4) == 0) {
		*path += 4;
		return HKEY_USERS;
	}
	if (_wcsnicmp(*path, L"HKCC:", 5) == 0) {
		*path += 5;
		return HKEY_CURRENT_CONFIG;
	}

	// unsupported or invalid key prefix
	return NULL;
}

static HKEY getSubkey(HKEY key, const wchar_t **path)
{
	HKEY subkey;
	size_t length;
	wchar_t *subpath;
	const wchar_t *valueName;
	char hasValue;

	if (key == NULL)
		return NULL;

	// skip the initial path separator
	if (**path == L'\\')
		(*path)++;

	// make a copy of the subkey path that excludes the value name (if present)
	valueName = wcsrchr(*path, L'\\');
	hasValue = valueName ? valueName[1] != L'\0' : 0;
	if (hasValue) {
		length = (size_t)(valueName - *path);
		subpath = (wchar_t *)malloc((length + 1) * sizeof(wchar_t));
		wcsncpy(subpath, *path, length);
		subpath[length] = L'\0';
	}
	// no value separator means we should check the default value
	else {
		subpath = (wchar_t *)*path;
		length = wcslen(subpath);
	}

	// open the key for reading
	if (RegOpenKeyExW(key, subpath, 0, KEY_READ, &subkey) != ERROR_SUCCESS)
		subkey = NULL;

	// free the subpath if one was allocated
	if (hasValue)
		free(subpath);

	*path += length;
	return subkey;
}

static LPBYTE getValue(HKEY key, const wchar_t * name, RegKeyInfo *info)
{
	DWORD length_bytes;
	LPBYTE value;

	info->value = NULL;
	info->valueBytes = 0;
	if (key == NULL || name == NULL)
		return NULL;

	// skip the initial path separator
	if (name[0] == L'\\')
		name++;

	// query length of value
	if (RegQueryValueExW(key, name, NULL, NULL, NULL, &length_bytes) != ERROR_SUCCESS)
		return NULL;

	// allocate room for the value and fetch it
	value = (LPBYTE)malloc(length_bytes + (2 * sizeof(wchar_t)));
	if (!value)
		return NULL;

	if (RegQueryValueExW(key, name, NULL, &info->keyType, value, &length_bytes) != ERROR_SUCCESS) {
		free(value);
		return NULL;
	}

	// ensure proper termination of strings (two terminators for the REG_MULTI_SZ)
	memset(value + length_bytes, 0, 2 * sizeof(wchar_t));

	info->value = value;
	info->valueBytes = length_bytes;
	return value;
}

static void fetchKeyInfo(struct RegKeyInfo *info, const wchar_t *path)
{
	info->key = getRegistryKey(&path);
	info->subkey = getSubkey(info->key, &path);
	getValue(info->subkey, path, info);
}

static void releaseKeyInfo(struct RegKeyInfo *info)
{
	if (info->value) free(info->value);
	if (info->subkey) RegCloseKey(info->subkey);
}

int os_getWindowsRegistry(lua_State *L)
{
	RegKeyInfo info = {0, 0, 0, NULL, 0};
	const wchar_t *wpath = luaL_checkconvertstring(L, 1);
	fetchKeyInfo(&info, wpath);
	lua_pop(L, 1);

	switch (info.keyType)
	{
		case REG_NONE:
			lua_pushnil(L);
			break;

		case REG_SZ:
		case REG_EXPAND_SZ:
		case REG_LINK: {
			char *value = NULL;
			int size = 0;
			lua_pushstring(L, convertString((const wchar_t *)info.value, &value, &size) ? value : "Error converting value");
			free(value);
			break;
		}

		default: /* some of these are strange to push as a string... */
			lua_pushlstring(L, (char *)info.value, info.valueBytes);
			break;
	}

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
