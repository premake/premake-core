/**
 * \file   os_match.c
 * \brief  Match files and directories.
 * \author Copyright (c) 2002-2014 Jess Perkins and the Premake project
 */

#include <stdlib.h>
#include <string.h>
#include "premake.h"

#define METATABLE_NAME "premake.matchinfo"

#if PLATFORM_WINDOWS

typedef struct struct_MatchInfo
{
	HANDLE handle;
	int    is_first;
	WIN32_FIND_DATAW entry;
} MatchInfo;

static int gc_MatchInfo(lua_State *L)
{
	/* can be called twice per object */
	MatchInfo *m = (MatchInfo *)lua_touserdata(L, 1);
	if (m->handle != INVALID_HANDLE_VALUE) {
		FindClose(m->handle);
		m->handle = INVALID_HANDLE_VALUE;
	}
	return 0;
}

int os_matchstart(lua_State *L)
{
	const wchar_t *mask = luaL_checkconvertstring(L, 1);
	MatchInfo *m = (MatchInfo *)lua_newuserdata(L, sizeof(MatchInfo));
	memset(m, 0, sizeof(MatchInfo));
	m->handle = INVALID_HANDLE_VALUE;
	m->is_first = 1;
	if (luaL_newmetatable(L, METATABLE_NAME)) /* creating metatable? */
	{
		lua_pushcfunction(L, gc_MatchInfo);
		lua_setfield(L, -2, "__gc"); /* metatable.__gc = gc_MatchInfo */
	}
	lua_setmetatable(L, -2);

	m->handle = FindFirstFileW(mask, &m->entry);
	return 1;
}

int os_matchdone(lua_State *L)
{
	/* memory will be GC'd, but still close it here */
	luaL_checkudata(L, 1, METATABLE_NAME);
	gc_MatchInfo(L);
	return 0;
}

int os_matchname(lua_State *L)
{
	MatchInfo *m = (MatchInfo *)luaL_checkudata(L, 1, METATABLE_NAME);

	return luaL_convertwstring(L, m->entry.cFileName, NULL) != NULL;
}

int os_matchisfile(lua_State *L)
{
	MatchInfo *m = (MatchInfo *)luaL_checkudata(L, 1, METATABLE_NAME);
	lua_pushboolean(L, (m->entry.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) == 0);
	return 1;
}

int os_matchnext(lua_State *L)
{
	MatchInfo *m = (MatchInfo *)luaL_checkudata(L, 1, METATABLE_NAME);
	if (m->handle == INVALID_HANDLE_VALUE) {
		return 0;
	}

	while (m)  /* loop forever */
	{
		if (m->is_first)
			m->is_first = 0;
		else if (!FindNextFileW(m->handle, &m->entry))
			return 0;

		if (wcscmp(m->entry.cFileName, L".") != 0 && wcscmp(m->entry.cFileName, L"..") != 0)
		{
			lua_pushboolean(L, 1);
			return 1;
		}
	}

	return 0;
}

#else

#include <dirent.h>
#include <fnmatch.h>
#include <sys/stat.h>

typedef struct struct_MatchInfo
{
	DIR *handle;
	struct dirent *entry;
	char *path;
	char *mask;
	int mask_is_literal;
} MatchInfo;

static int gc_MatchInfo(lua_State *L)
{
	/* can be called twice per object */
	MatchInfo *m = (MatchInfo *)lua_touserdata(L, 1);
	if (m->handle != NULL) { closedir(m->handle); m->handle = NULL; }
	if (m->path != NULL) { free(m->path); m->path = NULL; }
	if (m->mask != NULL) { free(m->mask); m->mask = NULL; }
	return 0;
}

int os_matchstart(lua_State* L)
{
	const char* mask = luaL_checkstring(L, 1);
	const char* split;
	MatchInfo *m = (MatchInfo *)lua_newuserdata(L, sizeof(MatchInfo));
	memset(m, 0, sizeof(MatchInfo));
	if (luaL_newmetatable(L, METATABLE_NAME)) /* creating metatable? */
	{
		lua_pushcfunction(L, gc_MatchInfo);
		lua_setfield(L, -2, "__gc"); /* metatable.__gc = gc_MatchInfo */
	}
	lua_setmetatable(L, -2);

	/* split the mask into path and filename components */
	split = strrchr(mask, '/');
	if (split)
	{
		m->path = (char*)malloc((split - mask) + 1);
		memcpy(m->path, mask, split - mask);
		m->path[split - mask] = '\0';
		m->mask = strdup(split + 1);
	}
	else
	{
		m->path = strdup(".");
		m->mask = strdup(mask);
	}

	m->mask_is_literal = (strpbrk(m->mask, "*?[") == NULL);
	m->handle = opendir(m->path);
	return 1;
}

int os_matchdone(lua_State* L)
{
	/* memory will be GC'd, but still close it here */
	luaL_checkudata(L, 1, METATABLE_NAME);
	gc_MatchInfo(L);
	return 0;
}

int os_matchname(lua_State* L)
{
	MatchInfo * m = (MatchInfo *)luaL_checkudata(L, 1, METATABLE_NAME);
	lua_pushstring(L, m->entry->d_name);
	return 1;
}

int os_matchisfile(lua_State* L)
{
	MatchInfo * m = (MatchInfo *)luaL_checkudata(L, 1, METATABLE_NAME);
#if defined(_DIRENT_HAVE_D_TYPE)
	// Dirent marks symlinks as DT_LNK, not (DT_LNK|DT_DIR). The fallback handles symlinks using stat.
	if (m->entry->d_type == DT_DIR)
	{
		lua_pushboolean(L, 0);
	}
	else
#endif
	{
		const char* fname;
		lua_pushfstring(L, "%s/%s", m->path, m->entry->d_name);
		fname = lua_tostring(L, -1);

		lua_pushboolean(L, do_isfile(L, fname));
	}
	return 1;
}

int os_matchnext(lua_State* L)
{
	MatchInfo *m = (MatchInfo *)luaL_checkudata(L, 1, METATABLE_NAME);
	if (m->handle == NULL) {
		return 0;
	}

	for (m->entry = readdir(m->handle); m->entry != NULL; m->entry = readdir(m->handle))
	{
		const char* name = m->entry->d_name;
		/* skip . and .. */
		if (name[0] == '.' && (name[1] == '\0' || (name[1] == '.' && name[2] == '\0')))
			continue;
		if (m->mask_is_literal ? strcmp(m->mask, name) == 0 : fnmatch(m->mask, name, 0) == 0)
		{
			lua_pushboolean(L, 1);
			return 1;
		}
	}

	return 0;
}

#endif
