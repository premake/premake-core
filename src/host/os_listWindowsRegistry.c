/**
 * \file   os_reg.c
 * \brief  Returns true if the given file exists on the file system.
 * \author Copyright (c) 2002-2016 Jason Perkins and the Premake project
 */

#include "premake.h"

#if PLATFORM_WINDOWS

typedef struct RegNodeInfo
{
	const char * name;
	const char * value;
	DWORD valueSize;
	DWORD type;
} RegNodeInfo;

typedef void (*ListCallback)(const RegNodeInfo * info, void * user);
extern HKEY getRegistryKey(const char** path);

static const char* getTypeString(DWORD type)
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
		default:                             return NULL;
	}
}

static HKEY openKey(const char *path)
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
	if (path[0] == '\\')
		path++;
	
	// open the key for reading
	if (RegOpenKeyExA(key, path, 0, KEY_READ, &subkey) != ERROR_SUCCESS)
		subkey = NULL;

	return subkey;
}

static int listNodes(HKEY key, ListCallback callback, void * user)
{
	RegNodeInfo node;
	DWORD maxSubkeyLength;
	DWORD maxValueLength;
	DWORD maxNameLength;
	DWORD numSubkeys;
	DWORD numValues;
	DWORD length;
	DWORD index;	
	char* name;
	char* value;
	int ok;

	if (key == NULL || callback == NULL)
		return 0;

	// Initialize node structure
	node.value = NULL;
	node.valueSize = 0;
	node.type = REG_NONE;

	// Fetch info about key content
	if (RegQueryInfoKeyA(key, NULL, NULL, NULL, &numSubkeys, &maxSubkeyLength, NULL, &numValues, &maxNameLength, &maxValueLength, NULL, NULL) != ERROR_SUCCESS)
		return 0;

	// Allocate name and value buffers
	if (maxSubkeyLength > maxNameLength)
		maxNameLength = maxSubkeyLength;

	maxNameLength++;
	maxValueLength++;
	name = (char*)malloc((size_t)maxNameLength);
	value = (char*)malloc((size_t)maxValueLength + 1);

	// Iterate over subkeys
	ok = 1;
	node.name = name;
	for (index = 0; index < numSubkeys; index++) {
		length = maxNameLength;
		if (RegEnumKeyExA(key, index, name, &length, NULL, NULL, NULL, NULL) != ERROR_SUCCESS) {
			ok = 0;
			break;
		}
		callback(&node, user);
	}

	// Iterate over values
	if (ok) {
		node.value = value;
		for (index = 0; index < numValues; index++) {
			length = maxNameLength;
			node.valueSize = maxValueLength;
			if (RegEnumValueA(key, index, name, &length, NULL, &node.type, (LPBYTE)value, &node.valueSize) != ERROR_SUCCESS) {
				ok = 0;
				break;
			}

			// Ensure proper termination of strings (two terminators for the REG_MULTI_SZ)
			value[node.valueSize] = '\0';
			value[node.valueSize + 1] = '\0';
			callback(&node, user);
		}
	}

	// Free buffers
	free(name);
	free(value);

	return ok;
}

static void listCallback(const RegNodeInfo* info, void* user)
{
	lua_State* L = (lua_State*)user;
	const char* typeString;
	
	// Insert key into the result table (keys are represented as empty tables)
	if (info->value == NULL) {		
		lua_createtable(L, 0, 0);
		lua_setfield(L, -2, info->name);
		return;
	}

	// Values are represented as tables containing "type" and "value" records
	typeString = getTypeString(info->type);
	lua_createtable(L, 0, 2);
	lua_pushstring(L, typeString ? typeString : "Unknown");
	lua_setfield(L, -2, "type");

	switch (info->type)
	{
		// Binary encoded values -> size defined string
		case REG_NONE:
		case REG_BINARY:
		case REG_RESOURCE_LIST:
		case REG_FULL_RESOURCE_DESCRIPTOR:
		case REG_RESOURCE_REQUIREMENTS_LIST: {
			lua_pushlstring(L, info->value, info->valueSize);
			break;
		}

		// String encoded values -> zero terminated string
		case REG_SZ:
		case REG_EXPAND_SZ:
		case REG_LINK: {
			lua_pushstring(L, info->value);
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
			DWORD i, j, k;

			lua_newtable(L);
			for (i = j = 0, k = 1; i < info->valueSize; i++)
			{
				if (info->value[i] != 0)
					continue;

				if (i == j)
					break;

				lua_pushlstring(L, &info->value[j], i - j);
				lua_rawseti(L, -2, k);
				j = i + 1;
				k++;
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
	HKEY key = openKey(luaL_checkstring(L, 1));
	if (key == NULL) {
		lua_pushnil(L);
		return 1;
	}

	lua_newtable(L);
	if (!listNodes(key, listCallback, (void *)L)) {
		// Discard table in case of fault and push nil instead
		lua_pop(L, 1);
		lua_pushnil(L);
	}

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
