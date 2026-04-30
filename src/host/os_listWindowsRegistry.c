/**
 * \file   os_reg.c
 * \brief  Returns true if the given file exists on the file system.
 * \author Copyright (c) 2002-2016 Jess Perkins and the Premake project
 */

#include "premake.h"
#include <assert.h>

#if PLATFORM_WINDOWS

typedef struct RegNodeInfo
{
	const char * name;
	LPBYTE value;
	DWORD valueBytes;
	DWORD type;
} RegNodeInfo;

typedef struct State
{
	lua_State *L;
	char *valbuf;
	int valsize;
} State;

static void initState(State *state, lua_State *L)
{
	state->L = L;
	state->valbuf = NULL;
	state->valsize = 0;
}

static void freeState(State *state)
{
	if (state->valbuf) free(state->valbuf);
}

typedef void (*ListCallback)(const RegNodeInfo * info, void * user);
extern HKEY getRegistryKey(const wchar_t** path); /* from os_getWindowsRegistry.c */

static const char *getTypeString(DWORD type)
{
	switch (type)
	{
		case REG_NONE:                       return "REG_NONE";
		case REG_SZ:                         return "REG_SZ";
		case REG_EXPAND_SZ:                  return "REG_EXPAND_SZ";
		case REG_BINARY:                     return "REG_BINARY";
		case REG_DWORD:                      return "REG_DWORD";
		case REG_DWORD_BIG_ENDIAN:           return "REG_DWORD_BIG_ENDIAN";
		case REG_LINK:                       return "REG_LINK";
		case REG_MULTI_SZ:                   return "REG_MULTI_SZ";
		case REG_RESOURCE_LIST:              return "REG_RESOURCE_LIST";
		case REG_FULL_RESOURCE_DESCRIPTOR:   return "REG_FULL_RESOURCE_DESCRIPTOR";
		case REG_RESOURCE_REQUIREMENTS_LIST: return "REG_RESOURCE_REQUIREMENTS_LIST";
		case REG_QWORD:                      return "REG_QWORD";
		default:                             return "Unknown";
	}
}

static HKEY openKey(const wchar_t *path)
{
	HKEY key, subkey;

	// check string
	if (path == NULL)
		return NULL;

	// get HKEY
	key = getRegistryKey(&path);
	if (key == NULL)
		return NULL;

	// skip the initial path separator
	if (path[0] == L'\\')
		path++;

	// open the key for reading
	if (RegOpenKeyExW(key, path, 0, KEY_READ, &subkey) != ERROR_SUCCESS)
		subkey = NULL;

	return subkey;
}

int convertString(const wchar_t *value, char **pbuf, int *psize)
{
	int size = WideCharToMultiByte(CP_UTF8, 0, value, -1, *pbuf, *psize, NULL, NULL);
	if (!size)
	{
		// If we give it a valid size, but it's too small, we get an error with INSUFFICIENT_BUFFER
		if (!*psize || GetLastError() != ERROR_INSUFFICIENT_BUFFER)
			return 0;
		// Got INSUFFICIENT_BUFFER; need to get the required size without trying to convert
		size = WideCharToMultiByte(CP_UTF8, 0, value, -1, NULL, 0, NULL, NULL);
		if (!size)
			return 0;
		assert(size > *psize);
	}
	if (size > *psize)
	{
		*pbuf = realloc(*pbuf, size);
		if (!*pbuf)
			return 0;
		*psize = size;
		WideCharToMultiByte(CP_UTF8, 0, value, -1, *pbuf, size, NULL, NULL);
	}
	return 1;
}

