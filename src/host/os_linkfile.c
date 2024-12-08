/**
 * \file os_linkfile.c
 * \brief Creates a symbolic link to a file.
 * \author Copyright (c) 2024 Jess Perkins and the Premake project
 */

#include <sys/stat.h>
#include "premake.h"

int do_linkfile(lua_State* L, const char* src, const char* dst)
{
#if PLATFORM_WINDOWS
    char dstPath[MAX_PATH];
	char srcPath[MAX_PATH];

	do_normalize(L, srcPath, src);
	do_normalize(L, dstPath, dst);
	do_translate(dstPath, '\\');
	do_translate(srcPath, '\\');

	// Promote to wide path
	wchar_t wSrcPath[MAX_PATH];
	wchar_t wDstPath[MAX_PATH];

	MultiByteToWideChar(CP_UTF8, 0, srcPath, -1, wSrcPath, MAX_PATH);
	MultiByteToWideChar(CP_UTF8, 0, dstPath, -1, wDstPath, MAX_PATH);

	// If the source path is relative, prepend the current working directory
	if (!do_isabsolute(src))
	{
		// Get the current working directory
		wchar_t cwd[MAX_PATH];
		GetCurrentDirectoryW(MAX_PATH, cwd);

		// Convert the source path to a relative path
		wchar_t relSrcPath[MAX_PATH + 2];
		swprintf(relSrcPath, MAX_PATH + 2, L"%c:%s", cwd[0], wSrcPath);
		relSrcPath[MAX_PATH + 1] = L'\0';

		BOOLEAN res = CreateSymbolicLinkW(wDstPath, relSrcPath, SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE);
		return res != 0;
	}
	else
	{
		BOOLEAN res = CreateSymbolicLinkW(wDstPath, wSrcPath, SYMBOLIC_LINK_FLAG_ALLOW_UNPRIVILEGED_CREATE);
		return res != 0;
	}
#else
	(void)L;
	if (!do_isabsolute(src))
	{
		char cwd[PATH_MAX];
		if (!do_getcwd(cwd, PATH_MAX))
		{
			return FALSE;
		}

		char relSrcPath[2 * PATH_MAX + 1];
		snprintf(relSrcPath, 2 * PATH_MAX + 1, "%s/%s", cwd, src);
		relSrcPath[2 * PATH_MAX] = '\0';

		int res = symlink(relSrcPath, dst);
		return res == 0;
	}
	else
	{
		int res = symlink(src, dst);
    	return res == 0;
	}
#endif
}

int os_linkfile(lua_State* L)
{
    const char* src = luaL_checkstring(L, 1);
    const char* dst = luaL_checkstring(L, 2);

    int result = do_linkfile(L, src, dst);
    if (!result)
    {
        lua_pushnil(L);
        lua_pushfstring(L, "Unable to create link from '%s' to '%s'", src, dst);
        return 2;
    }

    lua_pushboolean(L, 1);
    return 1;
}
