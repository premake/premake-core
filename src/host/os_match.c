/**
 * \file   os_match.c
 * \brief  Match files and directories.
 * \author Copyright (c) 2002-2014 Jason Perkins and the Premake project
 */

#include <stdlib.h>
#include <string.h>
#include "premake.h"


#if PLATFORM_WINDOWS

typedef struct struct_MatchInfo
{
	HANDLE handle;
	int    is_first;
	WIN32_FIND_DATAW entry;
} MatchInfo;

int os_matchstart(lua_State* L)
{
	const char* mask = luaL_checkstring(L, 1);
	MatchInfo* m;

	wchar_t wide_mask[PATH_MAX];
	if (MultiByteToWideChar(CP_UTF8, 0, mask, -1, wide_mask, PATH_MAX) == 0)
	{
		lua_pushstring(L, "unable to encode mask");
		return lua_error(L);
	}

	m = (MatchInfo*)malloc(sizeof(MatchInfo));

	m->handle = FindFirstFileW(wide_mask, &m->entry);
	m->is_first = 1;
	lua_pushlightuserdata(L, m);
	return 1;
}

int os_matchdone(lua_State* L)
{
	MatchInfo* m = (MatchInfo*)lua_touserdata(L, 1);
	if (m->handle != INVALID_HANDLE_VALUE)
		FindClose(m->handle);
	free(m);
	return 0;
}

int os_matchname(lua_State* L)
{
	MatchInfo* m = (MatchInfo*)lua_touserdata(L, 1);

	char filename[PATH_MAX];
	if (WideCharToMultiByte(CP_UTF8, 0, m->entry.cFileName, -1, filename, PATH_MAX, NULL, NULL) == 0)
	{
		lua_pushstring(L, "unable to decode filename");
		return lua_error(L);
	}

	lua_pushstring(L, filename);
	return 1;
}

int os_matchisfile(lua_State* L)
{
	MatchInfo* m = (MatchInfo*)lua_touserdata(L, 1);
	lua_pushboolean(L, (m->entry.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) == 0);
	return 1;
}

int os_matchnext(lua_State* L)
{
	MatchInfo* m = (MatchInfo*)lua_touserdata(L, 1);
	if (m->handle == INVALID_HANDLE_VALUE) {
		return 0;
	}

	while (m)  /* loop forever */
	{
		if (m->is_first)
			m->is_first = 0;
		else
		{
			if (!FindNextFileW(m->handle, &m->entry))
				return 0;
		}

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
	DIR* handle;
	struct dirent* entry;
	char* path;
	char* mask;
} MatchInfo;

int os_matchstart(lua_State* L)
{
	const char* split;
	const char* mask = luaL_checkstring(L, 1);
	MatchInfo* m = (MatchInfo*)malloc(sizeof(MatchInfo));

	/* split the mask into path and filename components */
	split = strrchr(mask, '/');
	if (split)
	{
		m->path = (char*)malloc(split - mask + 1);
		strncpy(m->path, mask, split - mask);
		m->path[split - mask] = '\0';
		m->mask = (char*)malloc(mask + strlen(mask) - split);
		strcpy(m->mask, split + 1);
	}
	else
	{
		m->path = (char*)malloc(2);
		strcpy(m->path, ".");
		m->mask = (char*)malloc(strlen(mask)+1);
		strcpy(m->mask, mask);
	}

	m->handle = opendir(m->path);
	lua_pushlightuserdata(L, m);
	return 1;
}

int os_matchdone(lua_State* L)
{
	MatchInfo* m = (MatchInfo*)lua_touserdata(L, 1);
	if (m->handle != NULL)
		closedir(m->handle);
	free(m->path);
	free(m->mask);
	free(m);
	return 0;
}

int os_matchname(lua_State* L)
{
	MatchInfo* m = (MatchInfo*)lua_touserdata(L, 1);
	lua_pushstring(L, m->entry->d_name);
	return 1;
}

int os_matchisfile(lua_State* L)
{
	MatchInfo* m = (MatchInfo*)lua_touserdata(L, 1);
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
		lua_pop(L, 1);

		lua_pushboolean(L, do_isfile(L, fname));
	}
	return 1;
}

int os_matchnext(lua_State* L)
{
	MatchInfo* m = (MatchInfo*)lua_touserdata(L, 1);
	if (m->handle == NULL) {
		return 0;
	}

	m->entry = readdir(m->handle);
	while (m->entry != NULL)
	{
		const char* name = m->entry->d_name;
		if (strcmp(name, ".") != 0 && strcmp(name, "..") != 0)
		{
			if (fnmatch(m->mask, name, 0) == 0)
			{
				lua_pushboolean(L, 1);
				return 1;
			}
		}
		m->entry = readdir(m->handle);
	}

	return 0;
}

#endif