static int listNodes(HKEY key, ListCallback callback, void * user)
{
	RegNodeInfo node = {NULL, NULL, 0, REG_NONE};
	DWORD maxSubkeyLength; // in characters
	DWORD maxNameLength; // in characters
	DWORD maxValueBytes; // in bytes
	DWORD numSubkeys;
	DWORD numValues;
	DWORD length;
	DWORD index;
	wchar_t *name;
	char *namebuf = NULL;
	LPBYTE value;
	void *buf;
	int namesize = 0;
	int ok;

	if (key == NULL || callback == NULL)
		return 0;

	// Fetch info about key content
	if (RegQueryInfoKeyW(key, NULL, NULL, NULL, &numSubkeys, &maxSubkeyLength, NULL, &numValues, &maxNameLength, &maxValueBytes, NULL, NULL) != ERROR_SUCCESS)
		return 0;

	// Allocate name and value buffers
	if (maxSubkeyLength > maxNameLength)
		maxNameLength = maxSubkeyLength;

	maxNameLength++; // space for null terminator
	maxValueBytes += (2 * sizeof(wchar_t)); // space for two null terminators (for REG_MULTI_SZ)
	buf = malloc((maxNameLength * sizeof(wchar_t)) + maxValueBytes);
	if (!buf)
		return 0;

	name = (wchar_t *)buf;
	value = (LPBYTE)(name + maxNameLength);

	// Iterate over subkeys
	ok = 1;
	for (index = 0; index < numSubkeys; index++) {
		length = maxNameLength;
		if (RegEnumKeyExW(key, index, name, &length, NULL, NULL, NULL, NULL) != ERROR_SUCCESS) {
			ok = 0;
			break;
		}
		if (!convertString(name, &namebuf, &namesize)) {
			ok = 0;
			break;
		}
		node.name = namebuf;
		callback(&node, user);
	}

	// Iterate over values
	if (ok) {
		node.value = value;
		for (index = 0; index < numValues; index++) {
			length = maxNameLength;
			node.valueBytes = maxValueBytes;
			if (RegEnumValueW(key, index, name, &length, NULL, &node.type, value, &node.valueBytes) != ERROR_SUCCESS) {
				ok = 0;
				break;
			}

			// Ensure proper termination of strings (two terminators for the REG_MULTI_SZ)
			memset(value + node.valueBytes, 0, 2 * sizeof(wchar_t));

			if (!convertString(name, &namebuf, &namesize)) {
				ok = 0;
				break;
			}
			node.name = namebuf;
			callback(&node, user);
		}
	}

	// Free buffers
	free(buf);
	if (namebuf) free(namebuf);

	return ok;
}

static void listCallback(const RegNodeInfo* info, void* user)
{
	State *state = (State*)user;
	lua_State* L = state->L;

	// Insert key into the result table (keys are represented as empty tables)
	if (info->value == NULL) {
		lua_createtable(L, 0, 0);
		lua_setfield(L, -2, info->name);
		return;
	}

	// Values are represented as tables containing "type" and "value" records
	lua_createtable(L, 0, 2);
	lua_pushstring(L, getTypeString(info->type));
	lua_setfield(L, -2, "type");

	switch (info->type)
	{
		// Binary encoded values -> size defined string
		case REG_NONE:
		case REG_BINARY:
		case REG_RESOURCE_LIST:
		case REG_FULL_RESOURCE_DESCRIPTOR:
		case REG_RESOURCE_REQUIREMENTS_LIST: {
			lua_pushlstring(L, (char *)info->value, info->valueBytes);
			break;
		}

		// String encoded values -> zero terminated string
		case REG_SZ:
		case REG_EXPAND_SZ:
		case REG_LINK: {
			const char *str = convertString((const wchar_t *)info->value, &state->valbuf, &state->valsize) ? state->valbuf : "Error converting value";
			lua_pushstring(L, str);
			break;
		}

		// Numbers
		case REG_DWORD: {
			lua_pushinteger(L, *(DWORD32*)info->value);
			break;
		}

		case REG_DWORD_BIG_ENDIAN: {
			lua_pushinteger(L, (info->value[3] << 0) | (info->value[2] << 8) | (info->value[1] << 16) | (info->value[0] << 24));
			break;
		}

		case REG_QWORD: {
			lua_pushinteger(L, *(DWORD64*)info->value);
			break;
		}

		// Multiple strings
		case REG_MULTI_SZ: {
			int k = 1;
			const wchar_t *end = (const wchar_t *)(info->value + info->valueBytes);
			lua_newtable(L);
			for (const wchar_t *p = (const wchar_t *)info->value; p < end; p += wcslen(p) + 1) {
				char *str = convertString(p, &state->valbuf, &state->valsize) ? state->valbuf : "Error converting value";
				lua_pushstring(L, str);
				lua_rawseti(L, -2, k++);
			}
			break;
		}

		// Unknown field -> nil
		default: {
			lua_pushnil(L);
			break;
		}
	}
	lua_setfield(L, -2, "value");

	// Complete the value subtable
	lua_setfield(L, -2, info->name);
}

int os_listWindowsRegistry(lua_State* L)
{
	State state;
	HKEY key = openKey(luaL_checkconvertstring(L, 1));
	lua_pop(L, 1);
	if (key == NULL) {
		lua_pushnil(L);
		return 1;
	}

	initState(&state, L);
	lua_newtable(L);
	if (!listNodes(key, listCallback, &state)) {
		// Discard table in case of fault and push nil instead
		lua_pop(L, 1);
		lua_pushnil(L);
	}

	freeState(&state);

	RegCloseKey(key);
	return 1;
}

#else

int os_listWindowsRegistry(lua_State* L)
{
	lua_pushnil(L);
	return 1;
}

#endif
